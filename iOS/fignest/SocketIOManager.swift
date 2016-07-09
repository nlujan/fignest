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
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.7.29:3010")!)

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
        
        socket.on("status") { (dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String : AnyObject]])
        }
        
        socket.on("start") { (dataArray, ack) -> Void in
            completionHandler(userList: [[:]])
        }
        
        socket.emit("join", ["userId": userId, "eventId": eventId])
        
    }
    
    
    func setupProgressListener(completionHandler: (progressData: [AnyObject]) -> Void) {
        socket.on("progress") { (data, ack) -> Void in
            completionHandler(progressData: data)
        }
    }
    
    
    func sendProgress(userId: String, eventId: String, level: Float) {
        
        socket.emit("progress", ["userId": userId, "eventId": eventId, "level": level])
    }
    
    func gameDone(userId: String, eventId: String, completionHandler: (userList: [[String: AnyObject]]) -> Void) {
        
        socket.on("status") { (dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String : AnyObject]])
        }
        
        socket.emit("done", ["userId": userId, "eventId": eventId])
        
    }
    
//    func adduserToEvent(nickname: String, figName: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
//        socket.emit("adduserToFig", nickname, figName)
//        
//        socket.on("userStatus") { ( dataArray, ack) -> Void in
//            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
//        }
//    }
//    
//    
//    func sendProgressUpdate(progress: Float, completionHandler: (progress: Float) -> Void) {
//        socket.emit("progressMade", progress)
//        
//        socket.on("updateProgress") { ( dataArray, ack) -> Void in
//            completionHandler(progress: dataArray[0] as! Float)
//        }
//    }
}

//socket.on('progress', (data) => {
//    var userId = data.userId;
//    var eventId = data.eventId;
//    var level = data.level;
//    var user = _.find(rooms[eventId], (user) => user._id.toString() === userId);
//    
//    // Broadcast to room (except client)
//    socket.broadcast.to(eventId).emit('progress', {
//        user: user,
//        level: level
//    });
//    });
