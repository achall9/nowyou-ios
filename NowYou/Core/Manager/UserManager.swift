//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class UserManager: NSObject {
    
    private static var posts = [Media]()
    
    class func currentUser() -> User? {
        let userData = UserDefaults.standard.object(forKey: USER_INFO) as! Data?
        
        if userData != nil {
            let user = NSKeyedUnarchiver.unarchiveObject(with: userData!) as! User
            
            return user
        }
        
        return nil
    }
    
    class func myCashInfo() -> CashInfo? {
        let cashInfo = UserDefaults.standard.object(forKey: CASH_INFO) as! Data?
        if cashInfo != nil {
            let cashInfo = NSKeyedUnarchiver.unarchiveObject(with: cashInfo!) as! CashInfo
            return cashInfo
        }
        return nil
    }
    class func updateUser(user: User) {
        let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(encodedUser, forKey: USER_INFO)
        UserDefaults.standard.synchronize()
    }
    
    class func saveUserType(userLoggedinType: String) {
        UserDefaults.standard.set(userLoggedinType, forKey: "LoggedName")
    }
    
    class func getUserType() -> String {
        let userLoggedinType = UserDefaults.standard.string(forKey: "LoggedName") ?? ""
        return userLoggedinType
    }
    
    class func setPosts(userPosts: [Media]) {
        UserManager.posts = userPosts
    }
    
    class func getPosts() -> [Media] {
        return UserManager.posts
    }
}
