'use strict';

var _ = require('underscore');

class Util {
	static milesToMeters(miles) {
		return miles * 1609.344;
	}

  static ensureLength(collection, len) {
    while (collection.length < len) {
      collection.push(_.sample(collection));
    }
    return collection;
  }
}

module.exports = Util;