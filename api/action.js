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
    params.user = ObjectId(data.user);
    params.event = ObjectId(data.event);
    // Convert selection.place to ObjectId(selection.place);
    params.selections = data.selections.map((selection) => {
      return _.extend(selection, { place: ObjectId(selection.place) });
    });
    return new this(params);
	}

  static actionsFromEventId(eventId) {
    return new Promise((resolve, reject) => {
      var cursor = db.collection('actions').find({ event: eventId });
      cursor.toArray((err, actions) => {
        if (err) {
          console.log(`Error getting actions from event ID: ${eventId}`, err);
          reject(err);
        }
        resolve(actions.map((action) => this.fromJson(action) ));
      });
    });
  }
}

module.exports = Action;

// var sampleActions = [{
//   "user": "56eefe0835c5fe7e04913260",
//   "event": "56eefe0835c5fe7e04913260",
//   "selections": [{
//     "image": "image0",
//     "place": "56eefe1035c5fe7e04913261",
//     "isSelected": false
//   }, {
//     "image": "image1",
//     "place": "56eefe1035c5fe7e04913262",
//     "isSelected": true
//   }, {
//     "image": "image2",
//     "place": "56eefe1035c5fe7e04913263",
//     "isSelected": false
//   }, {
//     "image": "image3",
//     "place": "56eefe1035c5fe7e04913261",
//     "isSelected": false
//   }, {
//     "image": "image4",
//     "place": "56eefe1035c5fe7e04913262",
//     "isSelected": false
//   }, {
//     "image": "image5",
//     "place": "56eefe1035c5fe7e04913263",
//     "isSelected": false
//   }]
// }, {
//   "user": "56eefe0835c5fe7e04913260",
//   "event": "56eefe0835c5fe7e04913260",
//   "selections": [{
//     "image": "image0",
//     "place": "56eefe1035c5fe7e04913261",
//     "isSelected": false
//   }, {
//     "image": "image1",
//     "place": "56eefe1035c5fe7e04913262",
//     "isSelected": true
//   }, {
//     "image": "image2",
//     "place": "56eefe1035c5fe7e04913263",
//     "isSelected": false
//   }, {
//     "image": "image3",
//     "place": "56eefe1035c5fe7e04913261",
//     "isSelected": false
//   }, {
//     "image": "image4",
//     "place": "56eefe1035c5fe7e04913262",
//     "isSelected": false
//   }, {
//     "image": "image5",
//     "place": "56eefe1035c5fe7e04913263",
//     "isSelected": false
//   }]
// }];