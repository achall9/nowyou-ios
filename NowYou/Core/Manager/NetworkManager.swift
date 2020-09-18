//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import WSTagsField

/// Singleton class pattern
class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
//    private let reachability = Reachability(hostname: API.HOST)
//
//    var isReachableNetwork: Bool {
//        return reachability?.connection != .none
//    }
    
    var dataTask: URLSessionDataTask?
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600
        configuration.timeoutIntervalForResource = 600
        let newSession = URLSession(configuration: configuration)
        return newSession
    }()
    
    private override init() {
        super.init()
        // Now simply running for any case
//        try? reachability?.startNotifier()
    }
    
    deinit {
//        reachability?.stopNotifier()
    }
    
    func is_email_phone_duplicate(email: String, phone: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.is_email_phone_duplicate(email: email, phone: phone)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        call(request, completion: completion)
    }
    
    func login(email: String, password: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.login(email: email, password: password)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        call(request, completion: completion)
    }
    
    func passwordReset(email: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.passwordReset(email: email)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        call(request, completion: completion)
    }
    
    func register(first_name: String, last_name: String, email: String, password: String, phone: String, device_token: String, birthday: String, gender: Int, username: String, privateOn: Int, bio: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.register(firstName: first_name, lastName: last_name, email: email, password: password, phone: phone, device_token: device_token, birthday: birthday, gender: gender, username: username, privateOn: privateOn, bio: bio)
        
        var request = URLRequest(url: rest.url)

        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        call(request, completion: completion)
    }
    
    func activate(active_code: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.activate(code: active_code)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func resetPassword(reset_code: String, password: String, confirm_pwd: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.resetPassword(resetCode: reset_code, password: password, confirmPwd: confirm_pwd)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    func getAdditionalAccounts(main_user_id: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getAdditionalAccounts(main_user_id: main_user_id)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
        
        call(request, completion: completion)
    }
    
    
    func createAdditionalAccount(main_user_id: String, first_name: String, last_name: String, user_name: String, password: String, bio: String, photo: Data, completion: ((ServerResponse)->())?) {
        
        let rest = RestRouter.createAdditionalAccount(main_user_id: main_user_id, first_name: first_name, last_name: last_name, user_name: user_name, password: password, bio: bio, photo: photo)
        
        var request = URLRequest(url: rest.url)

        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
        
        call(request, completion: completion)
    }
    
    
    func changePassword(password: String, confirm_pwd: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.changePassword(password: password, confirmPassword: confirm_pwd)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    func getMyCashInfo(completion: ((ServerResponse)->())?){
        let rest = RestRouter.getMyCashInfo
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = rest.method
              request.httpBody = rest.body
              
              call(request, completion: completion)
    }
    
    func getUserDetails(userId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getUserDetails(user_id: userId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    
    func sharePost(postId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.sharePost(id: postId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    func updateDeviceToken(token: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.updatePushToken(device_token: token)
        
        var request = URLRequest(url: rest.url)
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func updateProfile(email: String, firstName: String, lastName: String, phone: String, birthDay: String, photo: Data, color: String, username: String, gender: Int, privateOn: Int, bio: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.updateProfile(email: email, firstName: firstName, lastName: lastName, phone: phone, birthday: birthDay, photo: photo, color: color, username: username, gender: gender, privateOn: privateOn, bio: bio)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func getMyPosts(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getPosts
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func getNotifications(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getNotifications
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func getUserDetails(user_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.userDetails(userId: user_id)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func removePosts(mediaId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.removePosts(mediaId: mediaId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func search(keyword: String, completion: ((ServerResponse)->())?) {
        
        dataTask?.cancel()
        
        let rest = RestRouter.search(keyword: keyword)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func follow(userId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.follow(userId: userId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    func unfollow(userId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.unfollow(userId: userId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func getfollowers(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getFollowers
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        call(request, completion: completion)
    }
    
    func getfollowings(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getFollowings
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func isFollowing(userId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.isFollowing(user_id: userId)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func postMedia(hash_tag: [String], description: String, forever: Bool, isVideo: Bool, thumbnail: Data?, media: Data, link: String, user_id: Int, screen_w: Int, screen_h: Int,  x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, angle: Float, scale: CGFloat, taggedUserId: [String], completion: ((ServerResponse)->())?) {
        let rest = RestRouter.postMedia(hash_tag: hash_tag, description: description, forever: forever, isVideo: isVideo, thumbnail: thumbnail, media: media, link: link, user_id: user_id, screen_w: screen_w, screen_h: screen_h, x: x, y: y, width: width, height: height, angle: angle, scale: scale, taggedUserId: taggedUserId)

        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body

        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
        
        call(request, completion: completion)
    }
    
    func postVideoToFeed(feed_id: Int, media: Data, link: String, screen_w: Int, screen_h: Int, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, angle: CGFloat, scale: CGFloat, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.uploadVideoToFeed(feed_id: feed_id, videoData: media, link: link, screen_w: screen_w, screen_h: screen_h, x: x, y: y, width: width, height: height, angle: angle, scale: scale)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")

        call(request, completion: completion)
    }
    
    func getFeeds(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getFeeds
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        
        call(request, completion: completion)
    }
    
    //-------------  Feed: feed/feeds
    func getFeedData(pageId: Int,completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getFeedData(page: pageId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    //-------------
    //-------------  Viral: feed/popular_feeds
    func getViralData(pageId: Int,completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getViralData(page: pageId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    //-------------
    //-------------  Tags: feed/my_tagged_feeds
    func getTagData(pageId: Int,completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getTagData(page: pageId)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        
        call(request, completion: completion)
    }
    //-------------
    func getFilteredStories (completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getFilteredStories
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        
        call(request, completion: completion)
    }
    
    func getPosts(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getPosts
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        

        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func getOthersPosts(userId: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getOthersFeeds(userId: userId)
        
        var request = URLRequest(url: rest.url)
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func like(media_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.like(mediaId: media_id)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func unlike(media_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.unlike(mediaId: media_id)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func comment(media_id: Int, message: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.comment(mediaId: media_id, comment: message)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func getComments(feed_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getComments(feed_id: feed_id)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func logViewFeed(media_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.logViewFeed(mediaId: media_id)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    func createCategory(name: String, logo: Data, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.createCategory(name: name, logo: logo)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
//    func getTop100Radio(completion: ((ServerResponse)->())?) {
//        let rest = RestRouter.getTop100
//
//        var request = URLRequest(url: rest.url)
//
//        if let token = TokenManager.getToken() {
//            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//            request.httpMethod = rest.method
//            request.httpBody = rest.body
//
//            call(request, completion: completion)
//        } else {
//            return
//        }
//    }
    
    func searchRadioStations(keyword: String, completion: ((ServerResponse)->())?) {
        
        dataTask?.cancel()
        
        let rest = RestRouter.searchRadioStations(keyword: keyword)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    func popularRadioStations(limit: Int, completion: ((ServerResponse)->())?) {
        
        dataTask?.cancel()
        
        let rest = RestRouter.popularRadioStations(limit: limit)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)
    }
    
    
    func getCategories(completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getCategories
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func getRadiosByCategory(category_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getRadiosByCategory(category_id: category_id)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func getRadioStation(radio_station_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getRadioStation(radio_station_id: radio_station_id)
        
        var request = URLRequest(url: rest.url )
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func getAllUsers(pageNum: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getAllUsers(pageNum: pageNum)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    
    func searchRadio(keyword: String, searchType:Int, completion: ((ServerResponse)->())?) {
        
        dataTask?.cancel()
        
        let rest = RestRouter.searchRadio(keyword: keyword, searchType: searchType)
        
        var request = URLRequest(url: rest.url)
        
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
        
        request.httpMethod = rest.method
        request.httpBody = rest.body
        
        call(request, completion: completion)        
    }
    
    func createRadio(category_id: Int, name: String, tags: [WSTag], completion: ((ServerResponse)->())?) {
        let rest = RestRouter.createRadio(category_id: category_id, name: name, tags: tags)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func createNewRadioStation(category_id: Int, name: String, hash_tag: [WSTag], completion: ((ServerResponse)->())?) {
        let rest = RestRouter.createNewRadioStation(category_id: category_id, name: name, hash_tag: hash_tag)

            var request = URLRequest(url: rest.url)
    
            if let token = TokenManager.getToken() {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                request.httpMethod = rest.method
                request.httpBody = rest.body
                
                call(request, completion: completion)
           } else {
                return
                }
        }
//    func uploadAudio(radio_id: Int, audio: Data, completion: ((ServerResponse)->())?) {
//        let rest = RestRouter.uploadRadio(radio_id: radio_id, audio: audio)
//
//        var request = URLRequest(url: rest.url)
//
//        if let token = TokenManager.getToken() {
//            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
//
//            request.httpMethod = rest.method
//            request.httpBody = rest.body
//
//            call(request, completion: completion)
//        } else {
//            return
//        }
//    }
    

    func logRadioView(radio_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.logRadioView(radio_id: radio_id)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func postRadioComment(radio_id: Int, comment: String, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.postRadioComment(radio_id: radio_id, comment: comment)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func getRadioComments(radio_id: Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.getRadioComments(radio_id: radio_id)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
   /////-------------------------------
   func startingARadioRecording(radio_Station_id : Int, completion: ((ServerResponse)->())?) {
          let rest = RestRouter.startingARadioRecording(radio_station_id: radio_Station_id)
          
          var request = URLRequest(url: rest.url)
          if let token = TokenManager.getToken() {
              request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
              
              request.httpMethod = rest.method
              request.httpBody = rest.body
              
              call(request, completion: completion)
          } else {
              return
          }
      }
    
    func uploadRadioFile(radio_station_id: Int, name: String, audio: Data, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.uploadRadioFile(radio_station_id: radio_station_id, name : name, audio: audio)
        
        var request = URLRequest(url: rest.url)
        
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("multipart/form-data; boundary=\(rest.boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func finishedRecording(radio_Station_id : Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.finishedRecording(radio_station_id: radio_Station_id)
        var request = URLRequest(url: rest.url)
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    
    func requestListen(radio_Station_id : Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.requestListen(radio_station_id: radio_Station_id)
        var request = URLRequest(url: rest.url)
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    func logAdView(postId: Int, type: Int, clickAd: Int, completion: ((ServerResponse)->())?){
        let rest = RestRouter.logAdView(post_id: postId, type: type, click_ad: clickAd)
             
        var request = URLRequest(url: rest.url)
         
        request.addValue("Bearer \(TokenManager.getToken()!)", forHTTPHeaderField: "Authorization")
         
        request.httpMethod = rest.method
        request.httpBody = rest.body
         
        call(request, completion: completion)
    }
    func rejectListen(radio_Station_id : Int, completion: ((ServerResponse)->())?) {
        let rest = RestRouter.rejectListen(radio_station_id: radio_Station_id)
        var request = URLRequest(url: rest.url)
        if let token = TokenManager.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = rest.method
            request.httpBody = rest.body
            
            call(request, completion: completion)
        } else {
            return
        }
    }
    /////-------------------------------
    
    private func call(_ request: URLRequest, completion: ((ServerResponse)->())?) {

        dataTask = session.dataTask(with: request) { data, urlResponse, error in
            
            guard let data = data else {
                
                completion?(.error(error: ServerError.wrongResponseData))
                return
            }
            
            completion?(.success(data: data))
        }
        dataTask?.resume()
    }
    
}
