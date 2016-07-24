'use strict';

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
var _ = require('underscore');

class Action {
	constructor(params) {
    this._id = params._id;
    this.user = params.user;
    this.event = params.event;
    this.selections = params.selections;
    this.createdAt = params.createdAt;
	}

	asJson() {
		return this;
	}

  save() {
    return new Promise((resolve, reject) => {
      db.collection('actions').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving action to db: ${this}`, err);
          return reject(err);
        }
        return resolve(this.constructor.fromJson(this));
      });
    });
  }

  asDocument() {
    return this;
  }

	static fromJson(data) {
    var params = {};
    params._id = data._id || null;
    params.user = ObjectId(data.user);
    params.event = ObjectId(data.event);
    // Convert selection.place to ObjectId(selection.place);
    params.selections = data.selections.map((selection) => {
      return _.extend(selection, { place: ObjectId(selection.place) });
    });
    params.createdAt = data.createdAt || new Date();
    return new this(params);
	}

  static actionsFromEventId(eventId) {
    return new Promise((resolve, reject) => {
      var cursor = db.collection('actions').find({ event: eventId });
      cursor.toArray((err, actions) => {
        if (err) {
          console.log(`Error getting actions from event ID: ${eventId}`, err);
          return reject(err);
        }
        return resolve(actions.map((action) => this.fromJson(action) ));
      });
    });
  }
}

module.exports = Action;
