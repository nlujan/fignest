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

  consumer_key: process.env.YELP_CONSUMER_KEY || 'K_C4kW5f7TDvoq7bB_4Z0w',
  consumer_secret: process.env.YELP_CONSUMER_SECRET || 'Wiijly9VWQAkWFWAY-Q4cn4T150',
  token: process.env.YELP_TOKEN || 'TsLL78ojlMFKoaD_haODwDrIwb9AUDl5',
  token_secret: process.env.YELP_TOKEN_SECRET || '9JM22dL0dlRCX_VyhItQscTU870'

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