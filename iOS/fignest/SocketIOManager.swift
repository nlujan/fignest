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
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://10.95.1.219:8080")!)

    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func adduserToFig(nickname: String, figName: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
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
