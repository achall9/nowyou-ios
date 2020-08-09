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
//    private var card = STPCardParams()
//
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
//    
//    //--create_bank_account--
//    func addBank(customAccountId: String,
//                 accountNumber: String,
//                 routingNumber: String,
//                 accountHolderName: String,
//                 bankName: String,
//                 completion: @escaping([String: Any] ,NowYouError?) -> ()) {
//        
//        let bankAccount = STPBankAccountParams()
//
//        bankAccount.accountHolderName = accountHolderName
//        bankAccount.routingNumber = routingNumber
//        bankAccount.accountNumber = accountNumber
//        bankAccount.country = "US"
//
//        STPAPIClient.shared().createToken(withBankAccount: bankAccount) { token, error in
//            guard let token = token else {
//                print(error)
//                return
//            }
//            let params = ["external_account": token]
//            
//        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
////        let params: [String: Any] = [
////                   "external_account[object]": "bank_account",
////                   "external_account[country]": "US",
////                   "external_account[currency]": "usd",
////                   "external_account[account_number]": accountNumber,
////                   "external_account[routing_number]": routingNumber,
////                   "external_account[account_holder_name]": accountHolderName]
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
//        }
//    }//end -- func createStripeAccount
//    
//    func addCard(customAccountId: String,
//        number: String,
//        exp_month: Int,
//        exp_year: Int,
//        cvc: String,
//        currency: String,
//        name: String,
//        address_line1: String,
//        address_city: String,
//        address_state: String,
//        address_country: String,
//        address_zip: String,
//        completion : @escaping([String: Any], NowYouError?) -> ()) {
//        
//        card.number = number
//        card.expYear = UInt(exp_year)
//        card.expMonth = UInt(exp_month)
//        card.cvc = cvc
//        card.currency = currency
//        card.address.city = address_city
//        card.address.postalCode = address_zip
//        card.address.state = address_state
//        card.address.country = address_country
//        card.address.line1 = address_line1
//        
//        STPAPIClient.shared().createToken(withCard: card) { (token: STPToken?, error: Error?) in
//            guard let token = token else {return}
//            let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
//            let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//            let params = ["external_account": token]
//            Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//                   .validate()
//                   .responseJSON() { response in
//                       switch response.result {
//                       case .success:
//                           if let data = response.data,
//                               let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                                   print(dicData!)
//                                   completion(dicData!,nil)
//                               }
//                           case .failure(let error):
//                               if let data = response.data,
//                                   let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                                   let dicError = dicData?["error"] as? [String: Any],
//                                   let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                                       objStripeError.error = error
//                                   completion([:], objStripeError)
//                               } else{
//                                   let objStripeError = NowYouError(error: error)
//                                   completion([:],objStripeError)
//                               }
//                       }//--end--  switch response.result
//                   }//--end-- .responseJSON()
//           }
//    }//end -- func addCard
//    
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
//   //---list all cards
//   func listAllCards(customAccountId: String,
//              completion : @escaping([StripeCard] ,NowYouError?) -> ()) {
//       let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "external_account?object=card"
//       let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//       Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
//       .validate()
//       .responseJSON() { response in
//           switch response.result {
//           case .success:
//               if let data = response.data,
//                   let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                   let cardItems = json!["data"] as? [NSDictionary]
//                  {
//                   self.stripeCards.removeAll()
//                   for card in cardItems {
//                       let stripeCard = Mapper<StripeCard>().map(JSON: card as! [String : Any])
//                       self.stripeCards.append(stripeCard!)
//                   }
//                   completion(self.stripeCards,nil)
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
//   }//---end: func listAllCards
//
//    //-- create a payout
//    func createPayout(amount: Int,
//          currency: String,
//          destination: String,
//          completion : @escaping([String: Any], NowYouError?) -> ()) {
//          let requestString = API.STRIPE_BASEURL + "payouts"
//          let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
//          let params = ["amount": amount,
//                        "currency": "usd",
//                        "destination": destination] as [String : Any]
//          Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
//         .validate()
//         .responseJSON() { response in
//             switch response.result {
//             case .success:
//                 if let data = response.data,
//                     let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
//                         print(dicData!)
//                         completion(dicData!,nil)
//                     }
//                 case .failure(let error):
//                     if let data = response.data,
//                         let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
//                         let dicError = dicData?["error"] as? [String: Any],
//                         let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
//                             objStripeError.error = error
//                         completion([:], objStripeError)
//                     } else{
//                         let objStripeError = NowYouError(error: error)
//                         completion([:],objStripeError)
//                     }
//             }//--end--  switch response.result
//         }//--end-- .responseJSON()
//      }//end -- func createPayout
//}
//
