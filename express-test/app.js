'use strict'

var Mongo = require('./mongo');
Mongo.connect().then((err) => {
  run();
});

function run() {

  var express = require('express');
  var app = express();
  var bodyParser = require('body-parser');
  app.use(bodyParser.json());

  var Event = require('./event');
  var YelpApi = require('./yelp-api');
  var db = Mongo.db();

  

  // api
  app.get('/', (req, res) => {
    res.send(`Hello World!`);
    new Car()
  });

  app.post('/events', (req, res) => {
    let event = Event.fromJson(req.body);
    event.save().then((val) => {
      res.status(200).json(val.asJson());
    });
  });

  app.get('/events/:eventId', (req, res) => {
    let eventAsync = Event.fromId(req.params.eventId)
    eventAsync.then((val) => {
      res.status(200).json(val.asJson());
    });
  });

  app.get('/find/:borough', (req, res) => {
    findRestaurants(db, ()=>5, null);
  });

  app.listen(3010, function() {
    console.log('listening...');
  });


  app.get('/place/:place', (req, res) =>{
    res.send(Place.fromYelpId(req.params.place).num);
  });

  app.get('/photos/:id', (req, res) => {
    YelpApi.getImages('black-iron-burger-new-york').then((val) => {
      res.send(val);
    });
  });

  YelpApi.getImages('black-iron-burger-new-york-3').then((val) => {
    console.log(val);
  }).catch((err) => {
    console.log(err);
  })
}

