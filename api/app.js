'use strict'

var Mongo = require('./mongo');
Mongo.connect().then((err) => {
  run();
}).catch((err) => {
  console.log(err);
});

function run() {

  var express = require('express');
  var app = express();
  var bodyParser = require('body-parser');
  app.use(bodyParser.json());

  var Event = require('./event');
  var db = Mongo.db();

  // var Place = require('./place');
  // var YelpApi = require('./yelp-api');
  // var _ = require('underscore');



  // API
  app.post('/events', (req, res) => {
    var event = Event.fromJson(req.body);
    event.save().then((val) => {
      res.status(200).json(val.asJson());
    }).catch((err) => {
      res.status(500).json(err);
    });
  });

  app.get('/events/:eventId', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      res.status(200).json(event.asJson());
    }).catch((err) => {
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

  app.post('/events/:eventId/actions', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.saveActions(req.body);
    }).then((actions) => {
      res.status(200).json(actions.map((action) => action.asJson() ));
    }).catch((err) => {
      console.log(`Error in POST /events/:eventId/actions`, err);
      res.status(500).json(err);
    })
  });

  app.get('/events/:eventId/solution', (req, res) => {
    Event.fromId(req.params.eventId).then((event) => {
      return event.getSolution();
    }).then((solution) => {
      // res.status(200).json(solution.asJson());
      res.status(200).json(solution);
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/solution`, err);
      res.status(500).json(err);
    });
  });

  app.listen(3010, function() {
    console.log('App server started...');
  });
}

