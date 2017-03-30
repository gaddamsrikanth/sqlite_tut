//
//  Channel.swift
//  sqlite_tut
//
//  Created by Devloper30 on 30/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import Foundation
import ObjectMapper

class Channel: NSObject,Mappable {
    var id: String?
    var name: String?
    
    required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id      <- map["id"]
        name    <- map["name"]
    }
}
