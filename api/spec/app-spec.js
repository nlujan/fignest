'use strict';

describe('API', () => {
  var request = require('request');
  var url = 'http://localhost:3010';
  var Mongo = require('../mongo');
  var db;
  var ObjectId = require('mongodb').ObjectID;
  var _ = require('underscore');

  function _user0() {
    return {
      facebook: {
        id: 'uniq0',
        email: 'uniq0@gmail.com',
        name: 'User0'
      }
    };
  }

  function _user1() {
    return {
      facebook: {
        id: 'uniq1',
        email: 'uniq10@gmail.com',
        name: 'User1'
      }
    };
  }

  function _users() {
    return [_user0(), _user1()];
  }

  function _event0() {
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

  function _event1() {
    return {
      name: 'Sample Event 1',
      location: {
        type: 'address',
        address: 'East Village NYC'
      },
      search: 'mexican',
      isOver: false
    };
  }

  function _events() {
    return [_event0(), _event1()];
  }

  beforeAll((done) => {
    Mongo.connect().then((err) => {
      db = Mongo.db();
      done();
    });
  });

  describe('GET /users', () => {
    beforeEach((done) => {
      db.collection('users').drop((err, res) => {
        db.collection('users').insertMany(_users(), (err, res) => {
          done();
        });
      });
    });

    it('returns a 200 status code', (done) => {
      request.get(`${url}/users`, (err, res, body) => {
        expect(res.statusCode).toBe(200);
        done();
      });
    });

    describe('when there are users', () => {
      it('returns an array of users', (done) => {
        request.get(`${url}/users`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(Array.isArray(response)).toBeTruthy();
          expect(response.length).toBe(_users().length);
          done();
        });
      });
    });

    describe('when there are no users', () => {
      beforeEach((done) => {
        db.collection('users').drop((err, res) => {
          done();
        });
      });

      it('returns an empty array', (done) => {
        request.get(`${url}/users`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(Array.isArray(response)).toBeTruthy();
          expect(response.length).toBe(0);
          done();
        });
      })
    });
  });

  describe('GET /usersMapById', () => {
    beforeEach((done) => {
      db.collection('users').drop((err, res) => {
        db.collection('users').insertMany(_users(), (err, res) => {
          done();
        });  
      });
    });

    it('returns a key for each user', (done) => {
      request.get(`${url}/usersMapById`, (err, res, body) => {
        var response = JSON.parse(body);
        expect(Object.keys(response).length).toBe(_users().length);
        done();
      });
    });
  });

  describe('POST /users', () => {
    beforeEach((done) => {
      db.collection('users').drop((err, res) => {
        done();
      });
    });

    it('responds with the posted user', (done) => {
      request.post({
        url: `${url}/users`,
        body: _user0(),
        json: true
      }, (err, res, body) => {
        expect(body._id).not.toBeNull();
        expect(body.displayName).toBe(_user0().facebook.name);
        expect(body.facebook.id).toBe(_user0().facebook.id);
        done();
      });
    });
    
    it('adds the user to the db', (done) => {
      request.post({
        url: `${url}/users`,
        body: _user0(),
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
        db.collection('users').insert(_user0(), (err, res) => {
          done();
        });
      });

      it('does NOT create a new user', (done) => {
        request.post({
          url: `${url}/users`,
          body: _user0(),
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

  describe('GET /users/:userId/invitations', () => {
    beforeEach((done) => {
      db.collection('users').drop((err, res) => {
        db.collection('events').drop((err, res) => {
          done();
        });
      });
    });

    describe('when the user has been invited to an event', () => {
      it('returns the invitation', (done) => {
        var user = _user0();
        var event = _event0();
        db.collection('users').insert(user, (err, res) => {
          db.collection('events').insert(_.extend(event, {
            users: [user._id]
          }), (err, res) => {
            request.get(`${url}/users/${user._id}/invitations`, (err, res, body) => {
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
        var user = _user0();
        var events = _events();
        db.collection('users').insert(user, (err, res) => {
          db.collection('events').insertMany(events.map((event) => _.extend(event, {
            users: [user._id]
          })), (err, res) => {
            request.get(`${url}/users/${user._id}/invitations`, (err, res, body) => {
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
        var user = _user0();
        db.collection('users').insert(user, (err, res) => {
          request.get(`${url}/users/${user._id}/invitations`, (err, res, body) => {
            var response = JSON.parse(body);
            expect(response.length).toBe(0);
            done();
          });
        });
      });
    });
  });

  describe('GET /events/:eventId', () => {
    beforeEach((done) => {
      db.collection('events').drop((err, res) => {
        done();
      });
    });

    describe('when the event exists', () => {
      it('returns the event', (done) => {
        var event = _event0();
        db.collection('events').insert(event, (err, res) => {
          request.get(`${url}/events/${event._id}`, (err, res, body) => {
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
        request.get(`${url}/events/${badId}`, (err, res, body) => {
          var response = JSON.parse(body);
          expect(response.indexOf(badId) > -1).toBeTruthy();
          done();
        });
      });
    });
  });

  
});