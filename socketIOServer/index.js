var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);


var userList = [];
var userStatusList = [{name:"naim", status: "waiting"}, {name:"toks", status: "waiting"}]
var typingUsers = {};

app.get('/', function(req, res){
  res.send('<h1>fignest - SocketIO Server</h1>');
});


http.listen(8080, function(){
  console.log('Listening on *:8080');
});

var usernames = {};

// rooms which are currently available in chat
var rooms = ['room1','room2','room3'];

io.on('connection', function (socket) {
	console.log('a user connected');

	// when the client emits 'adduser', this listens and executes
	socket.on('adduserToFig', function(username, figRoom){
		// store the username in the socket session for this client
		socket.username = username;
		// store the room name in the socket session for this client
		socket.room = figRoom;
		// add the client's username to the global list
		usernames[username] = username;
		// send client to room 1
		socket.join('room1');
		// echo to client they've connected

		//socket.emit('updatechat', 'SERVER', 'you have connected to room1');
		var tempStatus = userStatusList;
		for (var i = 0; i < tempStatus.length) {
			if (tempStatus[i].name === username) {
				tempStatus[i].status = "ready";
			}
		}

		// echo to room 1 that a person has connected to their room
		socket.broadcast.to(figRoom).emit('updateStatus', 'SERVER', tempStatus);
		//socket.emit('updaterooms', rooms, 'room1');
	});

	// when the client emits 'sendchat', this listens and executes
	socket.on('sendchat', function (data) {
		// we tell the client to execute 'updatechat' with 2 parameters
		io.sockets.in(socket.room).emit('updatechat', socket.username, data);
	});

	socket.on('switchRoom', function(newroom){
		// leave the current room (stored in session)
		socket.leave(socket.room);
		// join new room, received as function parameter
		socket.join(newroom);
		socket.emit('updatechat', 'SERVER', 'you have connected to '+ newroom);
		// sent message to OLD room
		socket.broadcast.to(socket.room).emit('updatechat', 'SERVER', socket.username+' has left this room');
		// update socket session room title
		socket.room = newroom;
		socket.broadcast.to(newroom).emit('updatechat', 'SERVER', socket.username+' has joined this room');
		socket.emit('updaterooms', rooms, newroom);
	});

	// when the user disconnects.. perform this
	socket.on('disconnect', function(){
		// remove the username from global usernames list
		delete usernames[socket.username];
		// update list of users in chat, client-side
		io.sockets.emit('updateusers', usernames);
		// echo globally that this client has left
		socket.broadcast.emit('updatechat', 'SERVER', socket.username + ' has disconnected');
		socket.leave(socket.room);
	});
});


// io.on('connection', function(clientSocket){
//   console.log('a user connected');

//   clientSocket.on('disconnect', function(){
//     console.log('user disconnected');

//     var clientNickname;
//     for (var i=0; i<userList.length; i++) {
//       if (userList[i]["id"] == clientSocket.id) {
//         userList[i]["isConnected"] = false;
//         clientNickname = userList[i]["nickname"];
//         break;
//       }
//     }

//     delete typingUsers[clientNickname];
//     io.emit("userList", userList);
//     io.emit("userExitUpdate", clientNickname);
//     io.emit("userTypingUpdate", typingUsers);
//   });


//   clientSocket.on("exitUser", function(clientNickname){
//     for (var i=0; i<userList.length; i++) {
//       if (userList[i]["id"] == clientSocket.id) {
//         userList.splice(i, 1);
//         break;
//       }
//     }
//     io.emit("userExitUpdate", clientNickname);
//   });


//   clientSocket.on('chatMessage', function(clientNickname, message){
//     var currentDateTime = new Date().toLocaleString();
//     delete typingUsers[clientNickname];
//     io.emit("userTypingUpdate", typingUsers);
//     io.emit('newChatMessage', clientNickname, message, currentDateTime);
//   });


//   clientSocket.on("connectUser", function(clientNickname) {
//       var message = "User " + clientNickname + " was connected.";
//       console.log(message);

//       var userInfo = {};
//       var foundUser = false;
//       for (var i=0; i<userList.length; i++) {
//         if (userList[i]["nickname"] == clientNickname) {
//           userList[i]["isConnected"] = true
//           userList[i]["id"] = clientSocket.id;
//           userInfo = userList[i];
//           foundUser = true;
//           break;
//         }
//       }

//       if (!foundUser) {
//         userInfo["id"] = clientSocket.id;
//         userInfo["nickname"] = clientNickname;
//         userInfo["isConnected"] = true
//         userList.push(userInfo);
//       }

//       io.emit("userList", userList);
//       io.emit("userConnectUpdate", userInfo)
//   });




// });