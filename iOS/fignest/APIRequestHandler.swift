//
//  APIRequestHandler.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit
import Alamofire

struct APIRequestHandler {
    
    private let apiURL: String = "https://22efece1.ngrok.io"
    
    
    /**
     Just testing documentation using Markdown
     - returns: Bool
     - parameter name: Name of the user
     - parameter fbID: String
     - parameter email: asd
     - parameter callback: function to be called after success
     - Throws: error lists
     */
    
    func getAllUsers(callback: (dataArray: NSArray) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/users")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataArray: JSON as! NSArray)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func addUserToDatabase(name: String, fbID: String, email: String,  callback: (dataDict: NSDictionary) -> Void) {
        
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
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataDict: JSON as! NSDictionary)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func getUserInvitations(userID: String,  callback: (dataArray: NSArray) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/users/\(userID)/invitations")
            .validate()
            .responseJSON { response in
            switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataArray: JSON as! NSArray)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
            }
        }
    }
    
    func getEvent(eventID: String, callback: (dataDict: NSDictionary) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataDict: JSON as! NSDictionary)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func createNewEvent(name: String, address: String, users: [String], search: String, callback: (dataDict: NSDictionary) -> Void) {
        
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
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataDict: JSON as! NSDictionary)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func getEventPlaces(eventID: String, callback: (dataArray: NSArray) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/places")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataArray: JSON as! NSArray)
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }
    
    func getEventSolution(eventID: String, callback: (dataDict: NSDictionary) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/events/\(eventID)/solution")
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let JSON):
                    //print("JSON: \(JSON)")
                    callback(dataDict: JSON as! NSDictionary)
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
    
    func getUsersMapById(callback: (jsonDict: NSDictionary) -> Void) {
        
        Alamofire.request(.GET, "\(apiURL)/usersMapById")
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

}
