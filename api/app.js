'use strict'

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
  var db = Mongo.db();

  var _ = require('underscore');

  // Start server
  var server = app.listen(PORT, () => {
    console.log(`App server started and listening on port: ${PORT}...`);
  });










  // Socket
  var io = require('socket.io')(server);

  // should store rooms in db instead of memory
  var rooms = {
    // eventId0: [user0, user1, ...],
    // eventId1: ...
  };
  const STATUS_READY = 'ready';
  const STATUS_WAITING = 'waiting';
  const STATUS_DONE = 'done';
  // status start progress constants

  io.on('connection', (socket) => {
    console.log('Client connected to socket');

    socket.on('join', (data) => {
      // Race condition if 1 person joins before another is done joining
      var userId = data.userId;
      var eventId = data.eventId;
      joinRoom(userId, eventId).then(() => {
        // Add user to room and broadcast to everyone (including user)
        socket.join(eventId);
        io.sockets.in(eventId).emit('status', rooms[eventId]);

        // Check if we should start event
        if (shouldStartEvent(eventId)) {
          io.sockets.in(eventId).emit('start');
        }
      });
    });

    socket.on('progress', (data) => {
      var userId = data.userId;
      var eventId = data.eventId;
      var level = data.level;
      var user = _.find(rooms[eventId], (user) => user._id.toString() === userId);

      // Broadcast to room (except client)
      socket.broadcast.to(eventId).emit('progress', {
        user: user,
        level: level
      });
    });

    socket.on('done', (data) => {
      var userId = data.userId;
      var eventId = data.eventId;
      var user = _.find(rooms[eventId], (user) => user._id.toString() === userId);
      user.status = STATUS_DONE;
      io.sockets.in(eventId).emit('status', rooms[eventId]);

      // Check if we should finish event
      if (shouldFinishEvent(eventId)) {
        io.sockets.in(eventId).emit('finish');

        // And clean the room
        delete rooms[eventId];
      }
    });

    function shouldStartEvent(eventId) {
      return _.every(rooms[eventId], (user) => user.status === STATUS_READY);
    }

    function shouldFinishEvent(eventId) {
      return _.every(rooms[eventId], (user) => user.status === STATUS_DONE);
    }

    function roomExists(eventId) {
      return rooms[eventId] && rooms[eventId].length > 0;
    }

    function joinRoom(userId, roomId) {
      return new Promise((resolve, reject) => {
        if (!roomExists(roomId)) { // Room doesn't exist
          Event.fromId(roomId).then((event) => {
            return event.getUsers();
          }).then((users) => {
            // Map users to include status either "ready" or "waiting"
            rooms[roomId] = users.map((user) => {
              return _.extend(user, {
                status: (user._id.toString() === userId) ? STATUS_READY : STATUS_WAITING
              });
            });
            return resolve();
          });
        } else { // Room already exists
          var users = rooms[roomId];
          var currentUser = _.find(users, (user) => user._id.toString() === userId );
          currentUser.status = STATUS_READY;
          return resolve();
        }
      });
    }

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

