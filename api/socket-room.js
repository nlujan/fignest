'use strict';

var Event = require('./event');
var _ = require('underscore');

const STATUS_WAITING = 'waiting';
const STATUS_READY = 'ready';
const STATUS_DONE = 'done';

class SocketRoom {
  constructor(roomId, users) {
    this.roomId = roomId;
    this.users = users;
  }

  allUsersReady() {
    return _.every(this.users, (u) => u.status === STATUS_READY);
  }

  allUsersDone() {
    return _.every(this.users, (u) => u.status === STATUS_DONE);
  }

  markUserReady(userId) {
    var user = this.getUserFromId(userId);
    user.status = STATUS_READY;
  }

  markUserDone(userId) {
    var user = this.getUserFromId(userId);
    user.status = STATUS_DONE;
  }

  addUserData(userId, data) {
    var user = this.getUserFromId(userId);
    if (data.message != null) {
      user.message = data.message;
      user.hasMessage = true;
    } else {
      user.level = data.level;
      user.hasMessage = false;
      delete user.message;
    }
  }

  getUserFromId(userId) {
    var user = _.find(this.users, (u) => u._id.toString() === userId);
    if (user == null) {
      throw new Error(`user with id: ${userId} is not in room: ${this.roomId}`);
    }
    return user;
  }

  static create(roomId) {
    return new Promise((resolve, reject) => {
      Event.fromId(roomId).then((event) => {
        return event.getUsers();
      }).then((users) => {
        users = _.map(users, (u) => _.extend(u, { status: STATUS_WAITING }));
        return resolve(new this(roomId, users));
      }).catch((err) => {
        return reject(err);
      });
    });
  }
}

module.exports = _.extend(SocketRoom, {
  STATUS_WAITING: STATUS_WAITING,
  STATUS_READY: STATUS_READY,
  STATUS_DONE: STATUS_DONE
});








