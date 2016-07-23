'use strict';

var YelpApi = require('./yelp-api');
var Mongo = require('./mongo');
var db = Mongo.db();
var ObjectId = require('mongodb').ObjectID;
var _ = require('underscore');

const NUM_IMAGES_PER_PLACE = 6;

class Place {
  constructor(params) {
    this._id = params._id;
    this.yelpId = params.yelpId;
    this.event = params.event;
    this.name = params.name;
    this.rating = params.rating;
    this.urls = params.urls;
    this.images = params.images;
    this.phone = params.phone;
    this.location = params.location;
  }

  asJson() {
  	return this;
  }

  asDocument() {
    return this;
  }

  // Note resolves with place, not images (for now)
  getImages() {
  	return new Promise((resolve, reject) => {
  		YelpApi.getImages(this.yelpId).then((imageUrls) => {
        this.addImages(imageUrls);
        // resolve(this.images);
        return resolve(this);
      }).catch((err) => {
        return reject(err);
      });
  	});
  }

  addImages(urls) {
    this.images = _.sample(urls, NUM_IMAGES_PER_PLACE);
  }

  save() {
    return new Promise((resolve, reject) => {
      db.collection('places').save(this.asDocument(), null, (err, res) => {
        if (err) {
          console.log(`Error saving place to db: ${this}`, err);
          return reject(err);
        }
        return resolve(this);
      });
    });
  }

  static fromJson(data) {
  	let params = {};
  	params._id = data._id || null;
  	params.yelpId = data.id;
  	params.event = ObjectId(data.eventId);
  	params.name = data.name;
  	params.rating = data.rating;
  	params.urls = {
  		web: data.url,
  		mobile: data.mobile_url
  	};
    if (data.reservation_url) {
      params.urls.reservation = data.reservation_url;
    }
    if (data.eat24_url) {
      params.urls.delivery = data.eat24_url;
    }
  	params.images = data.images || [];
  	params.phone = data.phone;
  	params.location = data.location;
  	return new this(params);
  }

  static fromYelpJson(data, eventId) {
    // Add eventId to data
    data = _.extend(data, { eventId: eventId });

    return this.fromJson(data);
  }

  static fromId(_id) {
    return new Promise((resolve, reject) => {
      db.collection('places').findOne({
        _id: ObjectId(_id)
      }, (err, res) => {
        if (err) {
          console.log(`Error finding place with _id:${_id}`, err);
          return reject(err);
        }
        if (res == null) {
          return reject(`No place found with _id: ${_id}`);
        }
        return resolve(new this(res));
      });
    });
  }

}

module.exports = _.extend(Place, {
  NUM_IMAGES_PER_PLACE: NUM_IMAGES_PER_PLACE
});