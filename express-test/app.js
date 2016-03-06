'use strict'

// import 'user';

var express = require('express');
var app = express();
var user = require('./user');
var request = require('request');
var cheerio = require('cheerio');
// var _ = require('underscore');

// mongo
var MongoClient = require('mongodb').MongoClient;
var assert = require('assert');
var url = 'mongodb://localhost:27017/test';
var db;
MongoClient.connect(url, (err, mdb) => {
  db = mdb;
  assert.equal(null, err);
  console.log("Connected correctly to server.");
  // db.close();
});

var insertDocument = function(db, callback) {
   db.collection('restaurants').insertOne( {
      "address" : {
         "street" : "2 Avenue",
         "zipcode" : "10075",
         "building" : "1480",
         "coord" : [ -73.9557413, 40.7720266 ]
      },
      "borough" : "Manhattan",
      "cuisine" : "Italian",
      "grades" : [
         {
            "date" : new Date("2014-10-01T00:00:00Z"),
            "grade" : "A",
            "score" : 11
         },
         {
            "date" : new Date("2014-01-16T00:00:00Z"),
            "grade" : "B",
            "score" : 17
         }
      ],
      "name" : "Vella",
      "restaurant_id" : "41704620"
   }, function(err, result) {
    assert.equal(err, null);
    console.log("Inserted a document into the restaurants collection.");
    callback && callback();
  });
};

insertDocument(db);

var findRestaurants = function(db, callback, borough) {
   var cursor = db.collection('restaurants').find( { "borough": "Manhattan" } );
   cursor.each(function(err, doc) {
      assert.equal(err, null);
      if (doc != null) {
         console.dir(doc);
      } else {
         callback();
      }
   });
};

// api
app.get('/', (req, res) => {
	res.send(`Hello World!`);
	new Car()
	insertDocument(db, () => 5);
});

app.get('/find/:borough', (req, res) => {
  findRestaurants(db, ()=>5, null);
});

app.listen(3010, function() {
	console.log('listening...');
});

class Car {
	constructor() {
		console.log('here');
	}
}


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
	constructor() {

	}

	save() {

	}

	asJson() {

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

  static createFromJson(data) {
    let name = data.name;
    let location = data.location;
    let users = data.users;
    let search = data.search;
    let isOpen = data.isOpen == null ? false : data.isOpen;
    let isOver = data.isOver == null ? false : data.isOver;
    let limit = data.limit || 5;
    let event = new this(name, location, users, search, isOpen, isOver, limit);
    event.save().then((val) => {

    })
  }

  static fromId() {

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