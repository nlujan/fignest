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
  var Place = require('./place');
  var YelpApi = require('./yelp-api');
  var db = Mongo.db();
  var _ = require('underscore');

  const placesPerEvent = 5;
  const eventHasPlacesMsg = 'Event already has places';



  // api

  app.post('/events', (req, res) => {
    let event = Event.fromJson(req.body);
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

  // move most of this logic into Event
  app.get('/events/:eventId/places', (req, res) => {
    // probably better way to do this
    var _event;
    var _places;
    Event.fromId(req.params.eventId).then((event) => {
      _event = event;
      if (_event.hasPlaces()) {

        // Just query for places. Don't generate new places.
        // Cleaner implementation without throwing error
        throw new Error(eventHasPlacesMsg);
        return;
      } else {
        return YelpApi.search(_event.getSearchParams());
      }
      
    }).then((businesses) => {
      // pick 5 businesses at random
      businesses = _.sample(businesses, placesPerEvent);

      // merge/extend biz
      var places = businesses.map((business) => {
        // Add eventId to params for new Place
        _.extend(business, { eventId: _event._id });
        return Place.fromJson(business);
      });

      return Promise.all(places.map((place) => place.getImages()));
    }).then((places) => {

      // save places
      // bulk save instead?
      return Promise.all(places.map((place) => place.save()));
    }).then((places) => {
      _places = places;

      // add places to event
      _event.addPlaces(places);

      // save event
      return _event.save();
    }).then((event) => {
      res.status(200).json(_places.map((place) => place.asJson()));
    }).catch((err) => {
      if (err.message === eventHasPlacesMsg) {
        // use $in query instead
        Promise.all(_event.places.map((id) => Place.fromId(id))).then((places) => {
          res.status(200).json(places);
        });
      } else {
        console.log(`Error in GET /events/:eventId/places`, err);
        res.status(500).json(err);
      }
    });
  });

  app.listen(3010, function() {
    console.log('App server started...');
  });
}

