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

  

  // api
  app.get('/', (req, res) => {
    res.send(`Hello World!`);
    new Car()
  });

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

  app.get('/events/:eventId/places', (req, res) => {
    // probably better way to do this
    var _event;
    Event.fromId(req.params.eventId).then((event) => {
      _event = event;
      return YelpApi.search(_event.getSearchParams());
    }).then((businesses) => {
      // res.status(200).json(_event);
      // pick 5 businesses at random
      businesses = _.sample(businesses, placesPerEvent);

      // merge/extend biz
      var places = businesses.map((business) => {
        // Add eventId to params for new Place
        _.extend(business, { eventId: _event._id });
        return Place.fromJson(business).asJson();
      });
      // res.json(places);
      places[0].getImages().then((images)=> res.json(images));


      // var promiseImages = new Promise.all(places.map((place) => place.getImages()));
      // save places
      // add places to event
      // save event
    }).then((images) => {
      // want places here
      // res place.asJson each
    }).catch((err) => {
      console.log(`Error in GET /events/:eventId/places`, err);
      res.status(500).json(err);
    });

    // YelpApi.search(val.getSearchParams()).then((places) => {
    //   res.status(200).json(places.businesses.map((biz)=> biz.name));
    // });
  });





  // app.get('/find/:borough', (req, res) => {
  //   findRestaurants(db, ()=>5, null);
  // });

  app.listen(3010, function() {
    console.log('App server started...');
  });


  // app.get('/place/:place', (req, res) =>{
  //   res.send(Place.fromYelpId(req.params.place).num);
  // });

  // app.get('/photos/:id', (req, res) => {
  //   YelpApi.getImages('black-iron-burger-new-york').then((val) => {
  //     res.send(val);
  //   });
  // });

  YelpApi.getImages('black-iron-burger-new-york-3').then((val) => {
    console.log(val);
  }).catch((err) => {
    console.log(err);
  });
}

