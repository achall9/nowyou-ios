//
//  StripeCard.swift
//  NowYou
//
//  Created by 111 on 2/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//
import UIKit
import ObjectMapper

class StripeCard: Mappable {
    
    var exp_month       : Int?
    var exp_year        : Int?
    var last4           : String?
    var brand           : String?

    var id              : String?
    var object          : String?
    var address_city    : String?
    var address_county  : String?
    var address_state   : String?
    var address_line1   : String?
    var address_line2   : String?
    var address_zip     : Int?
    var country         : String?

    var customer        : String?
    var name            : String?
    var fingerprint     : String?
    var funding        : String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
       id              <- map["id"]
       object          <- map["object"]
       address_city    <- map["address_city"]
       address_county  <- map["address_county"]
       address_state   <- map["address_state"]
       address_line1   <- map["address_line1"]
       address_line2   <- map["address_line2"]
       address_zip     <- map["address_zip"]
       
       brand           <- map["brand"]
       country         <- map["country"]
       customer        <- map["customer"]
       exp_month       <- map["exp_month"]
       exp_year        <- map["exp_year"]
       funding         <- map["funding"]
       last4           <- map["last4"]
       fingerprint     <- map["fingerprint"]
       name            <- map["name"]
    }
}


