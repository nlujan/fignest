'use strict';

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
var Event = require('./event');

class User {
	constructor(params) {
    this._id = params._id;
    this.displayName = params.displayName;
    this.facebook = params.facebook;
	}

	asJson() {
    return this;
	}

  asDocument() {
    return this;
  }

  save() {
    return new Promise((resolve, reject) => {
      db.collection('users').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving user to db: ${this}`, err);
          reject(err);
        }
        resolve(this.constructor.fromJson(this));
      });
    });
  }

  getInvitations() {
    return new Promise((resolve, reject) => {
      // Improve query
      var cursor = db.collection('events').find({
        users: this._id,
        isOver: false
      });
      cursor.toArray((err, invitations) => {
        if (err) {
          console.log(`Error getting invitations for user: ${this}`, err);
          reject(err);
        }
        resolve(invitations.map((inv) => Event.fromJson(inv) ));
      });
    });
  }

  static allUsers() {
    return new Promise((resolve, reject) => {
      var cursor = db.collection('users').find();
      cursor.toArray((err, users) => {
        if (err) {
          console.log(`Error getting all users`, err);
          reject(err);
        }
        resolve(users.map((user) => this.fromJson(user) ));
      });
    });
  }

  static fromId(_id) {
    return new Promise((resolve, reject) => {
      db.collection('users').findOne({ _id: ObjectId(_id) }, (err, res) => {
        if (err) {
          console.log(`Error finding user with _id: ${_id}`, err);
          reject(err);
        }
        resolve(this.fromJson(res));
      });
    });
  }

	static fromJson(data) {
    var params = {};
    params._id = data._id || null;
    params.displayName = this.getDisplayName(data);
    params.facebook = data.facebook;
    return new this(params);
	}

  static getDisplayName(userData) {
    var displayName;
    if (userData.facebook && userData.facebook.name) {
      displayName = userData.facebook.name;
    } else {
      displayName = 'Private User';
    }
    return displayName;
  }
}

module.exports = User;