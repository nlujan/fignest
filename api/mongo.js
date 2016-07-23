'use strict';

var MongoClient = require('mongodb').MongoClient;
var _ = require('underscore');
// var ObjectId = require('mongodb').ObjectID;
const MONGO_URL_LOCAL = 'mongodb://localhost:27017/test';
const MONGO_URL_TEST = 'mongodb://localhost:27017/testing';
// var url = process.env.MONGOLAB_URI || MONGO_URL_TEST;
var url = process.env.MONGOLAB_URI || MONGO_URL_LOCAL;
var _db;

class Mongo {
  static connect() {
    return new Promise((resolve, reject) => {
      MongoClient.connect(url, (err, db) => {
        _db = db;
        if (err) {
          console.log('Error connecting to mongo');
          reject(err);
        }
        console.log(`Connected to mongo at ${url}`);
        resolve();
      });
    });
  }

  static close() {

  }

  static db() {
    return _db;
  }
}

module.exports = _.extend(Mongo, {
  MONGO_URL_LOCAL: MONGO_URL_LOCAL,
  MONGO_URL_TEST: MONGO_URL_TEST
});