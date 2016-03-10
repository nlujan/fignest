'use strict';

var YelpApi = require('./yelp-api');

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

  getImages() {
  	return new Promise((resolve, reject) => {
  		YelpApi.getImages(this.yelpId).then((imageUrls) => {
        this.images = imageUrls;
        resolve(this.images);
      }).catch((err) => {
        reject(err);
      });
  	});
  }

  static fromJson(data) {
  	let params = {};
  	params._id = data._id || null;
  	params.yelpId = data.id;
  	params.event = data.eventId;
  	params.name = data.name;
  	params.rating = data.rating;
  	params.urls = {
  		web: data.url,
  		mobile: data.mobile_url,
  		reservation: data.reservation_url,
  		delivery: data.eat24_url
  	};
  	params.images = data.images || [];
  	params.phone = data.phone;
  	params.location = data.location;
  	return new this(params);
  }

  static saveMany() {
    
  }

  // static fromYelpId(num) {
  //   // yelp
  //   return new this(num);
  // }
}

module.exports = Place;