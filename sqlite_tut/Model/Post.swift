

import UIKit
import ObjectMapper

class Post: NSObject,Mappable {
    
    var userId: Int?
    var id: Int?
    var title: String?
    var body: String?
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        userId         <- map["userId"]
        id              <- map["id"]
        title           <- map["title"]
        body             <- map["body"]
    }
}


