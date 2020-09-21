//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import WSTagsField

enum RestRouter: RestAPIProtocol {
    // push
    case updatePushToken(device_token: String)
    case sharePost(id: Int)
    // notification
    case getNotifications
    // get all users
    case getAllUsers(pageNum: Int)
    // know if email/phone is duplicate or not
    case is_email_phone_duplicate(email: String, phone: String, user_name: String)
    // auth
    case login(email: String, password: String)
    case passwordReset(email: String)
    
    case register(firstName: String, lastName: String, email: String, password: String, phone: String, device_token: String, birthday: String, gender: Int, username: String, privateOn: Int, bio: String)
    case activate(code: String)
    case resetPassword(resetCode: String, password: String, confirmPwd: String)
    case getAdditionalAccounts(main_user_id: String)
    case createAdditionalAccount(main_user_id: String, first_name: String, last_name: String, user_name: String, password: String, bio: String, photo: Data)
    // profile
    case changePassword(password: String, confirmPassword: String)
    case userDetails(userId: Int)
    case updateProfile(email: String, firstName: String, lastName: String, phone: String, birthday: String, photo: Data, color: String, username: String, gender: Int, privateOn: Int, bio: String)
    case getPosts
    case removePosts(mediaId: Int)
    
    // user
    case search(keyword: String)
    case follow(userId: Int)
    case unfollow(userId: Int)
    case getFollowers
    case getFollowings
    case isFollowing(user_id: Int)
    case getUserDetails(user_id: Int)
    case getMyCashInfo
    
    // feed
    case postMedia(hash_tag: [String], description: String, forever: Bool, isVideo: Bool, thumbnail: Data?, media: Data, link: String, user_id: Int, screen_w: Int, screen_h: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, angle: Float, scale: CGFloat, taggedUserId: [String])
    case getFeeds
    
    case getFeedData(page: Int)
    case getViralData(page: Int)
    case getTagData(page: Int)
    
    case getFilteredStories
    case getOthersFeeds(userId: Int)
    case like(mediaId: Int)
    case unlike(mediaId: Int)
    case comment(mediaId: Int, comment: String)
    case getComments(feed_id: Int)
    case logViewFeed(mediaId: Int)
    case uploadVideoToFeed(feed_id: Int, videoData: Data, link: String, screen_w: Int, screen_h: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, angle: CGFloat, scale: CGFloat)
    // radio
    case createCategory(name: String, logo: Data)
    case getCategories

    case createRadio(category_id: Int, name: String, tags: [WSTag])
    case logRadioView(radio_id: Int)
    case postRadioComment(radio_id: Int, comment: String)
    case getRadioComments(radio_id: Int)
    case searchRadio(keyword: String, searchType:Int)
    
    //radio statiom
    case createNewRadioStation(category_id : Int, name : String, hash_tag : [WSTag])
    case getRadiosByCategory(category_id: Int)
    case uploadRadioFile(radio_station_id: Int, name : String, audio: Data)
    case searchRadioStations(keyword: String)
    case popularRadioStations(limit : Int)
    
    case getRadioStation(radio_station_id: Int)
    case startingARadioRecording(radio_station_id: Int)
    case finishedRecording(radio_station_id : Int)
    case requestListen(radio_station_id: Int)
    case rejectListen(radio_station_id: Int)
    
    case logAdView(post_id: Int, type: Int, click_ad: Int)

    var url: URL {
        switch self {
        case .is_email_phone_duplicate:
            return URL(string: API.SERVER + API.IS_EMAIL_PHONE_DUPLICATE)!
        case .login:
            return URL(string: API.SERVER + API.LOGIN)!
        case .passwordReset:
            return URL(string: API.SERVER + API.PASSWORD_RESET)!
        case .register:
            return URL(string: API.SERVER + API.REGISTER)!
        case .activate(let code):
            return URL(string: API.SERVER + API.ACTIVATE + "?/code=\(code)")!
        case .resetPassword:
            return URL(string: API.SERVER + API.RESET_PWD)!
        case .getAdditionalAccounts:
            return URL(string: API.SERVER + API.GET_ADDITIONAL_ACCOUNTS)!
        case .createAdditionalAccount:
            return URL(string: API.SERVER + API.CREATE_ADDITIONAL_ACCOUNT)!
        case .changePassword:
            return URL(string: API.SERVER + API.CHANGE_PWD)!
        case .userDetails:
            return URL(string: API.SERVER + API.USER_DETAILS)!
        case .updateProfile:
            return URL(string: API.SERVER + API.PROFILE_UPDATE)!
        case .getPosts:
            return URL(string: API.SERVER + API.GET_POSTS)!
        case .removePosts:
            return URL(string: API.SERVER + API.REMOVE_POSTS)!
        case .search:
            return URL(string: API.SERVER + API.USER_SEARCH)!
        case .follow:
            return URL(string: API.SERVER + API.USER_FOLLOW)!
        case .unfollow:
            return URL(string: API.SERVER + API.USER_UNFOLLOW)!
        case .getFollowers:
            return URL(string: API.SERVER + API.USER_FOLLOWERS)!
        case .getFollowings:
            return URL(string: API.SERVER + API.USER_FOLLOWINGS)!
        case .isFollowing:
            return URL(string: API.SERVER + API.IS_FOLLOWING)!
        case .getFeeds:
            return URL(string: API.SERVER + API.GET_FEED)!
            
        case .getFeedData(let page):
            return URL(string: API.SERVER + API.GET_FEED_DATA + "?page=\(page)")!
        case .getViralData(let page):
             return URL(string: API.SERVER + API.GET_VIRAL_DATA + "?page=\(page)")!
        case .getTagData(let page):
             return URL(string: API.SERVER + API.GET_TAG_DATA + "?page=\(page)")!
            
        case .getFilteredStories:
               return URL(string: API.SERVER + API.GET_FILTERED_FEEDS)!
        case .postMedia:
            return URL(string: API.SERVER + API.POST_MEDIA)!
        case .getOthersFeeds:
            return URL(string: API.SERVER + API.GET_OTHER_FEEDS)!
        case .like:
            return URL(string: API.SERVER + API.LIKE)!
        case .unlike:
            return URL(string: API.SERVER + API.UNLIKE)!
        case .comment:
            return URL(string: API.SERVER + API.COMMENT)!
        case .getComments(let feed_id):
            return URL(string: API.SERVER + API.GET_COMMENT + "/\(feed_id)")!
        case .logViewFeed:
            return URL(string: API.SERVER + API.LOG_FEED_VIEW)!
        case .createCategory:
            return URL(string: API.SERVER + API.CREATE_CATEGORY)!
        case .getCategories:
            return URL(string: API.SERVER + API.GET_CATEGORIES)!
        case .createRadio:
            return URL(string: API.SERVER + API.CREATE_RADIO)!
        case .logRadioView:
            return URL(string: API.SERVER + API.LOG_RADIO_VIEW)!
        case .postRadioComment:
            return URL(string: API.SERVER + API.POST_RADIO_COMMENT)!
        case .getRadioComments:
            return URL(string: API.SERVER + API.GET_RADIO_COMMENT)!
        case .uploadVideoToFeed:
            return URL(string: API.SERVER + API.UPLOAD_VIDEO_TO_FEED)!
        case .getUserDetails(let user_id):
            return URL(string: API.SERVER + API.USER_DETAIL + "/\(user_id)")!
        case .sharePost(let postId):
            return URL(string: API.SERVER + API.SHARE_POST)!
        case .getMyCashInfo:
            return URL(string: API.SERVER + API.USER_MYINFO)!
        case .updatePushToken:
            return URL(string: API.SERVER + API.DEVICE_TOKEN)!
        case .getNotifications:
            return URL(string: API.SERVER + API.GET_NOTIFICATIONS)!
        case .getAllUsers(let pageNum):
            return URL(string: API.SERVER + API.GET_ALL_USER)!
        case .searchRadio(let keyword, let searchType):
            return URL(string: API.SERVER + API.RADIO_SEARCH)!
            
        // radio station--2020
            
        case .createNewRadioStation :
            return URL(string: API.SERVER + API.CREATE_NEW_RADIO_STATION)!
        case .getRadiosByCategory(let category_id):
            return URL(string: API.SERVER + API.GET_RADIO_BY_CATEGORY + "?category_id=\(category_id)")!
        case .uploadRadioFile:
            return URL(string: API.SERVER + API.UPLOAD_RADIO_FILE)!
        case .searchRadioStations :
            return URL(string: API.SERVER + API.SERACH_RADIO_STATIONS)!
        case .popularRadioStations :
            return URL(string: API.SERVER + API.POPULAR_RADIO_STATION)!
        case .getRadioStation(let radio_station_id):
            return URL(string: API.SERVER + API.GET_RADIO_STATION_INFO + "?radio_station_id=\(radio_station_id)")!
        case .startingARadioRecording:
            return URL(string: API.SERVER + API.STARTING_A_RADIO_RECORDIGN)!
        case .finishedRecording:
            return URL(string: API.SERVER + API.FINISHED_RECORDING)!
        case .requestListen:
            return URL(string: API.SERVER + API.REQUEST_LISTEN)!
        case .rejectListen:
            return URL(string: API.SERVER + API.REJECT_LISTEN)!
        case .logAdView(let post_id, let type, let click_ad):
            return URL(string: API.SERVER + API.LOG_AD_VIEW + "?post_id=\(post_id)" + "&type=\(type)" + "&click_ad=\(click_ad)")!
       
        }
    }
    
    var method: String {
        switch self {
        case .is_email_phone_duplicate:
            return "POST"
            
        case .login:
            return "POST"
        case .passwordReset:
            return "POST"
            
        case .register:
            return "POST"
        case .activate:
            return "GET"
        case .resetPassword:
            return "POST"
        case .getAdditionalAccounts:
            return "POST"
        case .createAdditionalAccount:
            return "POST"
        case .changePassword:
            return "POST"
        case .userDetails:
            return "POST"
        case .updateProfile:
            return "POST"
        case .getPosts:
            return "GET"
        case .removePosts:
            return "POST"
        case .search:
            return "POST"
        case .follow:
            return "POST"
        case .unfollow:
            return "POST"
        case .getFollowers:
            return "GET"
        case .getFollowings:
            return "GET"
        case .isFollowing:
            return "POST"
        case .postMedia:
            return "POST"
        case .getFeeds:
            return "GET"
            
        case .getFeedData:
            return "GET"
        case .getTagData:
            return "GET"
        case .getViralData:
            return "GET"
            
        case .getFilteredStories:
            return "GET"
        case .getOthersFeeds:
            return "POST"
        case .like:
            return "POST"
        case .unlike:
            return "POST"
        case .comment:
            return "POST"
        case .getComments:
            return "GET"
        case .logViewFeed:
            return "POST"
        case .createCategory:
            return "POST"
        case .getCategories:
            return "GET"
//        case .getRadiosByCategory:
//            return "GET"
        case .createRadio:
            return "POST"
//        case .uploadRadio:
//            return "POST"
        case .logRadioView:
            return "POST"
            
        case .postRadioComment:
            return "POST"
        case .getRadioComments:
            return "GET"
//        case .getTop100:
//            return "GET"
        case .uploadVideoToFeed:
            return "POST"
        case .getUserDetails:
            return "GET"
        case .sharePost:
            return "POST"
        case .getMyCashInfo:
            return "GET"
        case .updatePushToken:
            return "POST"
        case .getNotifications:
            return "GET"
        case .getAllUsers:
            return "GET"
        case .searchRadio(let keyword, let searchType):
            return "POST"
        // radio station 2020
        case .createNewRadioStation :
            return "POST"
        case .getRadiosByCategory:
            return "GET"
        case .uploadRadioFile:
            return "POST"
        case .searchRadioStations(let keyword):
            return "POST"
        case .popularRadioStations( _):
            return "GET"
        
        case .getRadioStation:
            return "GET"
        case .startingARadioRecording:
            return "POST"
        case .finishedRecording:
            return "POST"
        case .requestListen:
            return "POST"
        case .rejectListen:
            return "POST"
        case .logAdView:
            return "POST"

        }
    }
    
    var param: Parameters {
        switch self {
        case .is_email_phone_duplicate:
            return [:]
        case .login:
            return [:]
        case .passwordReset:
            return [:]
        case .register(let firstName, let lastName, let email, let password, let phone, let token, let birthday, let gender, let username, let privateOn, let bio):
            return ["first_name": firstName, "last_name": lastName, "email": email, "password": password, "c_password": password, "phone": phone, "device_token": token, "birthday": birthday, "gender": gender, "user_name": username, "privateOn": privateOn, "bio": bio]
        case .activate:
            return [:]
        case .resetPassword:
            return [:]
        case .getAdditionalAccounts:
            return [:]
        case .createAdditionalAccount(let main_user_id, let first_name, let last_name, let user_name, let password, let bio, _):
            return ["main_user_id": main_user_id,
                    "first_name"  : first_name,
                    "last_name"   : last_name,
                    "user_name"   : user_name,
                    "password"    : password,
                    "bio"         : bio
            ]
        case .changePassword:
            return [:]
        case .userDetails:
            return [:]
        case .updateProfile(let email, let firstName, let lastname, let phone, let birthday, _, let color, let username, let gender, let privateOn, let bio):
            return ["email": email, "first_name": firstName, "last_name": lastname, "phone": phone, "birthday": birthday, "color": color, "user_name": username, "gender": gender, "privateOn": privateOn, "bio": bio]
        case .getPosts:
            return [:]
        case .removePosts:
            return [:]
        case .search:
            return [:]
        case .follow:
            return [:]
        case .unfollow:
            return [:]
        case .getFollowers:
            return [:]
        case .getFollowings:
            return [:]
        case .isFollowing:
            return [:]
        case .postMedia(let hash_tag, let description, let forever, _, _,  _, let link, let user_id, let screen_w, let screen_h, let x, let y, let width, let height, let angle, let scale, let taggedUserId):
            return ["hash_tag": hash_tag, "description": description, "forever": forever ? "1" : "0", "link": link, "user_id": user_id, "screen_w": screen_w, "screen_h": screen_h, "x": x, "y": y, "width": width, "height": height, "angle": angle, "scale": scale, "taggedUserId": taggedUserId]
        case .getFeeds:
            return [:]
            
        case .getFeedData:
             return [:]
        case .getViralData:
            return [:]
        case .getTagData:
            return [:]
            
        case .getFilteredStories:
            return [:]
        case .getOthersFeeds:
            return [:]
        case .like:
            return [:]
        case .unlike:
            return [:]
        case .comment:
            return [:]
        case .getComments:
            return [:]
        case .getRadioComments:
            return [:]
        case .logViewFeed:
            return [:]
        case .createCategory(let name, _):
            return ["name": name]
        case .getCategories:
            return [:]
//        case .getRadiosByCategory:
//            return [:]
        case .createRadio(let category_id, let name, let tags):
            var tagStrings = [String]()
            for tag in tags {
                tagStrings.append(tag.text)
            }

            return ["category_id": "\(category_id)",
                "name": name, "hash_tag": tagStrings] as [String : Any]
//        case .uploadRadio(let radio_id, _):
//            return ["radio_id": "\(radio_id)"]
        case .logRadioView:
            return [:]
        case .postRadioComment:
            return [:]
//        case .getTop100:
//            return [:]
        case .uploadVideoToFeed(let feed_id, _, let link, let screen_w, let screen_h, let x, let y, let width, let height, let angle, let scale):
            return ["feed_id": "\(feed_id)", "link": link, "screen_w": screen_w, "screen_h": screen_h, "x": x, "y": y, "width": width, "height": height, "angle": angle, "scale": scale]
        case .getUserDetails(_):
            return [:]
        case .sharePost(let postId):
            return ["id": postId]
        case .getMyCashInfo:
            return [:]
        case .updatePushToken:
            return [:]
        case .getNotifications:
            return [:]
        case .getAllUsers:
            return [:]
        case .searchRadio(let keyword, let searchType):
        return ["type": searchType, "keyword": keyword]

        // radio station 2020
        case .createNewRadioStation(let category_id,let name,let hash_tag):
            var tagStrings = [String]()
            for tag in hash_tag {
                tagStrings.append(tag.text)
            }
//            return [:]
            return ["category_id": category_id, "name": name, "hash_tag": tagStrings]
        case .getRadiosByCategory:
            return [:]
        case .uploadRadioFile(let radio_station_id, let name, _):
            return ["radio_station_id": "\(radio_station_id)", "name" : name]
        case .searchRadioStations(let keyword):
            return [:]
        case .popularRadioStations(let limit):
            return ["limit":"\(limit)"]
            
        case .getRadioStation(let radio_station_id):
            return [:]
        case .startingARadioRecording(let radio_station_id):
             return ["radio_station_id": "\(radio_station_id)"]
        case .finishedRecording(let radio_station_id):
            return ["radio_station_id": "\(radio_station_id)"]
        case .requestListen(let radio_station_id):
            return ["radio_station_id": "\(radio_station_id)"]
        case .rejectListen(let radio_station_id):
            return ["radio_station_id": "\(radio_station_id)"]
            
        case .logAdView(let post_id, let type, let click_ad):
            return ["post_id":post_id, "type":type, "click_ad": click_ad]
        }
       
    }
    
    var body: Data? {
        switch self {
        case .is_email_phone_duplicate(let email, let phone, let user_name):
            
            var data = Data()
            
            
            let param = ["email": email, "phone": phone, "user_name": user_name]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                return data
            } catch let error {
                print(error.localizedDescription)
            }
            
            return nil
            
            
        case .login(let email, let password):
            var data = Data()
            
            var token: String = ""
            if let deviceToken = UserDefaults.standard.value(forKey: "currentFCMTokenKey") as? String {
                token = deviceToken
            }
            let param = ["email": email, "password": password, "push_token": token]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                return data
            } catch let error {
                print(error.localizedDescription)
            }
            
            return nil
            
        case .passwordReset(let email):
            var data = Data()
            
            
            let param = ["email": email]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                return data
            } catch let error {
            }
            
            return nil
            
        case .register(let firstName, let lastName, let email, let password, let phone, let deviceToken, let birthday, let gender, let username, let privateOn, let bio):
            var data = Data()
            
            var token: String = ""
            //if let deviceToken = UserDefaults.standard.value(forKey: USER.DEVICE_TOKEN) as? String {
            if let deviceToken = UserDefaults.standard.value(forKey: "currentFCMTokenKey") as? String {
                token = deviceToken
            }
            
            let param = ["first_name": firstName, "last_name": lastName, "email": email, "user_name": username,"password": password, "c_password": password, "phone": phone, "birthday": birthday, "gender": gender, "device_token": deviceToken, "push_token": token, "privateOn": privateOn, "bio": bio] as [String : Any]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                return data
            } catch let error {
            }
            
            return nil
            
        case .activate:
            return nil
            
        case .resetPassword(let resetCode, let password, let confirmPwd):
            var data = Data()
            let param = ["reset_code": resetCode, "password": password, "confirm_password": confirmPwd]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {

                return nil
            }
            
            
        case .getAdditionalAccounts(let main_user_id):
            var data = Data()
            let param = ["main_user_id": main_user_id]
            /*
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                return nil
            }
             */
            for (key, value) in param {
                data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            return data
        
        case .createAdditionalAccount(_, _, _, _, _, _, let photo):
            var data = Data()
            for (key, value) in param {
                data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
            
            // using as image name timestamp in UNIX format
            let tempFileName = Int(Date().timeIntervalSince1970).description + ".png"
            data.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
            
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(photo)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
             
            return data
            
        case .changePassword(let password, let confirmPwd):
            var data = Data()
            let param = ["password": password,
                         "confirm_password": confirmPwd]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                
                return nil
            }

        case .userDetails(let userId):
            var data = Data()
            let param = ["user_id": userId]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                
                return nil
            }
            
        case .updateProfile(_, _, _, _, _, let photo, _, _, _, let privateOn, let bio):
            var data = Data()
            for (key, value) in param {
                data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
            
            // using as image name timestamp in UNIX format
            let tempFileName = Int(Date().timeIntervalSince1970).description + ".png"
            data.append("Content-Disposition: form-data; name=\"photo\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
            
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(photo)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            return data

        case .getPosts:
            return nil
            
        case .removePosts(let mediaId):
            var data = Data()
            
            data.append("feed_id=\(mediaId)".data(using: .utf8)!)
            
            return data
            
        case .search(let keyword):
            var data = Data()

            data.append("keyword=\(keyword)".data(using: .utf8)!)
            
            return data
            
        case .follow(let userId):
            var data = Data()
            
            data.append("user_id=\(userId)".data(using: .utf8)!)
            
            return data
            
        case .unfollow(let userId):
            var data = Data()
            
            data.append("user_id=\(userId)".data(using: .utf8)!)
            
            return data
            
        case .getFollowers:
            
            return nil
            
        case .getFollowings:
            
            return nil
            
        case .isFollowing:
            
            return nil

        case .postMedia(let hash_tag, _, _, let isVideo, let thumbnail, let media, _, let user_id, _, _, _, _, _, _, _, _, let taggedUserId):
                    
            var data = Data()
            for (key, value) in param {
                
                if key == "hash_tag" {
                    var index: Int  = 0
                    for hashTag in hash_tag {
                        if hashTag != ""{
                          data.append("--\(boundary)\r\n".data(using: .utf8)!)
                          data.append("Content-Disposition: form-data; name=\"hash_tag[\(index)]\"\r\n\r\n".data(using: .utf8)!)
                          data.append("\(hashTag)\r\n".data(using: .utf8)!)
                          data.append("\r\n".data(using: .utf8)!)
                          index += 1
                        }
                    }
                } else if key == "taggedUserId" {
                    var index: Int  = 0
                    for tag in taggedUserId {
                        if tag != "" {
                          data.append("--\(boundary)\r\n".data(using: .utf8)!)
                          data.append("Content-Disposition: form-data; name=\"taggedUserId[\(index)]\"\r\n\r\n".data(using: .utf8)!)
                          data.append("\(tag)\r\n".data(using: .utf8)!)
                          data.append("\r\n".data(using: .utf8)!)
                          index += 1
                        }
                    }
                } else {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)\r\n".data(using: .utf8)!)
                }
            }
            data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
//             using as image name timestamp in UNIX format
            let tempFileName = Int(Date().timeIntervalSince1970).description + (isVideo ? ".mp4" : ".png")
            let mimeType = isVideo ? "video/mp4" : "image/png"
            data.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            data.append(media)
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            
            let thumbnailName = Int(Date().timeIntervalSince1970).description + ".png"
            
            if thumbnail != nil {
                data.append("Content-Disposition: form-data; name=\"thumbnail\"; filename=\"\(thumbnailName)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                data.append(thumbnail!)
                data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            }
            return data

        case .getFeeds:
            return nil
            
        case .getFeedData:
                return nil
        case .getViralData:
            return nil
        case .getTagData:
            return nil
            
        case .getFilteredStories:
            return nil
        case .getOthersFeeds:
            return nil
            
        case .like(let mediaId):
            var data = Data()
            
            data.append("feed_id=\(mediaId)".data(using: .utf8)!)

            return data
            
        case .unlike(let mediaId):
            
            var data = Data()
            data.append("feed_id=\(mediaId)".data(using: .utf8)!)
            return data
            
        case .comment(let mediaId, let comment):
            var data = Data()
            data.append(("feed_id=\(mediaId)&message=\(comment)").data(using: .utf8)!)

            return data
            
        case .getComments:
            return nil
            
        case .getRadioComments:
            return nil
            
        case .logViewFeed(let mediaId):
            var data = Data()
            data.append("feed_id=\(mediaId)".data(using: .utf8)!)
            return data
        case .createCategory(_, let logo):
            var data = Data()
            for (key, value) in param {
                data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
            
            // using as image name timestamp in UNIX format
            let tempFileName = Int(Date().timeIntervalSince1970).description + ".png"
            data.append("Content-Disposition: form-data; name=\"logo\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
            
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(logo)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            return data
        case .getCategories:
            return nil
            
//        case .getRadiosByCategory:
//            return nil
            
        case .createRadio(let category_id, let name, let tags):
            var data = Data()

            var tagStrings = [String]()
            for tag in tags {
                tagStrings.append(tag.text)
            }

            let param = ["category_id": "\(category_id)",
                "name": name, "hash_tag": tagStrings] as [String : Any]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                print(error.localizedDescription)

                return nil
            }
//        case .uploadRadio(_, let audio):
//            var data = Data()
//            for (key, value) in param {
//                data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
//                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
//                data.append("\(value)\r\n".data(using: .utf8)!)
//            }
//
//            data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
//
//            // using as image name timestamp in UNIX format
//            let tempFileName = Int(Date().timeIntervalSince1970).description + ".m4a"
//            data.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
//
//            data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
//            data.append(audio)
//            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//            return data
            
        case .uploadRadioFile(_, _, let audio):
             var data = Data()
             for (key, value) in param {
                 data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
                 data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                 data.append("\(value)\r\n".data(using: .utf8)!)
             }
             
             data.append("\r\n--\(self.boundary)\r\n".data(using: .utf8)!)
             
             // using as image name timestamp in UNIX format
             let tempFileName = Int(Date().timeIntervalSince1970).description + ".m4a"
             data.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
             
             data.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
             data.append(audio)
             data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
             return data
        case .logRadioView(let radio_id):
            var data = Data()
            
            data.append("radio_id=\(radio_id)".data(using: .utf8)!)
            
            return data
        case .postRadioComment(let radio_id, let comment):
            var data = Data()
            let param = ["radio_id": radio_id,
                         "comment": comment] as [String : Any]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                print(error.localizedDescription)
                
                return nil
            }
//        case .getTop100:
//            return nil
        case .uploadVideoToFeed(_, let videoData, _, _, _, _, _, _, _, _, _):
            var data = Data()
            for (key, value) in param {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
            
            //             using as image name timestamp in UNIX format
            
            let tempFileName = Int(Date().timeIntervalSince1970).description + ".mp4"
            let mimeType = "video/mp4"
            data.append("Content-Disposition: form-data; name=\"media\"; filename=\"\(tempFileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            data.append(videoData)
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            
            return data
        case .getUserDetails:
            return nil
        case .sharePost(let id):
            var data = Data()
            data.append("id=\(id)".data(using: .utf8)!)
            return data
        case .getMyCashInfo:
            return nil
        case .updatePushToken(let device_token):
            
            var data = Data()
            data.append("push_token=\(device_token)".data(using: .utf8)!)
            data.append("&undefined=undefined".data(using: String.Encoding.utf8)!)
            return data            
        case .getNotifications:
            return nil
        case .getAllUsers:
            return nil
        case .searchRadio(let keyword, let searchType):
            var data = Data()
            
            for (key, value) in param {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)\r\n".data(using: .utf8)!)
            }
            
            data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
            return data
        // radio Station 2020
        case .createNewRadioStation(let category_id, let name, let hash_tag):
            var data = Data()

            var tagStrings = [String]()
            for tag in hash_tag {
                tagStrings.append(tag.text)
            }

            let param = ["category_id": "\(category_id)",
                "name": name, "hash_tag": tagStrings] as [String : Any]
            do {
                data = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                return data
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        case .getRadiosByCategory:
            return nil
            
        case .searchRadioStations(let keyword):
            var data = Data()
            
            data.append("keyword=\(keyword)".data(using: .utf8)!)
            
            return data
        case .popularRadioStations:
            return nil
            
        case .getRadioStation:
            return nil
        case .startingARadioRecording:
            return nil
        case .finishedRecording:
            return nil
        case .requestListen:
            return nil
        case .rejectListen:
            return nil
            
        case .logAdView:
            return nil
        }


    }
    var boundary: String {
        return "---------------------------14737809831466499882746641449"
    }
    var queryItems: [URLQueryItem]? {
        return nil
    }
    var description: String {
        return ""
    }
}
