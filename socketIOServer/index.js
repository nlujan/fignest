var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

var userList = [];
var typingUsers = {};

app.get('/', function(req, res){
  res.send('<h1>FignestPoop - SocketIO Server</h1>');
});


http.listen(8080, function(){
  console.log('Listening on *:8080');
});


var rooms = {
  // eventId0: [user0, user1, ...],
  // eventId1: ...
};
const statusReady = 'ready';
const statusWaiting = 'waiting';
const statusDone = 'done';
// status start progress constants

io.on('connection', (socket) => {
  console.log('Client connected to socket');

  socket.on('join', (data) => {
    // Race condition if 1 person joins before another is done joining
    var userId = data.userId;
    var eventId = data.eventId;
    joinRoom(userId, eventId).then(() => {
      // Add user to room and broadcast to everyone (including user)
      socket.join(eventId);
      io.sockets.in(eventId).emit('status', rooms[eventId]);

      // Check if we should start event
      if (shouldStartEvent(eventId)) {
        io.sockets.in(eventId).emit('start');
      }
    });
  });

  socket.on('progress', (data) => {
    var userId = data.userId;
    var eventId = data.eventId;
    var level = data.level;
    var user = _.find(rooms[eventId], (user) => user._id.toString() === userId);

    // Broadcast to room (except client)
    socket.broadcast.to(eventId).emit('progress', {
      user: user,
      level: level
    });
  });

  socket.on('done', (data) => {
    var userId = data.userId;
    var eventId = data.eventId;
    var user = _.find(rooms[eventId], (user) => user._id.toString() === userId);
    user.status = statusDone;
    io.sockets.in(eventId).emit('status', rooms[eventId]);

    // Check if we should finish event
    if (shouldFinishEvent(eventId)) {
      io.sockets.in(eventId).emit('finish');

      // And clean the room
      delete rooms[eventId];
    }
  });

  function shouldStartEvent(eventId) {
    return _.every(rooms[eventId], (user) => user.status === statusReady);
  }

  function shouldFinishEvent(eventId) {
    return _.every(rooms[eventId], (user) => user.status === statusDone);
  }

  function roomExists(eventId) {
    return rooms[eventId] && rooms[eventId].length > 0;
  }

  function joinRoom(userId, roomId) {
    return new Promise((resolve, reject) => {
      if (!roomExists(roomId)) { // Room doesn't exist
        Event.fromId(roomId).then((event) => {
          return event.getUsers();
        }).then((users) => {
          // Map users to include status either "ready" or "waiting"
          rooms[roomId] = users.map((user) => {
            return _.extend(user, {
              status: (user._id.toString() === userId) ? statusReady : statusWaiting
            });
          });
          resolve();
        });
      } else { // Room already exists
        var users = rooms[roomId];
        var currentUser = _.find(users, (user) => user._id.toString() === userId );
        currentUser.status = statusReady;
        resolve();
      }
    });
  }

});

