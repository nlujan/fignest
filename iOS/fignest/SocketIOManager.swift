//
//  SocketIOManager.swift
//  fignest
//
//  Created by Naim on 3/13/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.7:3010")!)

    override private init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    
    func joinRoom(userId: String, eventId: String, completionHandler: (userList: [[String: AnyObject]]) -> Void) {
        
        socket.emit("join", ["userId": userId, "eventId": eventId])
        
        socket.on("status") { (dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String : AnyObject]])
        }
        
        socket.on("start") { (dataArray, ack) -> Void in
            print("started!")
            print(dataArray)
        }
        
    }
    
    func adduserToEvent(nickname: String, figName: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("adduserToFig", nickname, figName)
        
        socket.on("userStatus") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    
    func sendProgressUpdate(progress: Float, completionHandler: (progress: Float) -> Void) {
        socket.emit("progressMade", progress)
        
        socket.on("updateProgress") { ( dataArray, ack) -> Void in
            completionHandler(progress: dataArray[0] as! Float)
        }
    }
}

//
//socket.on('join', (data) => {
//    // Race condition if 1 person joins before another is done joining
//    var userId = data.userId;
//    var eventId = data.eventId;
//    joinRoom(userId, eventId).then(() => {
//        // Add user to room and broadcast to everyone (including user)
//        socket.join(eventId);
//        io.sockets.in(eventId).emit('status', rooms[eventId]);
//        
//        // Check if we should start event
//        if (shouldStartEvent(eventId)) {
//            io.sockets.in(eventId).emit('start');
//        }
//        });
//    });
