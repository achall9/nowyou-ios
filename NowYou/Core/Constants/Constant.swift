//
//  Constant.swift
//  NowYou
//
//  Created by 111 on 2020/9/22.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
struct Environment {
    public static var current: Options = .development
    
    enum Options {
        case development, production
    }
}

struct Constant {
    struct PayPal {
        //production
        static var clientId: String {
            if Environment.current == .development {
                return "AcBKkv29nffbKeCW-KnFYd5CXn-Q3xUoYBSKoTz3VHfjPbfRFusD3YcPGHNhIO5IOn1OQwfPYwWF2kib"
            }
            else {
                return  ""
            }
        }
        static var secret: String {
            if Environment.current == .development {
                return "EJ11M7lWG4gzc5TcoOKuF2bxx1xIFuzdv-IBAe2nPBN8ocE9ExSjSfIOMqx8yEzEXrHhFmGjmXPViVz9"
            }
            else {
                return  ""
            }
        }
        struct URL{
            static var baseAuth: String{
                if Environment.current == .development{
                    return "https://api.sandbox.paypal.com/v1/oauth2"
                }else{
                    return "https://api.paypal.com/v1/oauth2"
                }
            }
            static var base: String{
                if Environment.current == .development{
                    return "https://api.sandbox.paypal.com/v1/payments"
                }else{
                    return "https://api.paypal.com/v1/payments"
                }
            }
            static var token: String {
                    return "\(baseAuth)/token"
            }
            static var payout: String{
                return "\(base)/payouts"
            }
            
        }
}
