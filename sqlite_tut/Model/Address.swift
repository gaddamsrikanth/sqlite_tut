

import UIKit
import ObjectMapper

class Address: NSObject,Mappable {
    
    var street: String?
    var suite: String?
    var city: String?
    var zipcode: String?
    var geo: Geo?
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        street         <- map["street"]
        suite              <- map["suite"]
        city           <- map["city"]
        zipcode             <- map["zipcode"]
        geo     <- map["geo"]
    }
}

