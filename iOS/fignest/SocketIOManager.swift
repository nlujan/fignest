//
//  SocketIOManager.swift
//  fignest
//
//  Created by Naim on 3/13/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import SocketIOClientSwift
import SwiftyJSON

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.8:3010")!)

    override private init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func joinRoom(userId: String, eventId: String, completionHandler: (userList: JSON) -> Void) {
        
        socket.on("status") { (jsonArray, ack) -> Void in
            completionHandler(userList: JSON(jsonArray[0]))
        }
        
        socket.on("start") { (jsonArray, ack) -> Void in
            completionHandler(userList: [])
        }
        
        socket.emit("join", ["userId": userId, "eventId": eventId])
    }
    
    func setupProgressListener(completionHandler: (progressData: JSON) -> Void) {
        socket.on("progress") { (data, ack) -> Void in
            completionHandler(progressData: JSON(data))
        }
    }
    
    func sendProgress(userId: String, eventId: String, level: Float) {
        socket.emit("progress", ["userId": userId, "eventId": eventId, "level": level])
    }
    
    func gameDone(userId: String, eventId: String, completionHandler: (userList: JSON) -> Void) {
        
        socket.on("status") { (jsonArray, ack) -> Void in
            completionHandler(userList: JSON(jsonArray[0]))
        }
        
        socket.emit("done", ["userId": userId, "eventId": eventId])
    }

}
