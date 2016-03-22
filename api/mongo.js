'use strict';

var MongoClient = require('mongodb').MongoClient;
// var ObjectId = require('mongodb').ObjectID;
// var url = 'mongodb://localhost:27017/test';
var url = process.env.MONGOLAB_URI;
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
        console.log("Connected to mongo...");
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

module.exports = Mongo;