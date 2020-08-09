//
//  NotificationManager.swift
//  BetIT
//
//  Created by joseph on 8/27/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

typealias NotificationTopicSubscribeCompletionHandler = (Error?) -> Void

protocol NotificationDelegate {
     func pushDirect(_ userInfo: [AnyHashable: Any])
}

internal final class NotificationManager: NSObject {
    
    var notificationDelegate : NotificationDelegate?
    
    static let shared = NotificationManager()
    private let GCMMessageIDKey = "gcm.message_id"
    private let GCMNotificationDataKey = "gcm.notification.data"
    private let betDataKey = "bet"
    private let currentFCMTokenKey = "currentFCMTokenKey"
    
    private let fcmSendURL = "https://fcm.googleapis.com/fcm/send"
    private let serverKey = "AAAAtd0PIZc:APA91bEH1ywpA9G-5ycQ7o4Of2m2M3zYtBPueVAfBmvWzpRSTDUyODyNmdzHCHNbmnlbtKayxXHh-ZKdRDmtTff-pUOoQdt7PMY5FnEWLeUGaa-4lATOAEIf6MJAfZKn2W4OYpcsHkNI"
    private let LegacyAPIKey = "AIzaSyDVahewmaKp7WcuwPo3tgXUBQK2wGF4Bco"
    let rootR = Database.database().reference(fromURL: "https://nowyou-5bbbf.firebaseio.com/")
    
    private override init() {
        super.init()
        setup()
    }
    
    func initRun(){
        
    }
    
    private func setup() {
        Messaging.messaging().delegate = self
        getCurrentRegistrationToken()
    }
    
    func getCurrentRegistrationToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            guard error == nil else { return }
            guard let result = result else { return }
            print("[DEBUG] NotificationManager.getCurrentRegistrationToken() - Remote InstanceID token: \(result.token)")
        }
    }
    
    func sendPush( token: String, title: String, message: String, action_event: [String:String], userId:String, success: @escaping () -> Void, failure: @escaping ( _ error: Error) -> Void) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : message],
                                           "data" : action_event
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                        success()
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
                failure(err)
            }
        }
        task.resume()
        
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        notificationDelegate?.pushDirect(userInfo)
        print(userInfo)
    }
    
    func storeToken() {
        guard AppDelegate.shared.fcmToken.count > 0 else { return }
        guard let currentUser = UserManager.currentUser() else {
            return
        }
        UserDefaults.standard.set(AppDelegate.shared.fcmToken, forKey: currentFCMTokenKey)
        
        let param: NSDictionary = [
                   "token":AppDelegate.shared.fcmToken,
                    "extra":currentUser.email ?? ""
               ]
        rootR.child("Users").child("\(currentUser.userID ?? -1)").setValue(param)
    }
    
    
    func getTokens(completion: @escaping ( _ tokens: [String]) -> Void) {
        
        rootR.child("Users").observe(DataEventType.value, with: {snapchat in
            var tokenArray:[String] = []
            for message in snapchat.children {
                let messageData = message as! DataSnapshot
                let tokenDic = messageData.value as! NSDictionary
                guard let currentUser = UserManager.currentUser() else {
                    continue
                }
                if currentUser.userID != Int(messageData.key) {
                    tokenArray.append(tokenDic["token"] as! String)
                }
            }
            completion(tokenArray)
        })
    }
    
    func getTokensOfFollowings(followers:[User], completion: @escaping ( _ tokens: [String]) -> Void) {
        
        rootR.child("Users").observe(DataEventType.value, with: {snapchat in
            var tokenArray:[String] = []
            for message in snapchat.children {
                let messageData = message as! DataSnapshot
                let tokenDic = messageData.value as! NSDictionary
                if followers.contains(where: { $0.userID == Int(messageData.key) }) {
                    tokenArray.append(tokenDic["token"] as! String)
                }
            }
            completion(tokenArray)
        })
    }
    
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        AppDelegate.shared.fcmToken = fcmToken
        if let currentToken = UserDefaults.standard.string(forKey: currentFCMTokenKey) {
            if currentToken != fcmToken {
                storeToken()
            }
        } else {
            storeToken()
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("")
    }
    
}
