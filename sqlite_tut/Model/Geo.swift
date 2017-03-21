

import UIKit
import ObjectMapper

class Geo: NSObject,Mappable {
    
    var lat: String?
    var lng: String?

    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        lat             <- map["lat"]
        lng     <- map["lng"]
    }
}


