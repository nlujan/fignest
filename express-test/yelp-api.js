'use strict';

var request = require('request');
var HtmlParser = require('./html-parser');

const yelpUrl = {
  base: 'https://www.yelp.com',
  photos: 'biz_photos',
  food: '?tab=food'
}
const start = '';
const imgSelector = '[data-photo-id] .photo-box-img';
const attribute = 'src';

class YelpApi {
  static getImages(id) {
    return new Promise((resolve, reject) => {
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
}

module.exports = YelpApi;