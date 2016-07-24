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
    
    func setupStatusListener(completionHandler: (userList: JSON) -> Void) {
        socket.on("status") { (jsonArray, ack) -> Void in
            completionHandler(userList: JSON(jsonArray[0]))
        }
    }
    
    func setupStartListener(completionHandler: () -> Void) {
        socket.on("start") { (jsonArray, ack) -> Void in
            completionHandler()
        }
    }
    
    func joinRoom(userId: String, eventId: String) {
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
    
    func emitDone(userId: String, eventId: String) {
        socket.emit("done", ["userId": userId, "eventId": eventId])
    }
    
    func setupProgressAllListener(completionHandler: (userList: JSON) -> Void) {
        socket.on("progressAll") { (jsonArray, ack) -> Void in
            completionHandler(userList: JSON(jsonArray[0]))
        }
    }
    
    func setupFinishListener(completionHandler: () -> Void) {
        socket.on("finish") { (jsonArray, ack) -> Void in
            completionHandler()
        }
    }
}
