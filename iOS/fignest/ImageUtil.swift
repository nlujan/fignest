//
//  ImageUtil.swift
//  fignest
//
//  Created by Naim on 4/8/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import UIKit


class ImageUtil {
    
    static let sharedInstance = ImageUtil()
    
    private init() {
        
    }
    
    func getImagesFromUrlStringArray(stringArray: [String]) -> [UIImage] {
        var result: [UIImage] = []
        
        for urlString in stringArray {
            
            var u = urlString
            
            //workaround for undefined images
            if u == "https:undefined" {
                u = "https://s3-media2.fl.yelpcdn.com/bphoto/7ztu4J0gMn468PNiOmOwew/258s.jpg"
            }
            
            if let url = NSURL(string: u) {
                if let data = NSData(contentsOfURL: url) {
                    //print(UIImage(data: data)!)
                    result.append(UIImage(data: data)!)
                }
            }
        }
        return result
    }
    
    
    func getFBImageFromID(fbID: String) -> UIImage {
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fbID)/picture?type=square&height=60&width=60")
        
        if let data = NSData(contentsOfURL: facebookProfileUrl!) {
            return UIImage(data: data)!
        } else {
            return UIImage()
        }
    }
    
    
}