'use strict';

var request = require('request');
var Yelp = require('yelp');
var HtmlParser = require('./html-parser');
var _ = require('underscore');

const YELP_URL_BASE = 'https://www.yelp.com';
const YELP_URL_PHOTOS = 'biz_photos';
const YELP_URL_FOOD = '?tab=food';
const IMG_SELECTOR = '[data-photo-id] .photo-box-img';
const ATTRIBUTE = 'src';

var yelp = new Yelp({
  consumer_key: process.env.YELP_CONSUMER_KEY || 'K_C4kW5f7TDvoq7bB_4Z0w',
  consumer_secret: process.env.YELP_CONSUMER_SECRET || 'Wiijly9VWQAkWFWAY-Q4cn4T150',
  token: process.env.YELP_TOKEN || 'TsLL78ojlMFKoaD_haODwDrIwb9AUDl5',
  token_secret: process.env.YELP_TOKEN_SECRET || '9JM22dL0dlRCX_VyhItQscTU870'
});

class YelpApi {
  static getImages(id) {
    return new Promise((resolve, reject) => {
      // clean requests
      let requestUrl = `${YELP_URL_BASE}/${YELP_URL_PHOTOS}/${id}${YELP_URL_FOOD}`;
      request(requestUrl, (err, httpMsg, body) => {
        if (err) {
          console.log(`Error requesting the URL:${requestUrl}`);
          return reject(err);
        }
        let imageUrls = HtmlParser.attrFromSelector(body, IMG_SELECTOR, ATTRIBUTE);
        imageUrls = imageUrls.map((url) => HtmlParser.addProtocol(url));
        return resolve(imageUrls);
      });
    });
  }

  static search(params) {
    return new Promise((resolve, reject) => {
      yelp.search(params).then((results) => {
        // console.log(results);
        return resolve(results.businesses);
      }).catch((err) => {
        return reject(err);
      });
    });
  }
}

module.exports = _.extend(YelpApi, {
  YELP_URL_BASE: YELP_URL_BASE,
  YELP_URL_PHOTOS: YELP_URL_PHOTOS,
  YELP_URL_FOOD: YELP_URL_FOOD,
  IMG_SELECTOR: IMG_SELECTOR,
  ATTRIBUTE: ATTRIBUTE
});