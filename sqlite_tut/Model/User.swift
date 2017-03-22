
import UIKit
import ObjectMapper

class User: NSObject,Mappable {
    
    var id: Int?
    var name: String?
    var username: String?
    var email: String?
    var phone: String?
    var website: String?
    var address: Address?
    var company: Company?
    
    
    required override  init() {
        super.init()
    }
    
    required init(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id        <- map["id"]
        name      <- map["name"]
        username  <- map["username"]
        email     <- map["email"]
        phone     <- map["phone"]
        website   <- map["website"]
        address   <- map["address"]
        company   <- map["company"]
    }
}


