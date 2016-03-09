'use strict';

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;

// var sampleEvent = {
//   "name": "Sample3",
//   "location": {
//     "type": "address",
//     "address": "1600 Pennsylvania Ave NW, Washington, DC 20500"
//   },
//   "users": [],
//   "search": "sushi"
// }

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

module.exports = Event;
