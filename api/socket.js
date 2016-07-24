'use strict';

var _ = require('underscore');
var SocketRoom = require('./socket-room');

const EMIT_STATUS = 'status';
const EMIT_START = 'start';
const EMIT_PROGRESS = 'progress';
const EMIT_PROGRESS_ALL = 'progressAll';
const EMIT_FINISH = 'finish';
const ON_DONE = 'done';
const ON_JOIN = 'join';
const ON_PROGRESS = 'progress';

class Socket {
  constructor(socket, io, rooms) {
    this.socket = socket;
    this.io = io;
    this.rooms = rooms;
  }

  addListeners() {
    this.socket.on('join', this.joinCallback.bind(this));
    this.socket.on('progress', this.progressCallback.bind(this));
    this.socket.on('done', this.doneCallback.bind(this));
  }

  broadcast(message, data, roomId, includeClient) {
    this.socket.broadcast.to(roomId).emit(message, data);
  }

  broadcastAll(message, data, roomId) {
    this.io.sockets.in(roomId).emit(message, data);
  }

  joinCallback(data) {
    var userId = data.userId;
    var eventId = data.eventId;
    this.findOrCreateRoom(eventId).then((room) => {
      room.markUserReady(userId);
      this.socket.join(room.roomId);
      this.broadcastAll(EMIT_STATUS, room.users, room.roomId);
      if (room.allUsersReady()) {
        this.broadcastAll(EMIT_START, null, room.roomId);
      }
    });
  }

  progressCallback(data) {
    var userId = data.userId;
    var eventId = data.eventId;
    var level = data.level;
    var message = data.message;
    var room = this.rooms[eventId];
    room.addUserData(userId, { level: level, message: message });
    var user = room.getUserFromId(userId);
    this.broadcast(EMIT_PROGRESS, user, room.roomId);
    this.broadcastAll(EMIT_PROGRESS_ALL, room.users, room.roomId);
  }

  doneCallback(data) {
    var userId = data.userId;
    var eventId = data.eventId;
    var room = this.rooms[eventId];
    room.markUserDone(userId);
    this.broadcastAll(EMIT_PROGRESS_ALL, room.users, room.roomId);
    if (room.allUsersDone()) {
      this.broadcastAll(EMIT_FINISH, null, room.roomId);
      delete this.rooms[room.roomId];
    }
  }

  findOrCreateRoom(roomId) {
    return new Promise((resolve, reject) => {
      var room = this.rooms[roomId];
      if (room == null || room.length == 0) {
        SocketRoom.create(roomId).then((r) => {
          this.rooms[roomId] = r;
          return resolve(r);
        }).catch((err) => {
          return reject(err);
        });
      } else {
        return resolve(room);  
      }
    });
  }

}

module.exports = _.extend(Socket, {
  EMIT_STATUS: EMIT_STATUS,
  EMIT_START: EMIT_START,
  EMIT_PROGRESS: EMIT_PROGRESS,
  EMIT_PROGRESS_ALL: EMIT_PROGRESS_ALL,
  EMIT_FINISH: EMIT_FINISH,
  ON_DONE: ON_DONE,
  ON_JOIN: ON_JOIN,
  ON_PROGRESS: ON_PROGRESS,
});