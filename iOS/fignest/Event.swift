//
//  Event.swift
//  fignest
//
//  Created by Naim on 3/22/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import Foundation

struct Event {
    
    var id: String
    var name: String
    var users: [String]
    var searchText: String
    
    init(data: NSDictionary) {
        
        self.id = data["_id"] as! String
        self.name = data["name"] as! String
        self.users = data["users"] as! [String]
        self.searchText = data["search"] as! String
    }
    
}