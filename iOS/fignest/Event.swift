//
//  Event.swift
//  fignest
//
//  Created by Naim on 3/22/16.
//  Copyright © 2016 fignest. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Event {
    
    var id: String
    var name: String
    var users: [JSON]
    var searchText: String
    
    init(data: JSON) {
        
        self.id = data["_id"].stringValue
        self.name = data["name"].stringValue
        self.users = data["users"].arrayValue
        self.searchText = data["search"].stringValue
    }
    
}