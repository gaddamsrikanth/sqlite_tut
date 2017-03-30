//
//  Hits.swift
//  sqlite_tut
//
//  Created by devloper65 on 3/27/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper
class Hits: NSObject, Mappable{
    var total: Int?
    var totalhits: Int?
    var res : NSMutableArray?
   
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)

    }
    
    func mapping(map: Map) {
        total   <- map["total"]
        totalhits <- map["totalHits"]
        res <- map["hits"]        
    }

}
