//
//  CardToken.swift
//  
//
//  Created by 111 on 3/4/20.
//
import UIKit
import ObjectMapper

class CardToken: Mappable {
    var address_city : String?
    var address_country : String?
    var address_line1: String?
    
    var address_line2: String?
    var address_state: String?
    var address_zip: String?
    var brand: String?
    var country: String?
    var currency: String?
    var exp_month: Int?
    var exp_year: Int?
    var fingerprint: String?
    var funding: String?
    var last4: String?
    var name: String?
    var object: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
       object          <- map["object"]
       address_city    <- map["address_city"]
       address_country <- map["address_country"]
       address_state   <- map["address_state"]
       address_line1   <- map["address_line1"]
       address_line2   <- map["address_line2"]
       address_zip     <- map["address_zip"]
       
       brand           <- map["brand"]
       country         <- map["country"]
       exp_month       <- map["exp_month"]
       exp_year        <- map["exp_year"]
       funding         <- map["founding"]
       last4           <- map["last4"]
       fingerprint     <- map["fingerprint"]
       name            <- map["name"]
    }
}


