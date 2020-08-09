//
//  DataBaseManager.swift
//  NowYou
//
//  Created by 222 on 2/27/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class NowYouError: Mappable {
    var error: Error!
    var type: String?
    var code: String?
    var message: String?
    var param: String?
    
    init(error: Error?) {
        self.error = error
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        type            <- map["type"]
        code            <- map["code"]
        message         <- map["message"]
        param           <- map["param"]
    }
}

class DataBaseManager: NSObject {
    static let shared = DataBaseManager()
    
    func searchRadios(keyword: String, type: Int, completion: @escaping ([RadioStation]?, NowYouError?) -> ()) {
        
        let requestString = API.SERVER + API.SERACH_RADIO_STATIONS
        let params: [String: Any] = [
            "keyword": keyword,
            "type": type]

        let headers: [String: String] = [
            "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    var radios = [RadioStation]()
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                        let radiosJson = dicData?["radio_stations"] as? [[String: Any]] {
                        for radio in radiosJson {
                            let radioStation = RadioStation(json: radio)
                            if radioStation.audios.id != 0 {
                                radios.append(RadioStation(json: radio))
                            }
                        }
                    }
                    completion(radios, nil)
                case .failure(let error):
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                        let dicError = dicData?["raw"] as? [String: Any],
                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(nil, objStripeError)
                    } else {
                        let objStripeError = NowYouError(error: error)
                        completion(nil, objStripeError)
                    }
                }
        }
    }
    func withdrawedInfoFromApp(amount: Double, completion: @escaping (NowYouError?) -> ()) {
        let requestString = API.SERVER + API.WITHDRAWED_INFO_FROM_APP
        let params: [String: Any] = ["amount": amount]

        let headers: [String: String] = ["Authorization": "Bearer \(TokenManager.getToken()!)"]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
           .validate()
           .responseJSON() { response in
               switch response.result {
               case .success:
                   completion(nil)
               case .failure(let error):
                   if let data = response.data,
                       let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                       let dicError = dicData?["error"] as? [String: Any],
                       let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                       objStripeError.error = error
                       completion(objStripeError)
                   } else {
                       let objStripeError = NowYouError(error: error)
                       completion(objStripeError)
                   }
               }
       }
    }
    
    func logRadioView(radioID: Int, completion: @escaping (NowYouError?) -> ()) {
        
        let requestString = API.SERVER + API.LOG_RADIO_STATION_VIEWS
        let params: [String: Any] = [
            "radio_station_id": radioID]

        let headers: [String: String] = [
            "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                        let dicError = dicData?["error"] as? [String: Any],
                        let objStripeError = Mapper<NowYouError>().map(JSON: dicError) {
                        objStripeError.error = error
                        completion(objStripeError)
                    } else {
                        let objStripeError = NowYouError(error: error)
                        completion(objStripeError)
                    }
                }
        }
    }
    
    func getRadioViews(radioID: Int, completion: @escaping (Int, NowYouError?) -> ()) {
        
        let requestString = API.SERVER + API.GET_RADIO_STATION_VIEWS + "?radio_station_id=\(radioID)"
//        let params: [String: Any] = [
//            "radio_id": radioID]

        let headers: [String: String] = [
            "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
            .validate()
            .responseJSON() { response in
                switch response.result {
                case .success:
                    var countViewers = 0
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                        let viewers = dicData?["views"] as? Int{
                        countViewers = viewers
                    }
                    completion(countViewers, nil)
                case .failure(let error):
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                        let dicError = dicData?["raw"] as? [String: Any],
                        let objError = Mapper<NowYouError>().map(JSON: dicError) {
                        objError.error = error
                        completion(0, objError)
                    } else {
                        let objError = NowYouError(error: error)
                        completion(0, objError)
                    }
                }
        }
    }
    
    
    func getViewers(radioID: Int, completion: @escaping (Int) -> ()) {
        logRadioView(radioID: radioID) { (_) in
            self.getRadioViews(radioID: radioID) { (viewers, error) in
                completion(viewers)
            }
        }
    }
    //----upload stripe custom_account_id or customerId
    func updateUserPaymentEmail(paymentEmail: String, completion: @escaping( NowYouError?)->()){
        let requestString = API.SERVER + API.UPDATE_USER_PAYMENT_EMAIL + "?payment_email=\(paymentEmail)"
        let headers: [String: String] = ["Authorization": "Bearer \(TokenManager.getToken()!)"]
        Alamofire.request(requestString, method: .post, parameters: nil, headers: headers)
            .validate()
            .responseJSON(){ response in
                switch response.result {
                case .success:
                    completion(nil)
                    break
                case .failure(let error):
                    if let data = response.data,
                        let dicdata = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                        let dicError = dicdata?["raw"] as? [String: Any],
                        let objcError = Mapper<NowYouError>().map(JSON: dicError){
                        objcError.error = error
                        completion(objcError)
                    }else{
                        let objError = NowYouError(error: error)
                        completion(objError)
                    }
                    break
                }
        }//----.responseJSON()--//
    }//----End func updateUserPaymentEmail
    
    //---Report post---
    func reportAPost(content: String, postId: Int, completion: @escaping( NowYouError?)->()){
        let requestString = API.SERVER + API.REPORT_A_POST
        let headers: [String: String] = ["Authorization": "Bearer \(TokenManager.getToken()!)"]
        let params: [String: Any] = ["content": content, "post_id": postId]
        
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
            .validate()
            .responseJSON(){ response in
                switch response.result {
                case .success:
                    completion(nil)
                    break
                case .failure(let error):
                    if let data = response.data,
                        let dicdata = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??),
                        let dicError = dicdata?["raw"] as? [String: Any],
                        let objcError = Mapper<NowYouError>().map(JSON: dicError){
                        objcError.error = error
                        completion(objcError)
                    }else{
                        let objError = NowYouError(error: error)
                        completion(objError)
                    }
                    break
                }
        }//----.responseJSON()--//
    }//---End func reportAPost
    
//---  Get Payment Email: (get custom account Id)
  func getPaymentEmail(completion: @escaping (String,String) -> ()) {
        
        let requestString = API.SERVER + API.GET_PAYMENT_EMAIL
    
        let headers: [String: String] = [
            "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        Alamofire.request(requestString, method: .post, parameters: nil, headers: headers)
            .validate()
            .responseJSON() { response in
             switch response.result {
                case .success:
                    if let data = response.data,
                        let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                        {
                            let paymentEmail = dicData?["payment_email"] as? String ?? ""
                            print(paymentEmail)
                            completion(paymentEmail,"")
                        }
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completion("",error.localizedDescription)
                    break
             }
        }
    }
    
    //---  Get Payment Email: (get custom account Id)
    func getMyInfo(completion: @escaping (String,String) -> ()) {
          
          let requestString = API.SERVER + API.GET_PAYMENT_EMAIL
      
          let headers: [String: String] = [
              "Authorization": "Bearer \(TokenManager.getToken()!)"
          ]
          Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
              .validate()
              .responseJSON() { response in
               switch response.result {
                  case .success:
                      if let data = response.data,
                          let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                          {
                              let paymentEmail = dicData?["payment_email"] as? String ?? ""
                              print(paymentEmail)
                              completion(paymentEmail,"")
                          }
                      break
                  case .failure(let error):
                      print(error.localizedDescription)
                      completion("",error.localizedDescription)
                      break
               }
          }
      }
    //-----Block User
    func blockUsers(blockerId: Int, completion: @escaping (String,String) -> ()) {
        let requestString = API.SERVER + API.BLOCK_USER
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params: [String: Any] = ["blocker_id": blockerId]
        
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                  if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                      {
                          completion("Successful","")
                      }
                  break
              case .failure(let error):
                
                if let data = response.data,
                    let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??){
                    let dicError = dicData?["error"] as? [String: Any]
                    completion("", "Failure")
                } else {
                    let objError = NowYouError(error: error)
                    completion("", "Failure")
                }
                  print(error.localizedDescription)
                  break
           }
        }
    }
    //---------- unblock User
    func unblockUsers(blockerId: Int, completion: @escaping (String,String) -> ()) {
        let requestString = API.SERVER + API.UNBLOCK_USER
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params: [String: Any] = ["blocker_id": blockerId]
        
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                  if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                      {
                          completion("Sucess","")
                      }
                  break
              case .failure(let error):
                if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??){
                      let dicError = dicData?["error"] as? [String: Any]
                      completion("", "Failure")
                  } else {
                      let objError = NowYouError(error: error)
                      completion("", "Failure")
                  }
                    print(error.localizedDescription)
                    break
           }
        }
    }
    
    //---------- List of blocked Users
    func getBlockerList(completion: @escaping ([SearchUser],String) -> ()) {
        let requestString = API.SERVER + API.GET_BLOCKER_LIST
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                  if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                      {
                        var blockers = [SearchUser]()
                        if let blockersJson = dicData?["blockers"] as? [[String: Any]] {
                            for blockerJson in blockersJson {
                                let blocker = User(json: blockerJson)
                                
                                var blockerPosts = [Media]()
                                if let posts = blockerJson["posts"] as? [[String: Any]] {
                                    for post in posts {
                                        let post = Media(json: post)
                                        blockerPosts.append(post)
                                    }
                                }
                                blockers.append(SearchUser(searchUser: blocker, following: false, posts: blockerPosts))
                            }
                        }
                        completion(blockers,"")
                      }
                  break
              case .failure(let error):
                if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??){
                      let dicError = dicData?["error"] as? [String: Any]
                      completion([], "")
                  } else {
                      let objError = NowYouError(error: error)
                      completion([], "Load blockers failure")
                  }
                    print(error.localizedDescription)
                    break
           }
        }
    }
    
    //-----Delete User
    func deleteUser(completion: @escaping (String,String) -> ()) {
        let requestString = API.SERVER + API.DELETE_USER
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        
        Alamofire.request(requestString, method: .post, parameters: nil, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                  if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                      {
                          completion("success","")
                      }
                  break
              case .failure(let error):
                if let data = response.data,
                     let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??){
                     let dicError = dicData?["error"] as? [String: Any]
                    
//                     let error = dicError?["blocker_id"] as? String
                     completion("", "Failure")
                 } else {
                     let objError = NowYouError(error: error)
                     completion("", "Failure")
                 }
                   print(error.localizedDescription)
                   break
           }
        }
    }
    
    //-----Delete User
    func feedCount(completion: @escaping (String,String) -> ()) {
        let requestString = API.SERVER + API.DELETE_USER
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        
        Alamofire.request(requestString, method: .post, parameters: nil, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                  if let data = response.data,
                      let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                      {
                          completion("success","")
                      }
                  break
              case .failure(let error):
                if let data = response.data,
                     let dicData = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??){
                     let dicError = dicData?["error"] as? [String: Any]
                    
//                     let error = dicError?["blocker_id"] as? String
                     completion("", "Failure")
                 } else {
                     let objError = NowYouError(error: error)
                     completion("", "Failure")
                 }
                   print(error.localizedDescription)
                   break
           }
        }
    }
    //---------- List of blocked Users
    func getViralFeed(pageId: Int, completion: @escaping ([Media],String) -> ()) {
        var feedPosts = [Media]()
        let requestString = API.SERVER + API.GET_VIRAL_DATA
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params : [String: Int] = ["page":pageId]
        Alamofire.request(requestString, method: .get, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                let json = jsonRes as? [String: Any] {
                    if let feedItems = json["popular_feeds"] as? [NSDictionary]{
                       print(feedItems.count)
                       for feed in feedItems {
                            let post = Media(json: feed as! [String : Any])
                            var bAdded: Bool = false
                            for existingPost in feedPosts {
                                if post.id == existingPost.id {
                                    bAdded = true
                                    break
                                }
                            }
                            if !bAdded {
                                feedPosts.append(post)
                            }
                       }
                    }
                    completion(feedPosts,"")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    //                    let dicError = dicData?["error"] as? [String: Any]
                      completion([], "")
                } else {
                    completion([], "Load blockers failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
    
    func getFeedData(pageId: Int, completion: @escaping ([Media],String) -> ()) {
        var feedPosts = [Media]()
        let requestString = API.SERVER + API.GET_FEED_DATA
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params : [String: Int] = ["page": pageId]
        Alamofire.request(requestString, method: .get, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any] {
                    if let feedItems = json["feeds"] as? [NSDictionary]{
                       print(feedItems.count)
                       for feed in feedItems {
                            let post = Media(json: feed as! [String : Any])
                            var bAdded: Bool = false
                            for existingPost in feedPosts {
                                if post.id == existingPost.id {
                                    bAdded = true
                                    break
                                }
                            }
                            if !bAdded {
                                feedPosts.append(post)
                            }
                       }
                    }
                    completion(feedPosts,"")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? [String: Any]
                    completion([], "Load Feed Data failure")
                } else {
                    completion([], "Load Feed Data failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
    
    func getTagData(pageId: Int, completion: @escaping ([Media],String) -> ()) {
        var feedPosts = [Media]()
        let requestString = API.SERVER + API.GET_TAG_DATA
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params : [String: Int] = ["page": pageId]
        Alamofire.request(requestString, method: .get, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any] {
                    if let feedItems = json["feeds"] as? [NSDictionary]{
                       print(feedItems.count)
                       for feed in feedItems {
                            let post = Media(json: feed as! [String : Any])
                            var bAdded: Bool = false
                            for existingPost in feedPosts {
                                if post.id == existingPost.id {
                                    bAdded = true
                                    break
                                }
                            }
                            if !bAdded {
                                feedPosts.append(post)
                            }
                       }
                    }
                    completion(feedPosts,"")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? [String: Any]
                    completion([], "Load Tag Data failure")
                } else {
                    completion([], "Load Tag Data failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }

//---------related to HashTag
    func followHashTag(tagId: Int, completion: @escaping (String,String) -> ()) {

        let requestString = API.SERVER + API.FOLLOW_HASHTAG
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params : [String: Int] = ["tag_id": tagId]
        
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any] {
                    let success = json["success"] as? String
                    completion(success ?? "","")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? String
                    completion("", "Follow Tag failure")
                } else {
                    completion("", "Follow Tag failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
    
    func unfollowHashTag(tagId: Int, completion: @escaping (String,String) -> ()) {

        let requestString = API.SERVER + API.UNFOLLOW_HASHTAG
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        let params : [String: Int] = ["tag_id": tagId]
        
        Alamofire.request(requestString, method: .post, parameters: params, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any] {
                    let success = json["success"] as? String
                    completion(success ?? "","")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? String
                    completion("", "UnFollow Tag failure")
                } else {
                    completion("", "UnFollow Tag failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
    
    func getAllHashTags(tagId: Int, completion: @escaping (String,String) -> ()) {

        let requestString = API.SERVER + API.GET_ALL_HASHTAGS
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        
        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any] {

                    completion("","")
                }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? [String: Any]
                    completion("", "Load Tag Data failure")
                } else {
                    completion("", "Load Tag Data failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
    
    func getFollowingHashTags(completion: @escaping ([Tag],String) -> ()) {
        var followingTags = [Tag]()
        let requestString = API.SERVER + API.GET_FOLLOWING_HASHTAGS
        let headers: [String: String] = [
          "Authorization": "Bearer \(TokenManager.getToken()!)"
        ]
        
        Alamofire.request(requestString, method: .get, parameters: nil, headers: headers)
          .validate()
          .responseJSON() { response in
           switch response.result {
              case .success:
                if let data = response.data,
                   let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                   let json = jsonRes as? [String: Any] {
                       if let tags = json["hashtags"] as? [NSDictionary]{
                          print(tags.count)
                          for tag in tags {
                               let followingTag = Tag(json: tag as! [String : Any])
                               var bAdded: Bool = false
                               for existingTag in followingTags {
                                   if followingTag.id == existingTag.id {
                                       bAdded = true
                                       break
                                   }
                               }
                               if !bAdded {
                                   followingTags.append(followingTag)
                               }
                          }
                       }
                       completion(followingTags,"")
                   }
              case .failure(let error):
                if let data = response.data,
                    let jsonRes = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)),
                    let json = jsonRes as? [String: Any]{
                    let dicError = json["error"] as? [String: Any]
                    completion([], "Load Tag Data failure")
                } else {
                    completion([], "Load Tag Data failure")
                }
                print(error.localizedDescription)
                break
           }
        }
    }
}
