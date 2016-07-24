'use strict';

var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
var Place = require('./place');
var Action = require('./action');
var User = require('./user');
var YelpApi = require('./yelp-api');
var Util = require('./util');
var _ = require('underscore');

const SEARCH_CATEGORY = 'food';
// Number of results to return from Yelp search, not to be confused with the
// number of places to consider as a solution.
const SEARCH_LIMIT = 20;
// For sort, 0 = best matched, 1 = distance, 2 = highest rated
const SEARCH_SORT = 2;
const SEARCH_SHOULD_INCLUDE_ACTION_LINKS = true;
const EVENT_RADIUS_DEFAULT = 3;
const EVENT_LIMIT_DEFAULT = 6;

class Event {
	constructor(params) {
    if (params._id) {
      this._id = params._id;  
    }
    this.name = params.name;
    this.location = params.location;
    this.users = params.users;
    this.search = params.search;
    this.isOver = params.isOver;
    this.limit = params.limit;
    this.places = params.places;
    this.actions = params.actions;
    this.solution = params.solution;
    this.createdAt = params.createdAt;
	}

	save() {
    return new Promise((resolve, reject) => {
      db.collection('events').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving event to db: ${this}`, err);
          return reject(err);
        }
        return resolve(this.constructor.fromJson(this));
      });
    });
	}

	asJson() {
    var eventKeysToOmit = ['isOver', 'places', 'actions', 'solution'];
    return _.omit(this, eventKeysToOmit);
	}

  asDocument() {
    return this;
  }

  getSearchParams() {
    var result = {};
    result.term = this.search;
    result.limit = SEARCH_LIMIT;
    result.sort = SEARCH_SORT;
    result.category_filter = SEARCH_CATEGORY;
    result.radius_filter = Util.milesToMeters(this.location.radius || EVENT_RADIUS_DEFAULT);
    if (this.location.type === 'address') {
      result.location = this.location.address;
    } else if (this.location.type === 'coord') {
      result.ll = `${this.location.lat},${this.location.long}`;
    }
    result.actionlinks = SEARCH_SHOULD_INCLUDE_ACTION_LINKS;
    return result;
  }

  getUsers() {
    return new Promise((resolve, reject) => {
      // $in query instead
      Promise.all(_.map(this.users, (user) => User.fromId(user))).then((users) => {
        return resolve(users);
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  getPlaces() {
    return new Promise((resolve, reject) => {
      if (this.hasPlaces()) {
        // Just get current places; no need to generate new places.
        // Use $in query instead of Promise.all, or single query of places using
        // eventId.
        Promise.all(_.map(this.places, (id) => {
          return Place.fromId(id);
        })).then((places) => {
          return resolve(places);
        }).catch((err) => {
          return reject(err);
        });
      } else { // Event doesn't already have places
        this.generatePlaces().then((places) => {
          return resolve(places);
        }).catch((err) => {
          return reject(err);
        });
      }
    });
  }

  generatePlaces() {
    // Might be better way to scope _places here
    var _places;
    return new Promise((resolve, reject) => {
      YelpApi.search(this.getSearchParams()).then((yelpBusinesses) => {
        // pick this.limit businesses at random
        yelpBusinesses = _.sample(yelpBusinesses, this.limit);
        Util.ensureLength(yelpBusinesses, this.limit);

        var places = _.map(yelpBusinesses, (biz) => Place.fromYelpJson(biz, this._id));
        return Promise.all(_.map(places, (place) => place.getImages()));
      }).then((places) => {
        // Save places
        // Hanlde in Place.getImages() instead?
        // Bulk save instead?
        return Promise.all(_.map(places, (place) => place.save() ));
      }).then((places) => {
        _places = places;

        // Add places to event
        this.addPlaces(_places);

        // Save event
        return this.save();
      }).then((event) => {
        return resolve(_places);
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  addPlaces(places) {
    this.places = _.map(places, (place) => place._id);
  }

  hasPlaces() {
    return this.places && (this.places.length > 0);
  }

  getSolution() {
    return new Promise((resolve, reject) => {
      if (this.hasSolution()) {
        Place.fromId(this.solution).then((solution) => {
          return resolve(solution);
        }).catch((err) => {
          return reject(err);
        });
      } else { // Event doesn't already have solution
        this.generateSolution().then((solution) => {
          return resolve(solution);
        }).catch((err) => {
          return reject(err);
        });
      }
    });
  }

  generateSolution() {
    var _solutionId;
    return new Promise((resolve, reject) => {
      Action.actionsFromEventId(this._id).then((actions) => {
        if (actions == null || actions.length === 0) {
          throw 'This event has no actions.';
        }
        _solutionId = this.constructor.solutionIdFromActions(actions);
        this.addSolution(_solutionId);
        this.addIsOver();
        return this.save();
      }).then((event) => {
        return Place.fromId(_solutionId);
      }).then((solution) => {
        return resolve(solution);
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  addSolution(solutionId) {
    this.solution = ObjectId(solutionId);
  }

  hasSolution() {
    return !!this.solution;
  }

  addIsOver() {
    this.isOver = true;
  }

  saveAction(action) {
    // Might be better way to scope _actions here
    var _action;
    
    return new Promise((resolve, reject) => {
      // Save action
      Action.fromJson(action).save().then((action) => {
        _action = action;

        // Add action to event
        this.addAction(_action);

        // Save event
        return this.save();
      }).then((event) => {
        return resolve(_action);
      }).catch((err) => {
        return reject(err);
      });
    });
  }

  addAction(action) {
    if (!this.actions) {
      this.actions = [action._id];
      return;
    }
    this.actions.push(action._id);
  }

  static solutionIdFromActions(actions) {
    if (actions == null || actions.length === 0) {
      console.log(`Error in Event.solutionIdFromActions: no actions provided`);
      return;
    }
    var selections = _.reduce(actions, (memo, action) => {
      return memo.concat(action.selections);
    }, []);
    var posSelections = _.filter(selections, (sel) => sel.isSelected );
    var posSelectionsCountByPlace = _.countBy(posSelections, (sel) => sel.place );
    var solutionId = _.max(_.keys(posSelectionsCountByPlace), (place) => posSelectionsCountByPlace[place] );
    return solutionId;
  }

  static fromJson(data) {
    var params = {};
    if (data._id) {
      params._id = data._id;
    }
    params.name = data.name;
    params.location = data.location;
    params.location.radius = data.location.radius || EVENT_RADIUS_DEFAULT;
    params.users = _.map(data.users, (user) => ObjectId(user));
    params.search = data.search || '';
    params.isOver = data.isOver == null ? false : data.isOver;
    params.limit = data.limit || EVENT_LIMIT_DEFAULT;
    params.createdAt = data.createdAt || new Date();
    return new this(params);
  }

  static fromId(_id) {
    return new Promise((resolve, reject) => {
      db.collection('events').findOne({
        _id: ObjectId(_id)
      }, (err, res) => {
        if (err) {
          console.log(`error finding document with _id:${_id}`);
          return reject(err);
        }
        if (!res) {
          var errorMsg = `Can't find event with id: ${_id}`;
          return reject(errorMsg);
        }
        return resolve(new this(res));
      });
    });
  }
}

module.exports = _.extend(Event, {
  EVENT_LIMIT_DEFAULT: EVENT_LIMIT_DEFAULT,
  EVENT_RADIUS_DEFAULT: EVENT_RADIUS_DEFAULT,
  SEARCH_CATEGORY: SEARCH_CATEGORY,
  SEARCH_LIMIT: SEARCH_LIMIT,
  SEARCH_SORT: SEARCH_SORT,
  SEARCH_SHOULD_INCLUDE_ACTION_LINKS: SEARCH_SHOULD_INCLUDE_ACTION_LINKS
});
