'use strict';

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
// See circular dependency note in getInvitations()
// var Event = require('./event');
var _ = require('underscore');

class User {
	constructor(params) {
    if (params._id) {
      this._id = params._id;  
    }
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
          return reject(err);
        }
        return resolve(this.constructor.fromJson(this));
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
          return reject(err);
        }
        // Todo: circular dependency here, since Event requires User.
        var Event = require('./event');
        return resolve(invitations.map((inv) => Event.fromJson(inv) ));
      });
    });
  }

  // Tries to find user. Creates new user on DB if one isn't found. Updates 
  // user if found.
  createOrUpdate() {
    return new Promise((resolve, reject) => {
      this.constructor.fromFacebookId(this.facebook.id).then((user) => {
        if (!user) { // user doesn't exist via facebook
          return this.save();
        } else { // user exists via facebook
          // Set new _id from existing user, then save.
          this._id = user._id;
          return this.save();
        }
      }).then((user) => {
        return resolve(this.constructor.fromJson(user));
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  static allUsers() {
    return new Promise((resolve, reject) => {
      var cursor = db.collection('users').find();
      cursor.toArray((err, users) => {
        if (err) {
          console.log(`Error getting all users`, err);
          return reject(err);
        }
        return resolve(users.map((user) => this.fromJson(user) ));
      });
    });
  }

  static usersMapById() {
    return new Promise((resolve, reject) => {
      this.allUsers().then((users) => {
        var map = _.map(users, (user) => [user._id, user] );
        return resolve(_.object(map));
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  static fromId(_id) {
    return new Promise((resolve, reject) => {
      db.collection('users').findOne({ _id: ObjectId(_id) }, (err, res) => {
        if (err) {
          console.log(`Error finding user with _id: ${_id}`, err);
          return reject(err);
        }
        return resolve(this.fromJson(res));
      });
    });
  }

  static fromFacebookId(id) {
    return new Promise((resolve, reject) => {
      db.collection('users').findOne({
        "facebook.id": id
      }, (err, res) => {
        if (err) {
          console.log(`Error finding user from facebook id: ${id}`, err);
          return reject(err);
        }
        if (!res) {
          return resolve();
        } else {
          return resolve(this.fromJson(res));
        }
      });
    });
  }

	static fromJson(data) {
    var params = {};
    if (data._id) {
      params._id = data._id;  
    }
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