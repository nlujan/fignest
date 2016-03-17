'use strict';

// var sampleEvent = {
//   "name": "Sample3",
//   "location": {
//     "type": "address",
//     "address": "1600 Pennsylvania Ave NW, Washington, DC 20500"
//   },
//   "users": [],
//   "search": "sushi",
//   "places": [yelpIds]
// };

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
var Place = require('./place');
var Action = require('./action');
var YelpApi = require('./yelp-api');
var _ = require('underscore');

const search = {
  category: 'food',
  limit: 20,
  // For sort, 0 = best matched, 1 = distance, 2 = highest rated
  sort: 2,
  shouldIncludeActionLinks: true
};
const placesPerEvent = 5;


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
    this.places = params.places;
    this.actions = params.actions;
	}

	save() {
    return new Promise((resolve, reject) => {
      db.collection('events').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving event to db: ${this}`, err);
          reject(err);
        }
        // resolve(res)?
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

  generatePlaces() {
    // Might be better way to scope _places here
    var _places;
    return new Promise((resolve, reject) => {
      YelpApi.search(this.getSearchParams()).then((yelpBusinesses) => {
        // pick 5 businesses at random
        yelpBusinesses = _.sample(yelpBusinesses, placesPerEvent);

        var places = yelpBusinesses.map((biz) => Place.fromYelpJson(biz));
        return Promise.all(places.map((place) => place.getImages()));
      }).then((places) => {
        // Save places
        // Hanlde in Place.getImages() instead?
        // Bulk save instead?
        return Promise.all(places.map((place) => place.save() ));
      }).then((places) => {
        _places = places;

        // Add places to event
        this.addPlaces(_places);

        // Save event
        return this.save();
      }).then((event) => {
        resolve(_places);
      }).catch((err) => {
        reject(err);
      });
    });
  }

  getPlaces() {
    return new Promise((resolve, reject) => {
      if (this.hasPlaces()) {
        // Just get current places; no need to generate new places.
        // Use $in query instead of Promise.all, or single query of places using
        // eventId.
        Promise.all(this.places.map((id) => {
          return Place.fromId(id);
        })).then((places) => {
          resolve(places);
        }).catch((err) => {
          reject(err);
        });
      } else {
        this.generatePlaces().then((places) => {
          resolve(places);
        }).catch((err) => {
          reject(err);
        });
      }
    });
    
  }

  addPlaces(places) {
    this.places = places.map((place) => place._id);
  }

  hasPlaces() {
    return this.places && this.places.length;
  }

  getSearchParams() {
    var result = {};
    result.term = this.search;
    result.limit = search.limit;
    result.sort = search.sort;
    result.category = search.category;
    result.radius = this.location.radius;
    if (this.location.type === 'address') {
      result.location = this.location.address;
    } else if (this.location.type === 'coord') {
      result.ll = `${this.location.lat},${this.location.long}`;
    }
    result.actionlinks = search.shouldIncludeActionLinks;
    return result;
  }

  getSolution() {

  }

  createSolution() {

  }

  saveActions(actions) {
    // Might be better way to scope _actions here
    var _actions;
    actions = actions.map((action) => Action.fromJson(action) );
    
    return new Promise((resolve, reject) => {
      // Bulk save?
      // Save actions
      Promise.all(actions.map((action) => action.save())).then((actions) => {
        _actions = actions;

        // Add actions to event
        this.addActions(_actions);

        // Save event
        return this.save();
      }).then((event) => {
        resolve(_actions);
      }).catch((err) => {
        reject(err);
      });
    });
  }

  addActions(actions) {
    this.actions = actions.map((action) => action._id );
  }

  static fromJson(data) {
    var params = {};
    params._id = data._id || null;
    params.name = data.name;
    params.location = data.location;
    params.location.radius = data.location.radius || 1;
    params.users = data.users;
    params.search = data.search || '';
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
