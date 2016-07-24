'use strict';

describe('API', () => {
  var request = require('request');
  var Event = require('../event');
  var Place = require('../place');
  var Mongo = require('../mongo');
  var config = require('../config');
  var db;
  var ObjectId = require('mongodb').ObjectID;
  var _ = require('underscore');
  var SpecHelper = require('../spec-helper');
  var helper = new SpecHelper();

  beforeAll((done) => {
    Mongo.connect().then((err) => {
      db = Mongo.db();
      done();
    });
  });

  beforeEach((done) => {
    db.collection('events').drop(() => {
      db.collection('actions').drop(() => {
        db.collection('places').drop(() => {
          db.collection('users').drop(() => {
            done();
          });
        });
      });
    });
  });



  // GET /users
  describe('GET /users', () => {

    it('returns a 200 status code', (done) => {
      request.get(`${config.LOCAL_URL}/users`, (err, res, body) => {
        expect(res.statusCode).toBe(200);
        done();
      });
    });

    describe('when there are users', () => {
      var users = helper.getUsers(2);

      beforeEach((done) => {
        db.collection('users').insertMany(users, (err, res) => {
          done();
        });
      });

      it('returns an array of users', (done) => {
        request.get(`${config.LOCAL_URL}/users`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(_.isArray(response)).toBeTruthy();
          expect(response.length).toBe(users.length);
          done();
        });
      });
    });

    describe('when there are no users', () => {

      it('returns an empty array', (done) => {
        request.get(`${config.LOCAL_URL}/users`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(_.isArray(response)).toBeTruthy();
          expect(response.length).toBe(0);
          done();
        });
      })
    });
  });



  // GET /usersMapById
  describe('GET /usersMapById', () => {
    var users = helper.getUsers(2);

    beforeEach((done) => {
      db.collection('users').insertMany(users, (err, res) => {
        done();
      });
    });

    it('returns a key for each user', (done) => {
      request.get(`${config.LOCAL_URL}/usersMapById`, (err, res, body) => {
        var response = JSON.parse(body);
        expect(_.keys(response).length).toBe(users.length);
        done();
      });
    });
  });



  // POST /users
  describe('POST /users', () => {
    var user0 = helper.getUser();

    it('responds with the posted user', (done) => {
      request.post({
        url: `${config.LOCAL_URL}/users`,
        body: user0,
        json: true
      }, (err, res, body) => {
        expect(body._id).not.toBeNull();
        expect(body.displayName).toBe(user0.facebook.name);
        expect(body.facebook.id).toBe(user0.facebook.id);
        done();
      });
    });
    
    it('adds the user to the db', (done) => {
      request.post({
        url: `${config.LOCAL_URL}/users`,
        body: user0,
        json: true
      }, (err, res, body) => {
        db.collection('users').findOne({ _id: ObjectId(body._id) }, (err, res) => {
          expect(res).not.toBeNull();
          done();
        });
      });
    });

    describe('if the user is already in the db', () => {
      beforeEach((done) => {
        db.collection('users').insert(user0, (err, res) => {
          done();
        });
      });

      it('does NOT create a new user', (done) => {
        request.post({
          url: `${config.LOCAL_URL}/users`,
          body: user0,
          json: true
        }, (err, res, body) => {
          var cursor = db.collection('users').find({ _id: ObjectId(body._id) });
          cursor.toArray((err, docs) => {
            expect(docs.length).toBe(1);
            done();
          });
        });
      });
    });
  });



  // GET /users/:userId/invitations
  describe('GET /users/:userId/invitations', () => {

    describe('when the user has been invited to an event', () => {
      it('returns the invitation', (done) => {
        var user = helper.getUser();
        var event = helper.getEvent();
        db.collection('users').insert(user, (err, res) => {
          db.collection('events').insert(_.extend(event, {
            users: [user._id]
          }), (err, res) => {
            request.get(`${config.LOCAL_URL}/users/${user._id}/invitations`, (err, res, body) => {
              var response = JSON.parse(body);
              expect(response.length).toBe(1);
              expect(response[0]._id).toBe(event._id.toString());
              done();
            });
          });
        });
      });
    });

    describe('when the user has been invited to multiple events', () => {
      it('returns multiple invitations', (done) => {
        var user = helper.getUser();
        var events = helper.getEvents(2);
        db.collection('users').insert(user, (err, res) => {
          db.collection('events').insertMany(events.map((event) => _.extend(event, {
            users: [user._id]
          })), (err, res) => {
            request.get(`${config.LOCAL_URL}/users/${user._id}/invitations`, (err, res, body) => {
              var response = JSON.parse(body);
              expect(response.length).toBe(events.length);
              done();
            });
          });
        });
      });
    });

    describe('when the user has NOT been invited to any events', () => {
      it('does not return any invitations', (done) => {
        var user = helper.getUser();
        db.collection('users').insert(user, (err, res) => {
          request.get(`${config.LOCAL_URL}/users/${user._id}/invitations`, (err, res, body) => {
            var response = JSON.parse(body);
            expect(response.length).toBe(0);
            done();
          });
        });
      });
    });
  });



  // GET /events/:eventId
  describe('GET /events/:eventId', () => {

    describe('when the event exists', () => {
      it('returns the event', (done) => {
        var event = helper.getEvent();
        db.collection('events').insert(event, (err, res) => {
          request.get(`${config.LOCAL_URL}/events/${event._id}`, (err, res, body) => {
            var response = JSON.parse(body);
            expect(response._id).toBe(event._id.toString());
            expect(response.name).toBe(event.name);
            done();
          });
        });
      });
    });

    describe('when the event does NOT exist', () => {
      it('returns a descriptive error message', (done) => {
        var badId = '571d451b8c9add4a689457e4';
        request.get(`${config.LOCAL_URL}/events/${badId}`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(response.indexOf(badId) > -1).toBeTruthy();
          done();
        });
      });
    });
  });



  // POST /events
  describe('POST /events', () => {
    var event = helper.getEvent();

    it('responds with the posted event', (done) => {
      request.post({
        url: `${config.LOCAL_URL}/events`,
        body: event,
        json: true
      }, (err, res, body) => {
        expect(body._id).not.toBeNull();
        expect(body.name).toBe(event.name);
        expect(body.search).toBe(event.search);
        expect(_.isNumber(body.location.radius)).toBeTruthy();
        done();
      });
    });
    
    it('adds the event to the db', (done) => {
      request.post({
        url: `${config.LOCAL_URL}/events`,
        body: event,
        json: true
      }, (err, res, body) => {
        db.collection('events').findOne({ _id: ObjectId(body._id) }, (err, res) => {
          expect(res).not.toBeNull();
          done();
        });
      });
    });
  });




  // GET /events/:eventId/places
  describe('GET /events/:eventId/places', () => {

    describe('when the event does not have places yet', () => {
      it('creates and returns places', (done) => {
        var event = _.extend(helper.getEvent(), { limit: Event.EVENT_LIMIT_DEFAULT });
        db.collection('events').insert(event, () => {
          request.get(`${config.LOCAL_URL}/events/${event._id}/places`, (err, res, body) => {
            var response = JSON.parse(body);
            expect(response.length).toBe(Event.EVENT_LIMIT_DEFAULT);
            _.each(response, (r) => {
              expect(r.images.length).toBe(Place.NUM_IMAGES_PER_PLACE);
              expect(r.event).toBe(event._id.toString());
            });
            done();
          });
        });
      });
    });

    describe('when the event already has places', () => {
      it('returns the current places', (done) => {
        var event = _.extend(helper.getEvent(), { limit: Event.EVENT_LIMIT_DEFAULT });
        db.collection('events').insert(event, () => {
          request.get(`${config.LOCAL_URL}/events/${event._id}/places`, (err, res, body) => {
            var response = JSON.parse(body);
            var placeIds = _.map(response, '_id');
            request.get(`${config.LOCAL_URL}/events/${event._id}/places`, (err, res, body) => {
              var placesNew = JSON.parse(body);
              var placesNewIds = _.map(placesNew, '_id');
              expect(_.isEqual(_.sortBy(placeIds), _.sortBy(placesNewIds))).toBeTruthy();
              done();
            });
          });
        });
      });
    });
  });



  // GET /events/:eventId/solution
  describe('GET /events/:eventId/solution', () => {
    var eventPersist;
    var placePersist;

    describe('when there are no actions', () => {
      it('says there are no actions', (done) => {
        var event = helper.getEvent();
        db.collection('events').insert(event, () => {
          request.get(`${config.LOCAL_URL}/events/${event._id}/solution`, (err, res, body) => {
            expect(body.indexOf('no actions') > -1).toBeTruthy();
            done();
          });
        });
      });
    });

    describe('when there are actions', () => {
      beforeEach((done) => {
        var event = helper.getEvent();
        db.collection('events').insert(event, () => {
          eventPersist = event;        
          var place = helper.getPlaceFromEventId(event._id);
          db.collection('places').insert(place, () => {
            placePersist = place;
            var action = helper.getActionFromEventIdAndWinningPlaceId(event._id, place._id);
            db.collection('actions').insert(action, () => {
              done();
            });
          });          
        });
      });

      describe('when the event does not yet have a solution', () => {
        it('returns the place with the highest selections', (done) => {
          request.get(`${config.LOCAL_URL}/events/${eventPersist._id}/solution`, (err, res, body) => {
            var place = JSON.parse(body);
            expect(place._id).toBe(placePersist._id.toString());
            expect(place.yelpId).not.toBeNull();
            expect(place.name).not.toBeNull();
            expect(place.urls.web).not.toBeNull();
            expect(place.urls.mobile).not.toBeNull();
            done();
          });
        });
      });

      describe('when the event already has a solution', () => {
        it('returns the current solution', (done) => {
          request.get(`${config.LOCAL_URL}/events/${eventPersist._id}/solution`, (err, res, body) => {
            var place = JSON.parse(body);
            request.get(`${config.LOCAL_URL}/events/${eventPersist._id}/solution`, (err, res, body) => {
              var placeNew = JSON.parse(body);
              expect(placeNew._id).toBe(placePersist._id.toString());
              expect(_.isEqual(place, placeNew)).toBeTruthy();
              done();
            });
          });
        });
      });
    });
  });



  // POST /events/:eventId/actions
  describe('POST /events/:eventid/actions', () => {

    it('responds with the posted action', (done) => {
      var event = helper.getEvent();
      db.collection('events').insert(event, () => {
        var action = helper.getActionFromEventId(event._id);
        request.post({
          url: `${config.LOCAL_URL}/events/${event._id}/actions`,
          body: action,
          json: true
        }, (err, res, body) => {
          expect(body._id).not.toBeNull();
          expect(body.event).toBe(event._id.toString());
          expect(body.user).not.toBeNull();
          expect(body.selections.length).toBe(action.selections.length);
          done();
        });
      });
    });

    it('adds the action to the db', (done) => {
      var event = helper.getEvent();
      db.collection('events').insert(event, () => {
        var action = helper.getActionFromEventId(event._id);
        request.post({
          url: `${config.LOCAL_URL}/events/${event._id}/actions`,
          body: action,
          json: true
        }, (err, res, body) => {
          db.collection('actions').findOne({ _id: ObjectId(body._id) }, (err, res) => {
            expect(res).not.toBeNull();
            expect(res.event.toString()).toBe(event._id.toString());
            done();
          });
        });
      });
    });
  });
  
});