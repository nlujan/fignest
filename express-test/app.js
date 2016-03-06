'use strict'

// import 'user';

var express = require('express');
var app = express();
var user = require('./user');
var request = require('request');
var cheerio = require('cheerio');
var _ = require('underscore');

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
    callback();
  });
};

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

  static fromJson() {

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
const imageUrlPrefix = 'http://www.yelp.com/biz_photos/';
const foodTab = 'http://www.yelp.com/biz_photos/';
const start = 'http://www.yelp.com/biz_photos/';
const imgSelector = '[data-photo-id] .photo-box-img';

// module?
class YelpAPI {

  static getImages(id, callback) {
    return new Promise((resolve, reject) => {
      request(`${imageUrlPrefix}/${id}`, (err, res, body) => {
        // err ? reject(err) : resolve(body);
        if (err) {
          reject(err);
        }
        resolve(HtmlParser.stringFromHtml(body, imgSelector));

      });
    });
  }
}



class HtmlParser {
  static stringFromHtml(html, selector) {
    let $ = cheerio.load(html);
    // return $(selector).attr('src');
    return $(selector);
  }
}

YelpAPI.getImages('black-iron-burger-new-york').then((val) => {
  console.log(typeof val);
  console.log(_.map(val, (element) => element.attr('src')));
});