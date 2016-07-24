'use strict';

var Promise = require('bluebird');
Promise.onPossiblyUnhandledRejection((err) => {
  throw error;
});

var Mongo = require('./mongo');
Mongo.connect().then((err) => {
  run();
}).catch((err) => {
  console.log(err);
});

// Ports are as follows - localhost: 3010, heroku local: 5000, prod: fignest.herokuapp.com
const PORT = process.env.PORT || 3010;

function run() {

  var express = require('express');
  var app = express();
  var bodyParser = require('body-parser');
  app.use(bodyParser.json());

  var Event = require('./event');
  var User = require('./user');
  var Socket = require('./socket');
  var db = Mongo.db();

  var _ = require('underscore');

  // Start server
  var server = app.listen(PORT, () => {
    console.log(`App server started and listening on port: ${PORT}...`);
  });



  // SOCKETS
  var io = require('socket.io')(server);
  var rooms = {};
  io.on('connection', (socket) => {
    console.log('Client connected to socket.io');
    var s = new Socket(socket, io, rooms);
    s.addListeners();
  });


  // API
  app.get('/users', (req, res) => {
    User.allUsers().then((users) => {
      res.status(200).json(users.map((user) => user.asJson() ));
    }).catch((err) => {
      console.log(`Error in GET /users`, err);
      res.status(500).json(err);
    });
  });

  app.get('/usersMapById', (req, res) => {
    User.usersMapById().then((users) => {
      res.status(200).json(users);
    }).catch((err) => {
      console.log(`Error in GET /usersMapById`, err);
      res.status(500).json(err);
    });
  });

  app.post('/users', (req, res) => {
    var user = User.fromJson(req.body);
    user.createOrUpdate().then((user) => {
      res.status(200).json(user.asJson());
    }).catch((err) => {
      console.log(`Error in POST /users`, err);
      res.status(500).json(err);
    });
  });

  app.get('/users/:userId/invitations', (req, res) => {
    User.fromId(req.params.userId).then((user) => {
      return user.getInvitations();
    }).then((invitations) => {
      res.status(200).json(invitations.map((inv) => inv.asJson() ));
    }).catch((err) => {
      console.log(`Error in GET /users/:userId/invitations`, err);
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      res.status(200).json(event.asJson());
    }).catch((err) => {
      var errMsg = `Error in GET /events/:eventId with id: ${req.params.eventId} ${err}`;
      console.log(errMsg);
      res.status(500).json(errMsg);
    });
  });

  app.post('/events', (req, res) => {
    var event = Event.fromJson(req.body);
    event.save().then((val) => {
      res.status(200).json(val.asJson());
    }).catch((err) => {
      console.log(`Error in POST /events`, err);
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId/places', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.getPlaces();
    }).then((places) => {
      res.status(200).json(places.map((place) => place.asJson() ));
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/places`, err);
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId/solution', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.getSolution();
    }).then((solution) => {
      res.status(200).json(solution.asJson());
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/solution`, err);
      res.status(500).json(err);
    });
  });

  app.post('/events/:eventId/actions', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.saveAction(req.body);
    }).then((action) => {
      res.status(200).json(action.asJson());
    }).catch((err) => {
      console.log(`Error in POST /events/:eventId/actions`, err);
      res.status(500).json(err);
    });
  });
  
}

