//
//  StripeBank.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//
import UIKit
import ObjectMapper

class StripeBank: Mappable {

    var account_holder_name : String?
    var bank_name       : String?
    var routing_number  : String?
    var last4           : String?
    var id              : String? //bank ID
    var account         : String? // custom account ID
    var country         : String?
    var currency        : String?    
    var object          : String?

    var account_holder_type : String?
    var fingerprint     : String?
    var status          : String?
    //    var metaData        : NSDictionary?

    required init?(map: Map) {

    }
    
    func mapping(map: Map) {
        account        <- map["account"]
        country        <- map["country"]
        currency       <- map["currency"]

        id             <- map["id"]
        object         <- map["object"]
        account_holder_name  <- map["account_holder_name"]
        account_holder_type  <- map["account_holder_type"]

        bank_name       <- map["bank_name"]
        fingerprint     <- map["fingerprint"]
        last4           <- map["last4"]
        routing_number  <- map["routing_number"]
        status          <- map["status"]
    }

}
