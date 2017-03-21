

import UIKit
import ObjectMapper

class Comment: NSObject,Mappable {
    
    var postId: Int?
    var id: Int?
    var name: String?
    var email: String?
    var body: String?
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        postId         <- map["postId"]
        id              <- map["id"]
        name           <- map["name"]
        email             <- map["email"]
        body     <- map["body"]
    }
}


