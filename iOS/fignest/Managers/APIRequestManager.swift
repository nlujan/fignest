//
//  APIRequestHandler.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct APIRequestManager {
    
    private let apiURL: String = "https://1aaa00e4.ngrok.io"
    
    
    func getAllUsers(callback: (jsonArray: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/users")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonArray: json)
                case .Failure(let error):
                    print("getAllUsers request failed with error: \(error)")
                }
        }
    }
    
    func addUser(name: String, fbID: String, email: String,  callback: (jsonDict: JSON) -> Void) {
        
        let parameters = [
            "facebook": [
                "name": name,
                "id": fbID,
                "email": email
            ]
        ]
        
        Alamofire.request(.POST,  "\(apiURL)/users", parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonDict: json)
                case .Failure(let error):
                    print("addUser request failed with error: \(error)")
                }
        }
    }
    
    func getUserInvitations(userID: String,  callback: (jsonArray: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/users/\(userID)/invitations")
            .validate()
            .responseJSON { response in
            switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonArray: json)
                case .Failure(let error):
                    print("getUserInvitations request failed with error: \(error)")
            }
        }
    }
    
    func getEvent(eventID: String, callback: (jsonDict: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonDict: json)
                case .Failure(let error):
                    print("getEvent request failed with error: \(error)")
                }
        }
    }
    
    func createEvent(name: String, address: String, users: [String], search: String, callback: (jsonDict: JSON) -> Void) {
        
        let parameters: [String : AnyObject] = [
            "name": name,
            "location": [
                "type": "address",
                "address": address
            ],
            "users": users,
            "search": search
        ]
        
        Alamofire.request(.POST, "\(apiURL)/events/", parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonDict: json)
                case .Failure(let error):
                    print("createEvent request failed with error: \(error)")
                }
        }
    }
    
    func getEventPlaces(eventID: String, callback: (jsonArray: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/places")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonArray: json)
                case .Failure(let error):
                    print("getEventPlaces request failed with error: \(error)")
                }
        }
    }
    
    func getEventSolution(eventID: String, callback: (jsonDict: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/solution")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    //print("JSON: \(JSON)")
                    let json = JSON(data)
                    callback(jsonDict: json)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func postEventAction(userID: String, eventID: String, selections: [NSDictionary],  callback: (jsonDict: NSDictionary) -> Void) {
        
        let parameters: [String: AnyObject] = [
            "user": userID,
            "event": eventID,
            "selections": selections
        ]
        
        Alamofire.request(.POST,  "\(apiURL)/events/\(eventID)/actions", parameters: parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(jsonDict: JSON as! NSDictionary)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func getUsersMapById(callback: (jsonDict: JSON) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/usersMapById")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    //print("JSON: \(JSON)")
                    let json = JSON(value)
                    callback(jsonDict: json)
                    //callback(jsonDict: JSON as! NSDictionary)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
}
