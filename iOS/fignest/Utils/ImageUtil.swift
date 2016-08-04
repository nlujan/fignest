//
//  ImageUtil.swift
//  fignest
//
//  Created by Naim on 4/8/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit


struct ImageUtil {
    
    func getImagesFromUrlStringArray(stringArray: [String]) throws -> [UIImage] {
        var imageArray: [UIImage] = []
        
        for urlString in stringArray {
            
            var u = urlString
            
            //workaround for undefined images
            if u == "https:undefined" {
                print("there are undefined images")
                u = "https://s3-media2.fl.yelpcdn.com/bphoto/7ztu4J0gMn468PNiOmOwew/258s.jpg"
            }
            
            guard let url = NSURL(string: u) else {
                throw ImageError.BadUrlString("Could not turn string to url")
            }
            
            guard let data = NSData(contentsOfURL: url) else {
                throw ImageError.InvalidUrl("Could not retreive contents of url")
            }
            
            imageArray.append(UIImage(data: data)!)
            
        }
        return imageArray
    }
    
    
    func getFBImageFromID(fbID: String) -> UIImage {
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fbID)/picture?width=1000&height=1000")
        
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            return UIImage(data: data)!
        } else {
            return UIImage()
        }
    }
    
    func getFBImageURL(fbID: String) -> String {
        return "http://graph.facebook.com/\(fbID)/picture?width=1000&height=1000"
    }
    
    
}