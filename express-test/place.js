'use strict';

class Place {
  constructor(num) {
    this.num = num;
  }

  asJson() {

  }

  static fromYelpId(num) {
    // yelp
    return new this(num);
  }
}

module.exports = Place;