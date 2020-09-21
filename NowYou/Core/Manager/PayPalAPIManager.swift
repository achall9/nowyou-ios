//
//  PayPalAPIManager.swift
//  NowYou
//
//  Created by 111 on 2020/9/19.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
class PayPalAPIManager: NSObject {
    static let shared = PayPalAPIManager()
    var accessToken: String?
    required override init() {
    }
    func getToken(_ completion: @escaping(String? ,NowYouError?) -> ()) {

        let requestString = Constant.PayPal.URL.token
        let params: Parameters = ["grant_type": "client_credentials"]
        let credentialData = "\(Constant.PayPal.clientId):\(Constant.PayPal.secret)".data(using: String.Encoding.utf8)
        let base64Credentials = credentialData?.base64EncodedString(options: [])
        let headers : HTTPHeaders = ["Authorization": "Basic \(base64Credentials ?? "")"]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result{
                case .success:
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                            print(dicData!["access_token"] ?? "")
                            let token  = dicData!["access_token"] as! String
                        self.accessToken = token
                            completion(token,nil)
                        }
                    case .failure(let error):
                        if let data = response.data,
                            let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                            let dicError = dicData?["error"] as? [String: Any],
                            let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                                objStripeError.error = error
                            completion(nil, objStripeError)
                        } else{
                            let objStripeError = NowYouError(error: error)
                            completion(nil,objStripeError)
                        }
                }//--end--  switch response.result
            }//--end-- .responseJSON()
    }
    
    func createPayout(email: String, amount: Double, _ completion: @escaping(Bool ,NowYouError?) -> ()){
        guard let token = self.accessToken else{
            completion(false, nil)
            return
        }
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd"
        let formatterDate = format.string(from: Date())
        let requestString = Constant.PayPal.URL.payout
        let headers : HTTPHeaders = ["Authorization": "Bearer " + token]
        let params: [String: Any] = [
            "sender_batch_header":["sender_batch_id": "\(email)\(formatterDate)", "email_subject": "You have a payout!"],
            "items": [["recipient_type": "EMAIL",
                     "receiver": email,
            "amount":[
                "currency": "USD",
                "value": "\(amount)"
            ]
            ]]
        ]
        Alamofire.request(requestString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result{
            case .success:
                if let data = response.data,
                    let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??){
                        completion(true, nil)
                    }
                case .failure(let error):
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                        let dicError = dicData?["error"] as? [String: Any],
                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                            objStripeError.error = error
                        completion(false, objStripeError)
                    } else{
                        let objStripeError = NowYouError(error: error)
                        completion(false,objStripeError)
                    }
            }//--end--  switch response.result
        }//--end-- .responseJSON()
        
    }
    
}
