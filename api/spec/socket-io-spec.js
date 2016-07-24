'use strict';

describe('sockets', () => {
  var Event = require('../event');
  var Mongo = require('../mongo');
  var db;
  var ObjectId = require('mongodb').ObjectID;
  var io = require('socket.io-client');
  var config = require('../config');
  var SpecHelper = require('../spec-helper');
  var _ = require('underscore');

  const HACK_WAIT_TIME = 100;
  var connection_options = {
    transports: ['websocket'],
    'force new connection': true,
    'reopen delay': 0,
    'reconnection delay': 0
  };
  var client1;
  var client2;
  var client3;
  var helper;
  var user0;
  var user1;
  var event;

  beforeAll((done) => {
    Mongo.connect().then((err) => {
      db = Mongo.db();
      done();
    });
  });

  beforeEach((done) => {
    helper = new SpecHelper();
    user0 = helper.getUser();
    user1 = helper.getUser();
    event = helper.getEvent();

    client1 = io.connect(config.LOCAL_URL, connection_options);
    client1.on('connect', () => {
      client2 = io.connect(config.LOCAL_URL, connection_options);
      client2.on('connect', () => {
        client3 = io.connect(config.LOCAL_URL, connection_options);
        client3.on('connect', () => {
          db.collection('users').insertMany([user0, user1], (err, res) => {
            db.collection('events').insert(_.extend(event, {
              users: [user0._id, user1._id]
            }), (err, res) => {
              done();
            });
          });
        });
        client3.on('error', (err) => {
          console.log(err);
          done();
        });
      });
      client2.on('error', (err) => {
        console.log(err);
        done();
      });
    });
    client1.on('error', (err) => {
      console.log(err);
      done();
    });
  });

  var helper = new SpecHelper();
  var user0 = helper.getUser();
  var user1 = helper.getUser();
  var event = helper.getEvent();

  afterEach((done) => {
    if (client1.connected) {
      client1.disconnect();
    }
    if (client2.connected) {
      client2.disconnect();
    }
    if (client3.connected) {
      client3.disconnect();
    }
    db.collection('users').drop(() => {
      db.collection('events').drop(() => {
        done();
      });
    });
  });

  it('multiple clients can connect', (done) => {
    expect(client1.connected).toBeTruthy();
    expect(client2.connected).toBeTruthy();
    expect(client3.connected).toBeTruthy();
    done();
  });



  // JOIN
  describe('joining', () => {
    describe('when the room is empty', () => {
      describe('when a user joins', () => {
        it('broadcasts to the user', (done) => {
          client1.emit('join', { userId: user0._id, eventId: event._id });
          client1.on('status', (res) => {
            var usersInRoom = _.map(res, '_id');
            var statusesInRoom = _.map(res, 'status');
            expect(usersInRoom).toContain(user0._id.toString());
            expect(usersInRoom).toContain(user1._id.toString());
            expect(statusesInRoom).toContain('ready');
            expect(statusesInRoom).toContain('waiting');
            done();
          });
        });
      });
    });

    describe('when 1 person is in the room (2 person event)', () => {
      beforeEach((done) => {
        client1.emit('join', { userId: user0._id, eventId: event._id });
        // Hack so that the event listeners don't respond to the response from this event.
        setTimeout(() => { done() }, HACK_WAIT_TIME);
      });

      describe('and the second person joins', () => {
        beforeEach((done) => {
          client2.emit('join', { userId: user1._id, eventId: event._id });
          done();
        });

        it('broadcasts the join to the first user', (done) => {
          client1.on('status', (res) => {
            var usersInRoom = _.map(res, '_id');
            var statusesInRoom = _.map(res, 'status');
            expect(usersInRoom).toContain(user0._id.toString());
            expect(usersInRoom).toContain(user1._id.toString());
            expect(_.isEqual(statusesInRoom, ['ready', 'ready'])).toBeTruthy();
            done();
          });
        });

        it('broadcasts the join to the second user', (done) => {
          client2.on('status', (res) => {
            var usersInRoom = _.map(res, '_id');
            var statusesInRoom = _.map(res, 'status');
            expect(usersInRoom).toContain(user0._id.toString());
            expect(usersInRoom).toContain(user1._id.toString());
            expect(_.isEqual(statusesInRoom, ['ready', 'ready'])).toBeTruthy();
            done();
          });
        });

        it('broadcasts the start to the first user', (done) => {
          client1.on('start', () => {
            done();
          });
        });

        it('broadcasts the start to the second user', (done) => {
          client2.on('start', () => {
            done();
          });
        });

        describe('and there is a 3rd person in a different room', () => {
          beforeEach((done) => {
            client3.emit('join', { 
              userId: new ObjectId().toString(), 
              eventId: new ObjectId().toString()
            });
            done();
          });

          it('does not broadcast anything to the 3rd user', (done) => {
            // Hack for didNotReceive;
            var receivedNotification = false;
            client3.on('status', () => {
              receivedNotification = true;
            });
            client3.on('start', () => {
              receivedNotification = true;
            });
            setTimeout(() => {
              if (!receivedNotification) {
                done();
              }
            }, HACK_WAIT_TIME);
          });
        });
      });
    });
  });



  // PROGRESS
  describe('progress', () => {
    describe('when there are 2 people in the room', () => {
      var level = 2;
      beforeEach((done) => {
        // change such that this is testing progress independently
        client1.emit('join', { userId: user0._id, eventId: event._id });
        client2.emit('join', { userId: user1._id, eventId: event._id });
        // Hack so that the event listeners don't respond to the response from this event.
        setTimeout(() => { done() }, HACK_WAIT_TIME);
      });

      describe('when the first user progresses', () => {
        beforeEach((done) => {
          client1.emit('progress', {
            userId: user0._id,
            eventId: event._id,
            level: level
          });
          done();
        });

        it('does not notify the first (current) user', (done) => {
          // Hack for didNotReceive;
          var receivedNotification = false;
          client1.on('progress', (res) => {
            receivedNotification = true;
          });
          setTimeout(() => {
            if (!receivedNotification) {
              done();
            }
          }, HACK_WAIT_TIME);
        });

        it('notifies the second user (progress)', (done) => {
          client2.on('progress', (res) => {
            expect(res._id).toBe(user0._id.toString());
            expect(res.level).toBe(level);
            done();
          });
        });

        it('notifies the first user (progressAll)', (done) => {
          client1.on('progressAll', (res) => {
            var usersInRoom = _.map(res, '_id');
            expect(usersInRoom).toContain(user0._id.toString());
            expect(usersInRoom).toContain(user1._id.toString());
            var userProgressed = _.find(res, (r) => r._id === user0._id.toString() );
            expect(userProgressed.level).toBe(level);
            done();
          });
        });

        it('notifies the second user (progressAll)', (done) => {
          client2.on('progressAll', (res) => {
            var usersInRoom = _.map(res, '_id');
            expect(usersInRoom).toContain(user0._id.toString());
            expect(usersInRoom).toContain(user1._id.toString());
            var userProgressed = _.find(res, (r) => r._id === user0._id.toString() );
            expect(userProgressed.level).toBe(level);
            done();
          });
        });
      });
    });
  });



  // DONE
  describe('done', () => {
    describe('when there are 2 people in the room', () => {
      beforeEach((done) => {
        // change such that this is testing progress independently
        client1.emit('join', { userId: user0._id, eventId: event._id });
        client2.emit('join', { userId: user1._id, eventId: event._id });
        // Hack so that the event listeners don't respond to the response from this event.
        setTimeout(() => { done() }, HACK_WAIT_TIME);
      });

      describe('when no one has finished', () => {
        describe('when one person finishes', () => {
          beforeEach((done) => {
            client1.emit('done', { userId: user0._id, eventId: event._id });
            done();  
          });

          it('broadcasts everyone\'s progressAll to the finished user', (done) => {
            client1.on('progressAll', (res) => {
              var usersInRoom = _.map(res, '_id');
              var statusesInRoom = _.map(res, 'status');
              expect(usersInRoom).toContain(user0._id.toString());
              expect(usersInRoom).toContain(user1._id.toString());
              expect(statusesInRoom).toContain('done');
              expect(_.contains(statusesInRoom, 'ready') || _.contains(statusesInRoom, 'waiting')).toBeTruthy();
              done();
            });
          });

          it('broadcasts everyone\'s progressAll to the other user', (done) => {
            client2.on('progressAll', (res) => {
              var usersInRoom = _.map(res, '_id');
              var statusesInRoom = _.map(res, 'status');
              expect(usersInRoom).toContain(user0._id.toString());
              expect(usersInRoom).toContain(user1._id.toString());
              expect(statusesInRoom).toContain('done');
              expect(_.contains(statusesInRoom, 'ready') || _.contains(statusesInRoom, 'waiting')).toBeTruthy();
              done();
            });
          });    
        });
      });

      describe('when one person has finished', () => {
        beforeEach((done) => {
          client1.emit('done', { userId: user0._id, eventId: event._id });
          // Hack so that the event listeners don't respond to the response from this event.
          setTimeout(() => { done() }, HACK_WAIT_TIME);
        });

        describe('when the other person finishes', () => {
          beforeEach((done) => {
            client2.emit('done', { userId: user1._id, eventId: event._id });
            done();  
          });

          it('broadcasts everyone\'s progressAll to the first user', (done) => {
            client1.on('progressAll', (res) => {
              var usersInRoom = _.map(res, '_id');
              var statusesInRoom = _.map(res, 'status');
              expect(usersInRoom).toContain(user0._id.toString());
              expect(usersInRoom).toContain(user1._id.toString());
              expect(statusesInRoom).toContain('done');
              expect(statusesInRoom).not.toContain('ready');
              expect(statusesInRoom).not.toContain('waiting');
              done();
            });
          });

          it('broadcasts everyone\'s progressAll to the second user', (done) => {
            client2.on('progressAll', (res) => {
              var usersInRoom = _.map(res, '_id');
              var statusesInRoom = _.map(res, 'status');
              expect(usersInRoom).toContain(user0._id.toString());
              expect(usersInRoom).toContain(user1._id.toString());
              expect(statusesInRoom).toContain('done');
              expect(statusesInRoom).not.toContain('ready');
              expect(statusesInRoom).not.toContain('waiting');
              done();
            });
          });

          it('broadcasts event finish to the first user', (done) => {
            client1.on('finish', (res) => {
              done();
            });
          });

          it('broadcasts event finish to the second user', (done) => {
            client2.on('finish', (res) => {
              done();
            });
          });
        });
      });
    });
  });
});