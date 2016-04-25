//
//  APIRequestHandler.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

struct APIRequestHandler {
    
    private let apiURL: String = "https://e6907817.ngrok.io"
    
    
    /**
     Just testing documentation using Markdown
     - returns: Bool
     - parameter name: Name of the user
     - parameter fbID: String
     - parameter email: asd
     - parameter callback: function to be called after success
     - Throws: error lists
     */
    private func get(postEndpoint : String, successHandler: (response: NSData?) -> Void) {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        // Make the GET call and handle it in a completion handler
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            //calls successHandler func
            successHandler(response: data as NSData?)

        }).resume()
    }
    
    /**
     Just testing documentation using Markdown
     - returns: Void
     - parameter postParams: Name of the user
     - parameter postEndpoint: String
     - parameter successHandler: asd
     - Throws: error lists
     */
    private func post(postParams : [String: AnyObject], postEndpoint : String, successHandler: (response: NSData?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            //print(postParams)
        } catch {
            print("bad things happened")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    print(error)
                    return
            }
            
            //calls successHandler func
            successHandler(response: data as NSData?)
            
        }).resume()
    }
    
    func getAllUsers(callback: (dataArray: NSArray) -> Void) {
        
        get("\(apiURL)/users", successHandler: {
            (response) in
            
            do {
                let jsonArray = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                print("Getting Users Success!")
                
                callback(dataArray: jsonArray)
                
            } catch {
                print("getAllUsers failed!")
            }
            
        })
    }
    
    /**
     Just testing documentation using Markdown
     - returns: Bool
     - parameter name: Name of the user
     - parameter fbID: String
     - parameter email: asd
     - parameter callback: function to be called after success
     - Throws: error lists
     */
    func addUserToDatabase(name: String, fbID: String, email: String,  callback: (dataDict: NSDictionary) -> Void) {
        
        let jsonObject: [String: AnyObject] = [
            "facebook": [
                "name": name,
                "id": fbID,
                "email": email
            ]
        ]
        
        post(jsonObject, postEndpoint: "\(apiURL)/users", successHandler: {
            (response) in
            
            do {
                let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("addUserToDatabase Success!")
                
                callback(dataDict: jsonDictionary)
                
            } catch {
                print("addUserToDatabase failed!")
            }
        })
    }
    
    func getUserInvitations(userID: String,  callback: (dataArray: NSArray) -> Void) {
        
        get("\(apiURL)/users/\(userID)/invitations", successHandler: {
        (response) in
        
            do {
                let jsonArray = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                print("Getting Invitations Success!")
                
                callback(dataArray: jsonArray)
            
            } catch {
                print("Getting Invitations failed!")
            }
        
        })
    }
    
    func getEvent(eventID: String, callback: (dataDict: NSDictionary) -> Void) {
        
        get("\(apiURL)/events/\(eventID)/", successHandler: {
            (response) in
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Getting Single Event Success!")
                
                callback(dataDict: jsonDict)
                
            } catch {
                print("Getting Single Event failed!")
            }
        })
        
    }
    
    func createNewFig(name: String, address: String, users: [String], search: String, callback: (dataDict: NSDictionary) -> Void) {
        
        let jsonObject: [String: AnyObject] = [
            "name": name,
            "location": [
                "type": "address",
                "address": address
            ],
            "users": users,
            "search": search
        ]
        
        post(jsonObject, postEndpoint: "\(apiURL)/events/", successHandler: {
            (response) in
            
            print("Posting Success!")
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                callback(dataDict: jsonDict)
                
            } catch {
                print("Posting failed!")
            }
            
        })
    }
    
    func getFigEventPlaces(eventID: String, callback: (dataArray: NSArray) -> Void) {
        
        get("\(apiURL)/events/\(eventID)/places", successHandler: {
        (response) in
            
            do {
                let jsonArray = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                print("Getting Places Success!")
                
                callback(dataArray: jsonArray)
                
            
            } catch {
                print("Getting Places Failed!")
            }
        })
    
    }
    
    
    
    func getSolution(eventID: String, callback: (dataDict: NSDictionary) -> Void) {
    
        get("\(apiURL)/events/\(eventID)/solution", successHandler: {
        (response) in
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Getting Final Result Success!")
                
                callback(dataDict: jsonDict)
                
            } catch {
                print("Getting Final Result failed!")
            }
        })
        
    }
    
    func postAction(userID: String, eventID: String, selections: [NSDictionary],  callback: (jsonDict: NSDictionary) -> Void) {
        
        let jsonObject: [String: AnyObject] = [
            "user": userID,
            "event": eventID,
            "selections": selections
        ]
        
        post(jsonObject, postEndpoint: "\(apiURL)/events/\(eventID)/actions", successHandler: {
            (response) in
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Posting Action Success!")
                
                callback(jsonDict: jsonDict)
            } catch {
                print("Posting Action failed!")
            }
        })
        
    }
    
    func getUsersMapById(callback: (jsonDict: NSDictionary) -> Void) {
        
        get("\(apiURL)/usersMapById", successHandler: {
            (response) in
            
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(response!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Getting Users Mapping Success!")
                
                callback(jsonDict: jsonDict)
                
            } catch {
                print("Getting Users Mapping failed!")
            }
        })
    }

}
