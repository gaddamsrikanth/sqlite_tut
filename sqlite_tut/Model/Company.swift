

import UIKit
import ObjectMapper

class Company: NSObject,Mappable {
    
    var name: String?
    var catchPhrase: String?
    var bs: String?
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {

        name           <- map["name"]
        catchPhrase             <- map["catchPhrase"]
        bs     <- map["bs"]
    }
}


