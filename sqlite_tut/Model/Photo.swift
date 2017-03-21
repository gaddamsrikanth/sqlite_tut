

import UIKit
import ObjectMapper

class Photo: NSObject,Mappable {
    
    var albumId: Int?
    var id: Int?
    var title: String?
    var url: String?
    var thumbnaiUrl: String?
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        albumId         <- map["albumId"]
        id              <- map["id"]
        title           <- map["title"]
        url             <- map["url"]
        thumbnaiUrl     <- map["thumbnaiUrl"]
    }
}


