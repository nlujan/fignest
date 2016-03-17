'use strict';

var sampleActions = [{
  "user": "someMongoId",
  "event": "someMongoId",
  "selections": [{
    "image": "image0",
    "place": "someMongoId0",
    "isSelected": false
  }, {
    "image": "image1",
    "place": "someMongoId1",
    "isSelected": true
  }, {
    "image": "image2",
    "place": "someMongoId2",
    "isSelected": false
  }, {
    "image": "image3",
    "place": "someMongoId3",
    "isSelected": false
  }, {
    "image": "image4",
    "place": "someMongoId4",
    "isSelected": false
  }, {
    "image": "image5",
    "place": "someMongoId5",
    "isSelected": false
  }]
}];

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;

class Action {
	constructor(params) {
    this._id = params._id;
    this.user = params.user;
    this.event = params.event;
    this.selections = params.selections;
	}

	asJson() {
		return this;
	}

  save() {
    return new Promise((resolve, reject) => {
      db.collection('actions').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving action to db: ${this}`, err);
          reject(err);
        }
        // resolve(res)?
        resolve(this);
      });
    });
  }

  asDocument() {
    return this;
  }

	static fromJson(data) {
    var params = {};
    params._id = data._id || null;
    params.user = data.user;
    params.event = data.event;
    params.selections = data.selections;
    return new this(params);
	}
}

module.exports = Action;