//
//  StripeManager.swift
//  NowYou
//
//  Created by 111 on 2/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//


import UIKit
import Alamofire
import ObjectMapper
import Stripe
class StripeManager: NSObject {
    
    static let shared = StripeManager()
    var stripeCards = [StripeCard]()
    var stripeBanks = [StripeBank]()
    private var card = STPCardParams()
//-- Create a customer
    func createStripeCustomer(_ email:String,
                           _ name:String,
                           completion: @escaping([String: String] ,NowYouError?) -> ()) {

        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_CUSTOMRER

        let params : Parameters = ["email": email,
                                    "name":name]
        
        let headers : HTTPHeaders = ["Authorization": "Bearer " + API.STRIPE_SECRET_KEY]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success:
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                            print(dicData!["id"] ?? "")
                            let stripeCountId  = dicData!["id"] as! String
                            completion(["stripeCustomerId": stripeCountId ],nil)
                        }
                    case .failure(let error):
                        if let data = response.data,
                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                            let dicError = dicData?["error"] as? [String: Any],
                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                                objStripeError.error = error
                            completion([:], objStripeError)
                        } else{
                            let objStripeError = NowYouError(error: error)
                            completion([:],objStripeError)
                        }
                }//--end--  switch response.result
            }//--end-- .responseJSON()
    }//end -- func CreateStripeCustomer
    
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

//-- create new stripe acccount for the user.
    func createStripeCustomAccount(email: String,
                                   country: String,
                                   connectAccountToken: STPToken,
                                   completion: @escaping([String: String] ,NowYouError?) -> ()) {
        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT
        let params: [String: Any] = [
            "type": "custom",
            "requested_capabilities": [
            "card_payments",
            "transfers"],
            "account_token": connectAccountToken,
            "business_profile[mcc]": 5734,
            "business_profile[url]": "Nowyou.com"
        ]
        let headers: [String: String] = [
            "Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"
        ]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                            print(dicData!["id"] ?? "")
                            let stripeCountId  = dicData!["id"] as! String
                            completion(["stripeCustomAccountId": stripeCountId ],nil)
                        }
                case .failure(let error):
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                        let dicError = dicData?["error"] as? [String: Any],
                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                            objStripeError.error = error
                        completion([:], objStripeError)
                    } else{
                        let objStripeError = NowYouError(error: error)
                        completion([:],objStripeError)
                    }
                }//--end--  switch response.result
            }//--end-- .responseJSON()
    }//end -- func createStripeAccount
    
    //--create_bank_account--
    func addBank(customAccountId: String,
                 accountNumber: String,
                 routingNumber: String,
                 accountHolderName: String,
                 bankName: String,
                 completion: @escaping([String: Any] ,NowYouError?) -> ()) {
        
        let bankAccount = STPBankAccountParams()

        bankAccount.accountHolderName = accountHolderName
        bankAccount.routingNumber = routingNumber
        bankAccount.accountNumber = accountNumber
        bankAccount.country = "US"

        STPAPIClient.shared().createToken(withBankAccount: bankAccount) { token, error in
            guard let token = token else {
                print(error!.localizedDescription)
                let objStripeError = NowYouError(error: error)
                completion([:],objStripeError)
                return
            }
            let params = ["external_account": token]
            
        let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
//        let params: [String: Any] = [
//                   "external_account[object]": "bank_account",
//                   "external_account[country]": "US",
//                   "external_account[currency]": "usd",
//                   "external_account[account_number]": accountNumber,
//                   "external_account[routing_number]": routingNumber,
//                   "external_account[account_holder_name]": accountHolderName]
        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                            print(dicData!)
//                            let stripeCountId  = dicData!["id"] as! String
                            completion(dicData!,nil)
                        }
                    case .failure(let error):
                        if let data = response.data,
                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                            let dicError = dicData?["error"] as? [String: Any],
                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                                objStripeError.error = error
                            completion([:], objStripeError)
                        } else{
                            let objStripeError = NowYouError(error: error)
                            completion([:],objStripeError)
                        }
                }//--end--  switch response.result
            }//--end-- .responseJSON()
        }
    }//end -- func createStripeAccount
    
    func addCard(customAccountId: String,
        number: String,
        exp_month: Int,
        exp_year: Int,
        cvc: String,
        currency: String,
        name: String,
        address_line1: String,
        address_city: String,
        address_state: String,
        address_country: String,
        address_zip: String,
        completion : @escaping([String: Any], NowYouError?) -> ()) {
        
        card.number = number
        card.expYear = UInt(exp_year)
        card.expMonth = UInt(exp_month)
        card.cvc = cvc
        card.currency = currency
        card.address.city = address_city
        card.address.postalCode = address_zip
        card.address.state = address_state
        card.address.country = address_country
        card.address.line1 = address_line1
        
        STPAPIClient.shared().createToken(withCard: card) { (token: STPToken?, error: Error?) in
            guard let token = token else {
                print(error?.localizedDescription)
                let objStripeError = NowYouError(error: error)
                completion([:],objStripeError)
                return
            }
            let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts"
            let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
            let params = ["external_account": token]
            Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
                   .validate()
                   .responseJSON() { response in
                       switch response.result {
                       case .success:
                           if let data = response.data,
                               let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                                   print(dicData!)
                                   completion(dicData!,nil)
                               }
                           case .failure(let error):
                               if let data = response.data,
                                   let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                                   let dicError = dicData?["error"] as? [String: Any],
                                   let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                                       objStripeError.error = error
                                   completion([:], objStripeError)
                               } else{
                                   let objStripeError = NowYouError(error: error)
                                   completion([:],objStripeError)
                               }
                       }//--end--  switch response.result
                   }//--end-- .responseJSON()
           }
    }//end -- func addCard
    
    
    //---list all bank accounts
    func listAllbankAcccounts(customAccountId: String,
                  completion : @escaping([StripeBank] ,NowYouError?) -> ()) {
       let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts?object=bank_account"
       let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
       Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
       .validate()
       .responseJSON() { response in
           switch response.result {
           case .success:
               if let data = response.data,
                   let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                   let bankItems = json!["data"] as? [NSDictionary]
                  {
                   self.stripeBanks.removeAll()
                   for bank in bankItems {
                       let stripeBank = Mapper<StripeBank>().map(JSON: bank as! [String : Any])
                       self.stripeBanks.append(stripeBank!)
                   }
                   completion(self.stripeBanks,nil)
               }
           case .failure(let error):
               if let data = response.data,
                   let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                   let dicError = dicData?["error"] as? [String: Any],
                   let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                       objStripeError.error = error
                   completion([], objStripeError)
               } else{
                   let objStripeError = NowYouError(error: error)
                   completion([],objStripeError)
               }
           }//--end--  switch response.result
       }//--end-- .responseJSON()
    }//---end: func listAllCards
   //---list all cards
   func listAllCards(customAccountId: String,
              completion : @escaping([StripeCard] ,NowYouError?) -> ()) {
       let requestString = API.STRIPE_BASEURL + API.STRIPE_CREATE_ACCOUNT + "/\(customAccountId)" + "/external_accounts?object=card"
       let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
       Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
       .validate()
       .responseJSON() { response in
           switch response.result {
           case .success:
               if let data = response.data,
                   let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                   let cardItems = json!["data"] as? [NSDictionary]
                  {
                   self.stripeCards.removeAll()
                   for card in cardItems {
                       let stripeCard = Mapper<StripeCard>().map(JSON: card as! [String : Any])
                       self.stripeCards.append(stripeCard!)
                   }
                   completion(self.stripeCards,nil)
               }
           case .failure(let error):
               if let data = response.data,
                   let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                   let dicError = dicData?["error"] as? [String: Any],
                   let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                       objStripeError.error = error
                   completion([], objStripeError)
               } else{
                   let objStripeError = NowYouError(error: error)
                   completion([],objStripeError)
               }
           }//--end--  switch response.result
       }//--end-- .responseJSON()
   }//---end: func listAllCards

    //-- create a payout
    func createPayout(amount: Int,
          currency: String,
          destination: String,
          completion : @escaping([String: Any], NowYouError?) -> ()) {
          let requestString = API.STRIPE_BASEURL + "/payouts"
          let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
          let params = ["amount": amount,
                        "currency": "usd",
                        "destination": destination] as [String : Any]
          Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
         .validate()
         .responseJSON() { response in
             switch response.result {
             case .success:
                 if let data = response.data,
                     let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                         print(dicData!)
                         completion(dicData!,nil)
                     }
                 case .failure(let error):
                     if let data = response.data,
                         let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                         let dicError = dicData?["error"] as? [String: Any],
                         let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                             objStripeError.error = error
                         completion([:], objStripeError)
                     } else{
                         let objStripeError = NowYouError(error: error)
                         completion([:],objStripeError)
                     }
             }//--end--  switch response.result
         }//--end-- .responseJSON()
      }//end -- func createPayout
    
    class func createBankAccountToken(accountHoldersName: String, routingNumber: String, accountNumber: String, completion: @escaping STPTokenCompletionBlock) {

        let bankAccountParams = STPBankAccountParams()
        
        bankAccountParams.country = "US"
        bankAccountParams.currency = "usd"
        bankAccountParams.accountHolderType = .individual
        bankAccountParams.accountHolderName = accountHoldersName
        bankAccountParams.routingNumber = routingNumber
        bankAccountParams.accountNumber = accountNumber
        
        STPAPIClient.shared().createToken(withBankAccount: bankAccountParams) { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                completion(token, nil)
            }
        }
    }
    
    class func createConnectAccountToken(ssn: String,
                                         line1: String,
                                         city: String,
                                         state: String,
                                         zipcode: String,
                                         _ completion: @escaping STPTokenCompletionBlock) {
         
        guard let phoneNu = UserManager.currentUser()!.phone else{return}
        guard let email = UserManager.currentUser()!.email else{return}
        guard let firstName = UserManager.currentUser()!.firstName else {return}
        guard let lastName = UserManager.currentUser()!.lastName else {return}
        let connectAccountIndividualParams = STPConnectAccountIndividualParams()
        let connectAccountParams = STPConnectAccountParams(tosShownAndAccepted: true, individual: connectAccountIndividualParams)
       
        connectAccountIndividualParams.phone = phoneNu
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        if let date = dateFormatter.date(from: UserManager.currentUser()!.birthday){
           connectAccountIndividualParams.dateOfBirth = Calendar.current.dateComponents([.month, .day, .year], from: date)
        }

        let address = STPConnectAccountAddress()
        address.line1 = line1
        address.city = city
        address.state = state
        address.postalCode = zipcode
            
        connectAccountIndividualParams.address = address
        connectAccountIndividualParams.idNumber = ssn
        
        connectAccountIndividualParams.ssnLast4 = String(ssn.suffix(4))
        connectAccountIndividualParams.firstName = firstName
        connectAccountIndividualParams.lastName = lastName
        connectAccountIndividualParams.email = email
        
        STPAPIClient.shared().createToken(withConnectAccount: connectAccountParams) { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                completion(token, nil)
            } else {
                completion(nil,nil)
            }
        }
    }
    
    func removeBankorCard(_ accountId: String,
                          _ id: String,
                            completion : @escaping(NowYouError?) -> ()) {
        let requestString = API.STRIPE_BASEURL + "/accounts/" +  "\(accountId)" + "/external_accounts/" + "\(id)"
        let headers: [String: String] = ["Authorization": "Bearer \(API.STRIPE_SECRET_KEY)"]
        Alamofire.request(requestString, method: .delete, parameters: nil, headers: headers)
                .validate()
                .responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let data = response.data,
                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                                print(dicData!)
                                completion(nil)
                            }
                    case .failure(let error):
                        if let data = response.data,
                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                            let dicError = dicData?["error"] as? [String: Any],
                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                                objStripeError.error = error
                            completion(objStripeError)
                        } else{
                            let objStripeError = NowYouError(error: error)
                            completion(objStripeError)
                        }
                    }//--end--  switch response.result
                }//--end-- .responseJSON()
    }//end -- func removeBankorCard
}
