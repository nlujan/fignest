'use strict'

// import 'user';

var express = require('express');
var app = express();
var bodyParser = require('body-parser');
app.use(bodyParser.json());

var user = require('./user');
var request = require('request');
var cheerio = require('cheerio');
// var _ = require('underscore');

// mongo
var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var ObjectId = require('mongodb').ObjectID;
var url = 'mongodb://localhost:27017/test';
var db;
MongoClient.connect(url, (err, mdb) => {
  db = mdb;
  assert.equal(null, err);
  console.log("Connected correctly to server.");
  // db.close();
  // insertDocument(db);
  // console.log(Event.fromJson(sampleEvent).save().then((val) => {
  //   console.log(1)
  // }));
  // Event.fromId('56dc5e6973cd424e4be05174').then((val) => {
  //   console.log(val);
  // });
});

var sampleEvent = {
  "name": "Sample3",
  "location": {
    "type": "address",
    "address": "1600 Pennsylvania Ave NW, Washington, DC 20500"
  },
  "users": [],
  "search": "sushi"
}



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
  YelpAPI.getImages('black-iron-burger-new-york').then((val) => {
    res.send(val);
  });
});


class User {
  constructor() {

  }

  asJson() {

  }

  getInvitations() {

  }

  static fromId() {

  }

  static fromJson() {

  }
}

class Event {
	constructor(params) {
    this._id = params._id;
    this.name = params.name;
    this.location = params.location;
    this.users = params.users;
    this.search = params.search;
    this.isOpen = params.isOpen;
    this.isOver = params.isOver;
    this.limit = params.limit;
	}

	save() {
    return new Promise((resolve, reject) => {
      db.collection('events').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving event to db`, err);
          reject(err);
        }
        resolve(this);
      });
    });
	}

	asJson() {
    return this;
	}

  asDocument() {
    return this;
  }

  sendInvitations() {

  }

  createPlaces() {

  }

  getPlaces() {
    // yelp search
  }

  getSolution() {

  }

  createSolution() {

  }

  addActions() {

  }

  getActions() {

  }

  static fromJson(data) {
    let params = {};
    params._id = data._id || null;
    params.name = data.name;
    params.location = data.location;
    params.location.radius = data.location.radius || 1;
    params.users = data.users;
    params.search = data.search;
    params.isOpen = data.isOpen == null ? false : data.isOpen;
    params.isOver = data.isOver == null ? false : data.isOver;
    params.limit = data.limit || 5;
    return new this(params);
  }

  static fromId(_id) {
    return new Promise((resolve, reject) => {
      db.collection('events').findOne({
        _id: ObjectId(_id)
      }, (err, res) => {
        if (err) {
          console.log(`error finding document with _id:${_id}`);
          reject(err);
        }
        resolve(new this(res));
      });
    });
  }
}


class Place {
  constructor(num) {
    this.num = num;
  }

  asJson() {

  }

  static fromYelpId(num) {
    // yelp
    return new this(num);
  }
}

class Action {
  constructor() {

  }

  asJson() {

  }

  static fromJson() {

  }
}

// figure out how to put this in the class/module
const yelpUrl = {
  base: 'https://www.yelp.com',
  photos: 'biz_photos',
  food: '?tab=food'
}
const start = '';
const imgSelector = '[data-photo-id] .photo-box-img';
const attribute = 'src';

// module?
class YelpApi {
  static getImages(id) {
    return new Promise((resolve, reject) => {
      let requestUrl = `${yelpUrl.base}/${yelpUrl.photos}/${id}${yelpUrl.food}`
      request(requestUrl, (err, httpMsg, body) => {
        if (err) {
          console.log(`Error requesting the URL:${requestUrl}`);
          reject(err);
        }
        let imageUrls = HtmlParser.attrFromSelector(body, imgSelector, attribute);
        imageUrls = imageUrls.map((url) => HtmlParser.addProtocol(url));
        resolve(imageUrls);
      });
    });
  }
}


const defaultProtocol = 'https';

class HtmlParser {
  static attrFromSelector(html, selector, attribute) {
    let $ = cheerio.load(html);
    let res = [];
    $(selector).each((i, el) => {
      res.push($(el).attr(attribute));
    });
    return res;
  }

  static addProtocol(str, protocol) {
    protocol = protocol || defaultProtocol;
    return `${protocol}:${str}`;
  }
}

YelpApi.getImages('black-iron-burger-new-york-3').then((val) => {
  console.log(val);
}).catch((err) => {
  console.log(err);
})