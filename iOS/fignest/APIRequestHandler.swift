//
//  APIRequestHandler.swift
//  fignest
//
//  Created by Naim on 3/19/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit

class APIRequestHandler: NSObject {
    
    static let sharedInstance = APIRequestHandler()
    
    let apiURL: String = "https://9d460dd2.ngrok.io"
    
    var imagesURLs = [
        "https://s3-media4.fl.yelpcdn.com/bphoto/0OIgMcReW_hlcOQYNrKWjA/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/nkau8U5Z48-dl4ICQZBDRw/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/CKfZc1IzacmhbsHaRFLa-w/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/4wDXAtgWzjr779xG6bjQNA/258s.jpg",
        "https://s3-media2.fl.yelpcdn.com/bphoto/PdTB4h6Tt34mZMCGerhzXA/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/jUVmJB47saALPsuQ0fIg6g/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/_-RSSS86gvL95lRWpCwiKA/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/DngwFbKFGlYEGiZplWTjpQ/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/Mvq73rEh-g3ohhnUdLZwWw/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/pQtu7hOdZnTZRdJwUH2tTQ/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/MlhzYXoeEKv6mhC2T6I0Vg/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/6qf5dLlGoTFAU1nthCvfEA/258s.jpg",
        "https://s3-media2.fl.yelpcdn.com/bphoto/zs93C4dltzUWcr9Sx3gMxQ/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/KIsCEzlUv0et4HWrzSKqRg/258s.jpg",
        "https://s3-media2.fl.yelpcdn.com/bphoto/XvQlCeB0pJgpJVRzFAuU3Q/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/NbSNlBvHFOBAEvznMpw6CQ/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/jBnVho-x4iFyEoruqdJmeA/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/dIZ3TFzxEBwOlWmgsu3Lfw/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/aWM2XtVAYQe-dNIEIlmdgw/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/e8QAAxn0cAsPK0vXajdJrw/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/7Vsibpgy11dkkIjzP4_u2g/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/upFBoRMCpxgsUqZeC9FhDQ/258s.jpg",
        "https://s3-media2.fl.yelpcdn.com/bphoto/zDcpeQMHmNw0U53SHkYygQ/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/4THQ0F_Hgvs9MeieIyKU2A/258s.jpg",
        "https://s3-media1.fl.yelpcdn.com/bphoto/Ktnc3ppDOSlokSO46L680A/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/YEVHM-eiJMcX2ufQiitfIg/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/IGWIAHHY2UpyZ7FU4HbT2w/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/3cKhlxP4PEfFAbP1pTkVNg/258s.jpg",
        "https://s3-media3.fl.yelpcdn.com/bphoto/_nKiWOO9yqvt5Nm3J-3nCw/258s.jpg",
        "https://s3-media4.fl.yelpcdn.com/bphoto/dpDHWDblLoS_YUsb2Mm4Yg/258s.jpg"
    ]
    
    override init() {
        super.init()
       
    }
    
    func getImagesFromUrlStringArray(stringArray: [String]) -> [UIImage] {
        
        var result: [UIImage] = []
        
        for urlString in stringArray {
            //print(urlString)
            
            if let url = NSURL(string: urlString) {
                if let data = NSData(contentsOfURL: url) {
                    //print(UIImage(data: data)!)
                    result.append(UIImage(data: data)!)
                }        
            }
        }
        return result
    }
    
    func getImages() -> [UIImage] {
         return getImagesFromUrlStringArray(imagesURLs)
    }
    
    private func get(postEndpoint : String) {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                if let ipString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    // Print what we got from the call
                    print(ipString)
                    
                    // Parse the JSON to get the IP
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                    print(jsonDictionary)
                    //let origin = jsonDictionary["origin"] as! String
                    
                    // Perform function that is desired
                    //self.performSelectorOnMainThread("updateIPLabel:", withObject: origin, waitUntilDone: false)
                }
            } catch {
                print("bad things happened")
            }
        }).resume()
    }
    
    private func post(postParams : [String: AnyObject], postEndpoint : String) {
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
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
            
            // Read the JSON
            
            do {
                if let postString = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                    // Print what we got from the call
                    print("POST: " + postString)
                    
                    // Perform function that is desired
                    
                    
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    //print("fucking ID!: \(jsonDictionary["_id"] as! String)")
                    
                    //self.performSelectorOnMainThread("printPostResult:", withObject: data, waitUntilDone: false)
                }
            } catch {
                print("bad things happened")
            }
            
        }).resume()
    }
    
    func createNewFig(name: String, address: String, users: [String], search: String) {
        
        let jsonObject: [String: AnyObject] = [
            "name": name,
            "location": [
                "type": "address",
                "address": address
            ],
            "users": [],
            "search": search
        ]
        
        post(jsonObject, postEndpoint: "\(apiURL)/events/")
        
        //get("https://01d7a946.ngrok.io/events/56ef1ceb6f0c73691ccdf190/places")
        
    }
    
    func printPostResult(text: String) ->  String {
        //self.postResultLabel.text = "POST : " + text
        print("POST : \(text["_id"])")
        return text
    }
    
    func updateIPLabel(text: String) {
        print("GET : \(text)")
        //self.ipLabel.text = "Your IP is " + text
    }
    
    func addUserToDatabase(name: String, fbID: String, email: String) {
        
        let jsonObject: [String: AnyObject] = [
            "facebook": [
                "name": name,
                "id": fbID,
                "email": email
            ]
        ]
        
        post(jsonObject, postEndpoint: "\(apiURL)/users")
    }
    
    func getAllUsers() {
        
        get("\(apiURL)/users")
    }
    
    func dataToArray(data: NSData!) {
        
        
    }

    

}
