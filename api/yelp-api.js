'use strict';

var request = require('request');
var Yelp = require('yelp');
var HtmlParser = require('./html-parser');

const yelpUrl = {
  base: 'https://www.yelp.com',
  photos: 'biz_photos',
  food: '?tab=food'
}
const start = '';
const imgSelector = '[data-photo-id] .photo-box-img';
const attribute = 'src';
var yelp = new Yelp({
  consumer_key: process.env.YELP_CONSUMER_KEY,
  consumer_secret: process.env.YELP_CONSUMER_SECRET,
  token: process.env.YELP_CONSUMER_TOKEN,
  token_secret: process.env.YELP_CONSUMER_SECRET
});

class YelpApi {
  static getImages(id) {
    return new Promise((resolve, reject) => {
      // clean requests
      let requestUrl = `${yelpUrl.base}/${yelpUrl.photos}/${id}${yelpUrl.food}`
      request(requestUrl, (err, httpMsg, body) => {
        if (err) {
          console.log(`Error requesting the URL:${requestUrl}`);
          reject(err);
        }
        let imageUrls = HtmlParser.attrFromSelector(body, imgSelector, attribute);
        imageUrls = imageUrls.map((url) => HtmlParser.addProtocol(url));
        resolve(imageUrls);
      });
    });
  }

  static search(params) {
    return new Promise((resolve, reject) => {
      yelp.search(params).then((results) => {
        // console.log(results);
        resolve(results.businesses);
      }).catch((err) => {
        reject(err);
      });
    });
  }
}

module.exports = YelpApi;