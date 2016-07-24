'use strict';

var _ = require('underscore');
var ObjectId = require('mongodb').ObjectID;

class SpecHelper {
  constructor() {

  }

  getUser() {
    return {
      facebook: {
        id: `${Math.random()}`,
        email: 'uniq0@gmail.com',
        name: 'User0'
      }
    };
  }

  getUsers(size) {
    return _.map(_.range(size), (i) => this.getUser() );
  }

  getEvent() {
    return {
      name: 'Sample Event 0',
      location: {
        type: 'address',
        address: 'East Village NYC'
      },
      search: 'bbq',
      isOver: false
    };
  }

  getEvents(size) {
    return _.map(_.range(size), (i) => this.getEvent() );
  }

  getPlaceFromEventId(eventId) {
    return _.extend(this.getPlace(), { event: eventId });
  }

  getActionFromEventId(eventId) {
    return _.extend(this.getAction(), { event: eventId });
  }

  getActionFromEventIdAndWinningPlaceId(eventId, winningPlaceId) {
    var action = _.extend(this.getAction(), { event: eventId });
    action.selections[1].place = winningPlaceId;
    return action;
  }

  // PRIVATE

  getPlace() {
    return { 
      _id: new ObjectId(),
      yelpId: 'graso-grill-new-york',
      event: new ObjectId(),
      name: 'Graso Grill',
      rating: 4,
      urls: {
        web: 'http://www.yelp.com/biz/graso-grill-new-york?utm_campaign=yelp_api&utm_medium=api_v2_search&utm_source=pluHcmRoKd3ypMFJ396lSA',
        mobile: 'http://m.yelp.com/biz/graso-grill-new-york?utm_campaign=yelp_api&utm_medium=api_v2_search&utm_source=pluHcmRoKd3ypMFJ396lSA' 
      },
      images: [
        'https://s3-media1.fl.yelpcdn.com/bphoto/2o_is0mtfLBudBgPHGO51w/258s.jpg',
        'https://s3-media4.fl.yelpcdn.com/bphoto/kvCDM0GJmorZ4paCpobN_A/258s.jpg',
        'https://s3-media1.fl.yelpcdn.com/bphoto/ftOxs-HZo2n3JNhwwKErdA/258s.jpg',
        'https://s3-media1.fl.yelpcdn.com/bphoto/W8PNTXUCp_1KwKeMptuCAA/258s.jpg',
        'https://s3-media2.fl.yelpcdn.com/bphoto/9c5-a_qiQadpM0bFWrO3dQ/258s.jpg',
        'https://s3-media1.fl.yelpcdn.com/bphoto/dIWFErYeanCIoNQr7Zb2tw/258s.jpg' 
      ],
      phone: '2127594848',
      location: {
        cross_streets: '5th Ave & Madison Ave',
        city: 'New York',
        geo_accuracy: 9.5,
        postal_code: '10017',
        country_code: 'US',
        state_code: 'NY' 
      }
    }
  }

  getAction() {
    return {
      user: new ObjectId(),
      event: new ObjectId(),
      selections: [{
        image: 'url0',
        place: new ObjectId(),
        isSelected: false
      }, {
        image: 'url1',
        place: new ObjectId(),
        isSelected: true
      }, {
        image: 'url2',
        place: new ObjectId(),
        isSelected: false
      }]
    }
  }
}

module.exports = SpecHelper;