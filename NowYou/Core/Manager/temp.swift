////
////  StripeManager.swift
////  NowYou
////
////  Created by 111 on 2/28/20.
////  Copyright © 2020 Apple. All rights reserved.
////
//
//
//import UIKit
//import Alamofire
//import ObjectMapper
//import Stripe
//class StripeManager: NSObject {
//
//    static let shared = StripeManager()
//    var stripeCards = [StripeCard]()
//    var stripeBanks = [StripeBank]()
////-- Create a customer
//    func createStripeCustomer(_ email:String,
//                           _ name:String,
//                           completion: @escaping([String: String] ,NowYouError?) -> ()) {
//
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER
//        let params : Parameters = ["email": email,
//                                    "name":name ]
//        let headers : HTTPHeaders = ["Authorization": "Bearer " + API.STRIPE_SECRET_KEY]
//        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//            .validate()
//            .responseJSON { response in
//                switch response.result{
//                case .success:
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                            print(dicData!["id"] ?? "")
//                            let stripeCountId  = dicData!["id"] as! String
//                            completion(["stripeCustomerId": stripeCountId ],nil)
//                        }
//                    case .failure(let error):
//                        if let data = response.data,
//                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                            let dicError = dicData?["error"] as? [String: Any],
//                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                                objStripeError.error = error
//                            completion([:], objStripeError)
//                        } else{
//                            let objStripeError = NowYouError(error: error)
//                            completion([:],objStripeError)
//                        }
//                }//--end--  switch response.result
//            }//--end-- .responseJSON()
//    }//end -- func CreateStripeCustomer
//
////-- create new stripe acccount for the user.
//    func createStripeCustomAccount(email: String, country: String, completion: @escaping([String: String] ,NowYouError?) -> ()) {
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT
//        let params: [String: Any] = [
//            "type": "custom",
//            "country": "US",
//            "email": email,
//            "business_type": "individual",
//            "requested_capabilities": [
//            "card_payments",
//            "transfers"]
//        ]
//        let headers: [String: String] = [
//            "Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"
//        ]
//        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//            .validate()
//            .responseJSON() { response in
//                switch response.result {
//                case .success:
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                            print(dicData!["id"] ?? "")
//                            let stripeCountId  = dicData!["id"] as! String
//                            completion(["stripeCustomAccountId": stripeCountId ],nil)
//                        }
//                case .failure(let error):
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                        let dicError = dicData?["error"] as? [String: Any],
//                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                            objStripeError.error = error
//                        completion([:], objStripeError)
//                    } else{
//                        let objStripeError = NowYouError(error: error)
//                        completion([:],objStripeError)
//                    }
//                }//--end--  switch response.result
//            }//--end-- .responseJSON()
//    }//end -- func createStripeAccount
//    //--create_bank_account--
//    func addBank(customAccountId: String,
//                 accountNumber: String,
//                 routingNumber: String,
//                 accountHolderName: String,
//                 bankName: String,
//                 completion: @escaping([String: Any] ,NowYouError?) -> ()) {
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
//        let params: [String: Any] = [
//                   "external_account[object]": "bank_account",
//                   "external_account[country]": "US",
//                   "external_account[currency]": "usd",
//                   "external_account[account_number]": accountNumber,
//                   "external_account[routing_number]": routingNumber,
//                   "external_account[account_holder_name]": accountHolderName]
//        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//            .validate()
//            .responseJSON() { response in
//                switch response.result {
//                case .success:
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                            print(dicData!)
////                            let stripeCountId  = dicData!["id"] as! String
//                            completion(dicData!,nil)
//                        }
//                    case .failure(let error):
//                        if let data = response.data,
//                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                            let dicError = dicData?["error"] as? [String: Any],
//                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                                objStripeError.error = error
//                            completion([:], objStripeError)
//                        } else{
//                            let objStripeError = NowYouError(error: error)
//                            completion([:],objStripeError)
//                        }
//                }//--end--  switch response.result
//            }//--end-- .responseJSON()
//    }//end -- func createStripeAccount
//
//    // Create a Card token
//    func createCardToken(customAccountId: String,
//            number: String,
//            exp_month: Int,
//            exp_year: Int,
//            cvc: String,
//            currency: String,
//            name: String,
//            address_line1: String,
//            address_city: String,
//            address_state: String,
//            address_country: String,
//            address_zip: String,
//            completion : @escaping(STPToken?, NowYouError?) -> ()) {
//        let requestString = API.STRIPE_BASEURL + "/tokens"
//        let params: [String: Any] = [
//                  "card[object]": "card",
//                  "card[number]": number,
//                  "card[exp_month]": exp_month,
//                  "card[exp_year]": exp_year,
//                  "card[cvc]": cvc,
//                  "card[currency]": currency,
//                  "card[name]": name,
//                  "card[address_line1]": address_line1,
//                  "card[address_city]": address_city,
//                  "card[address_state]": address_state,
//                  "card[address_country]": address_country,
//                  "card[address_zip]": address_zip
//                ]
//        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//         Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//            .validate()
//            .responseJSON() { response in
//                switch response.result {
//                case .success:
//                    if let data = response.data{
//                        let cardToken = (try? JSONSerialization.jsonObject(with: data, options: [])) as? STPToken
//                        print(cardToken as Any)
//                        completion(cardToken,nil)
//                    }
//                case .failure(let error):
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                        let dicError = dicData?["error"] as? [String: Any],
//                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                            objStripeError.error = error
//                        completion(nil, objStripeError)
//                    } else{
//                        let objStripeError = NowYouError(error: error)
//                        completion(nil,objStripeError)
//                    }
//            }//--end--  switch response.result
//        }//--end-- .responseJSON()
//    }//--- End
//    //Create a Card
//    func addCard(customAccountId: String,
//                 cardToken: STPToken,
////                number: String,
////                exp_month: Int,
////                exp_year: Int,
////                cvc: String,
////                currency: String,
////                name: String,
////                address_line1: String,
////                address_city: String,
////                address_state: String,
////                address_country: String,
////                address_zip: String,
//                completion : @escaping([String: Any] ,NowYouError?) -> ()) {
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
//        let params: [String: Any] = [
//            "external_account": cardToken
////                  "external_account[object]": "card",
////                  "external_account[number]": cardToken.last4!,
////                  "external_account[exp_month]": cardToken.exp_month!,
////                  "external_account[exp_year]": cardToken.exp_year!,
//////                  "external_account[cvc]": cardToken.c,
////                  "external_account[currency]": cardToken.currency ?? "usd",
////                  "external_account[name]": cardToken.name ?? "",
////                  "external_account[address_line1]": cardToken.address_line1 ?? "",
////                  "external_account[address_city]": cardToken.address_city ?? "",
////                  "external_account[address_state]": cardToken.address_state ?? "",
////                  "external_account[address_country]": cardToken.address_country ?? "US",
////                  "external_account[address_zip]": cardToken.address_zip ?? ""
//                ]
//        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//            .validate()
//            .responseJSON() { response in
//                switch response.result {
//                case .success:
//                    if let data = response.data,
//                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                            print(dicData!)
////                            let stripeCountId  = dicData!["id"] as! String
//                            completion(dicData!,nil)
//                        }
//                    case .failure(let error):
//                            if let data = response.data,
//                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                            let dicError = dicData?["error"] as? [String: Any],
//                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                                objStripeError.error = error
//                            completion([:], objStripeError)
//                        } else{
//                            let objStripeError = NowYouError(error: error)
//                            completion([:],objStripeError)
//                        }
//                }//--end--  switch response.result
//            }//--end-- .responseJSON()
//    }//end -- func createStripeAccount
//    //
//    //---list all cards
//    func listAllCards(customAccountId: String,
//               completion : @escaping([StripeCard] ,NowYouError?) -> ()) {
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "external_account?object=card"
//        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
//        .validate()
//        .responseJSON() { response in
//            switch response.result {
//            case .success:
//                if let data = response.data,
//                    let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                    let cardItems = json!["data"] as? [NSDictionary]
//                   {
//                    self.stripeCards.removeAll()
//                    for card in cardItems {
//                        let stripeCard = Mapper<StripeCard>().map(JSON: card as! [String : Any])
//                        self.stripeCards.append(stripeCard!)
//                    }
//                    completion(self.stripeCards,nil)
//                }
//            case .failure(let error):
//                if let data = response.data,
//                    let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                    let dicError = dicData?["error"] as? [String: Any],
//                    let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                        objStripeError.error = error
//                    completion([], objStripeError)
//                } else{
//                    let objStripeError = NowYouError(error: error)
//                    completion([],objStripeError)
//                }
//            }//--end--  switch response.result
//        }//--end-- .responseJSON()
//    }//---end: func listAllCards
//
//    //---list all bank accounts
//    func listAllbankAcccounts(customAccountId: String,
//                  completion : @escaping([StripeBank] ,NowYouError?) -> ()) {
//       let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "external_account?object=bank_account"
//       let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//       Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
//       .validate()
//       .responseJSON() { response in
//           switch response.result {
//           case .success:
//               if let data = response.data,
//                   let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                   let bankItems = json!["data"] as? [NSDictionary]
//                  {
//                   self.stripeBanks.removeAll()
//                   for bank in bankItems {
//                       let stripeBank = Mapper<StripeBank>().map(JSON: bank as! [String : Any])
//                       self.stripeBanks.append(stripeBank!)
//                   }
//                   completion(self.stripeBanks,nil)
//               }
//           case .failure(let error):
//               if let data = response.data,
//                   let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                   let dicError = dicData?["error"] as? [String: Any],
//                   let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                       objStripeError.error = error
//                   completion([], objStripeError)
//               } else{
//                   let objStripeError = NowYouError(error: error)
//                   completion([],objStripeError)
//               }
//           }//--end--  switch response.result
//       }//--end-- .responseJSON()
//    }//---end: func listAllCards
//}
////    //--create_bank_account--
////    func addBank(customerId: String,
////                 accountNumber: String,
////                 routingNumber: String,
////                 accountHolderName: String,
////                 bankName: String,
////                 completion: @escaping([String: Any] ,NowYouError?) -> ()) {
////        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER + "/\(customerId)" + "/sources"
////        let params: [String: Any] = [
////                   "source[object]": "bank_account",
////                   "source[country]": "US",
////                   "source[currency]": "usd",
////                   "source[account_number]": accountNumber,
////                   "source[routing_number]": routingNumber,
////                   "source[account_holder_name]": accountHolderName]
////        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
////        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
////            .validate()
////            .responseJSON() { response in
////                switch response.result {
////                case .success:
////                    if let data = response.data,
////                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
////                            print(dicData!)
//////                            let stripeCountId  = dicData!["id"] as! String
////                            completion(dicData!,nil)
////                        }
////                    case .failure(let error):
////                        if let data = response.data,
////                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                            let dicError = dicData?["error"] as? [String: Any],
////                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
////                                objStripeError.error = error
////                            completion([:], objStripeError)
////                        } else{
////                            let objStripeError = NowYouError(error: error)
////                            completion([:],objStripeError)
////                        }
////                }//--end--  switch response.result
////            }//--end-- .responseJSON()
////    }//end -- func createStripeAccount
////
////    //Create a Card
////    func addCard(customerId: String,
////                number: String,
////                exp_month: Int,
////                exp_year: Int,
////                cvc: String,
////                currency: String,
////                name: String,
////                address_line1: String,
////                address_city: String,
////                address_state: String,
////                address_country: String,
////                address_zip: String,
////                completion : @escaping([String: Any] ,NowYouError?) -> ()) {
////        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER + "/\(customerId)" + "/sources"
////        let params: [String: Any] = [
////                  "source[object]": "card",
////                  "source[number]": number,
////                  "source[exp_month]": exp_month,
////                  "source[exp_year]": exp_year,
////                  "source[cvc]": cvc,
////                  "source[currency]": currency,
////                  "source[name]": name,
////                  "source[address_line1]": address_line1,
////                  "source[address_city]": address_city,
////                  "source[address_state]": address_state,
////                  "source[address_country]": address_country,
////                  "source[address_zip]": address_zip,
////                ]
////        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
////        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
////            .validate()
////            .responseJSON() { response in
////                switch response.result {
////                case .success:
////                    if let data = response.data,
////                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
////                            print(dicData!)
//////                            let stripeCountId  = dicData!["id"] as! String
////                            completion(dicData!,nil)
////                        }
////                    case .failure(let error):
////                        if let data = response.data,
////                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                            let dicError = dicData?["error"] as? [String: Any],
////                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
////                                objStripeError.error = error
////                            completion([:], objStripeError)
////                        } else{
////                            let objStripeError = NowYouError(error: error)
////                            completion([:],objStripeError)
////                        }
////                }//--end--  switch response.result
////            }//--end-- .responseJSON()
////    }//end -- func createStripeAccount
////
////    //---list all cards
////    func listAllCards(customerId: String,
////                   completion : @escaping([StripeCard] ,NowYouError?) -> ()) {
////        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER + "/\(customerId)" + "/sources?object=card"
////        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
////        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
////        .validate()
////        .responseJSON() { response in
////            switch response.result {
////            case .success:
////                if let data = response.data,
////                    let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                    let cardItems = json!["data"] as? [NSDictionary]
////                   {
////                    self.stripeCards.removeAll()
////                    for card in cardItems {
////                        let stripeCard = Mapper<StripeCard>().map(JSON: card as! [String : Any])
////                        self.stripeCards.append(stripeCard!)
////                    }
////                    completion(self.stripeCards,nil)
////                }
////            case .failure(let error):
////                if let data = response.data,
////                    let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                    let dicError = dicData?["error"] as? [String: Any],
////                    let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
////                        objStripeError.error = error
////                    completion([], objStripeError)
////                } else{
////                    let objStripeError = NowYouError(error: error)
////                    completion([],objStripeError)
////                }
////            }//--end--  switch response.result
////        }//--end-- .responseJSON()
////    }//---end: func listAllCards
////
////
////    //---list all bank accounts
////       func listAllbankAcccounts(customerId: String,
////                      completion : @escaping([StripeBank] ,NowYouError?) -> ()) {
////           let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER + "/\(customerId)" + "/sources?object=bank_account"
////           let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
////           Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
////           .validate()
////           .responseJSON() { response in
////               switch response.result {
////               case .success:
////                   if let data = response.data,
////                       let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                       let bankItems = json!["data"] as? [NSDictionary]
////                      {
////                       self.stripeBanks.removeAll()
////                       for bank in bankItems {
////                           let stripeBank = Mapper<StripeBank>().map(JSON: bank as! [String : Any])
////                           self.stripeBanks.append(stripeBank!)
////                       }
////                       completion(self.stripeBanks,nil)
////                   }
////               case .failure(let error):
////                   if let data = response.data,
////                       let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
////                       let dicError = dicData?["error"] as? [String: Any],
////                       let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
////                           objStripeError.error = error
////                       completion([], objStripeError)
////                   } else{
////                       let objStripeError = NowYouError(error: error)
////                       completion([],objStripeError)
////                   }
////               }//--end--  switch response.result
////           }//--end-- .responseJSON()
////       }//---end: func listAllCards
////}
//
//
//
