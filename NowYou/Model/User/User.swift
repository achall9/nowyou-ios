//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    var userID              : Int!
    var firstName           : String!
    var lastName            : String!
    var email               : String!
    var username            : String!
    var userPhoto           : String!
    var fullname            : String!
    
    var phone               : String!
    var birthday            : String!
    
    var privateOn           : Int!
    var bio                 : String!
    
    var total_amount        : Int = 0
    var followers_count     : Int = 0
    var followings_count    : Int = 0
    var this_week_followers : Int = 0
    var posts_count         : Int = 0
    var posts_image_count   : Int = 0
    var posts_video_count   : Int = 0
    var view_count_total    : Int = 0
    var view_count_daily    : Int = 0
    var view_count_monthly  : Int = 0
    var view_count_weekly  : Int = 0
    var view_count_yearly   : Int = 0
    var earning_total       : Double = 0.0
    var earning_daily       : Double = 0.0
    var earning_weekly      : Double = 0.0
    var earning_monthly     : Double = 0.0
    var earning_yearly      : Double = 0.0
    var withdrawns_total    : Double = 0.0
    var color               : String = "FFFFFF"
    var gender              : Int = 1
    
    var monthly_history = [Double]()
    var daily_history = [Double]()
    var timely_history = [Double]()
    
    init(userID: Int,
         firstName: String,
         lastName: String,
         email: String,
         username: String,
         userPhoto: String,
         fullname: String,
         phone: String,
         birthday: String,
         privateOn: Int,
         bio: String,
         total_amount: Int,
         followers_count: Int,
         followings_count: Int,
         this_week_followers: Int,
         posts_count: Int,
         posts_image_count: Int,
         posts_video_count: Int,
         view_count_total: Int,
         view_count_daily: Int,
         view_count_weekly: Int,
         view_count_monthly: Int,
         view_count_yearly: Int,
         earning_total: Double,
         earning_daily: Double,
         earning_monthly: Double,
         earning_yearly: Double,
         withdrawns_total: Double,
         color: String,
         gender: Int,
         monthly: [Double],
         daily:[Double],
         timely: [Double]) {
        
        self.userID             = userID
        self.firstName          = firstName
        self.lastName           = lastName
        self.email              = email
        self.username           = username
        self.userPhoto          = userPhoto
        self.fullname           = fullname
        self.phone              = phone
        self.birthday           = birthday
        self.privateOn          = privateOn
        self.bio                = bio
        self.total_amount       = total_amount
        self.followers_count    = followers_count
        self.followings_count   = followings_count
        self.this_week_followers = this_week_followers
        self.posts_count        = posts_count
        self.posts_image_count  = posts_image_count
        self.posts_video_count  = posts_video_count
        self.view_count_total   = view_count_total
        self.view_count_daily   = view_count_daily
        self.view_count_weekly  = view_count_weekly
        self.view_count_monthly = view_count_monthly
        self.view_count_yearly  = view_count_yearly
        self.earning_total      = earning_total
        self.earning_daily      = earning_daily
        self.earning_monthly    = earning_monthly
        self.earning_yearly     = earning_yearly
        self.withdrawns_total   = withdrawns_total
        self.color              = color
        self.gender             = gender
        self.monthly_history    = monthly
        self.daily_history      = daily
        self.timely_history     = timely
        super.init()
    }
    
    init(json: [String: Any]) {
        self.userID             = json[USER.ID] as? Int ?? 0
        self.firstName          = json[USER.FIRST_NAME] as? String ?? ""
        self.lastName           = json[USER.LAST_NAME] as? String ?? ""
        self.email              = json[USER.EMAIL] as? String ?? ""
        self.username           = json[USER.USER_NAME] as? String ?? ""
        self.userPhoto          = json[USER.PHOTO] as? String ?? ""
        self.fullname           = json[USER.FULL_NAME] as? String ?? ""
        self.phone              = json[USER.PHONE] as? String ?? ""
        self.birthday           = json[USER.BIRTHDAY] as? String ?? ""
        self.privateOn          = json[USER.PRIVATE_ON] as? Int ?? 0
        self.bio                = json[USER.BIO]        as? String ?? ""
        

        self.total_amount       = json[USER.TOTAL_AMOUNT] as? Int ?? 0
        
        self.followers_count    = json[USER.FOLLOWERS_COUNT] as? Int ?? 0
        self.followings_count   = json[USER.FOLLOWINGS_COUNT] as? Int ?? 0
        self.this_week_followers = json[USER.THIS_WEEK_FOllOWERS] as? Int ?? 0
        self.posts_count        = json[USER.POSTS_COUNT] as? Int ?? 0
        self.posts_image_count  = json[USER.POSTS_IMAGE_COUNT] as? Int ?? 0
        self.posts_video_count  = json[USER.POSTS_VIDEO_COUNT] as? Int ?? 0
        self.view_count_total   = json[USER.VIEW_COUNT_TOTAL] as? Int ?? 0
        self.view_count_daily   = json[USER.VIEW_COUNT_DAILY] as? Int ?? 0
        self.view_count_weekly   = json[USER.VIEW_COUNT_WEEKLY] as? Int ?? 0
        self.view_count_monthly = json[USER.VIEW_COUNT_MONTHLY] as? Int ?? 0
        self.view_count_yearly  = json[USER.VIEW_COUNT_YEARLY] as? Int ?? 0
        self.earning_total      = json[USER.EARNING_TOTAL] as? Double ?? 0.0
        self.earning_daily      = json[USER.EARNING_DAILY] as? Double ?? 0.0
        self.earning_weekly     = json[USER.EARNING_WEEKLY] as? Double ?? 0.0
        
        self.withdrawns_total   = json[USER.WITHDRAWNS_TOTAL] as? Double ?? 0.0
        self.color              = json[USER.COLOR] as? String ?? "FFFFFF"
        
        if json[USER.GENDER] as? Int == nil {
            let gender = json[USER.GENDER] as? String
            self.gender = (gender as! NSString).integerValue
        } else {
            self.gender = json[USER.GENDER] as? Int ?? 1
        }
        
               
        
        if let monthly           = json[USER.EARNING_MONTHLY] as? [String: Any] {
            self.earning_monthly = monthly["monthly"] as? Double ?? 0.0
            
            if let history = monthly["daily_history"] as? [String: Any] {
                for index in 1..<31 {
                    daily_history.append(history["\(index)"] as? Double ?? 0.0)
                }
            }
        }
        if let yearly             = json[USER.EARNING_YEARLY] as? [String: Any] {
            self.earning_yearly = yearly["yearly"] as? Double ?? 0.0
            
            if let history = yearly["monthly_history"] as? [String: Any] {
                for index in 1..<13 {
                    monthly_history.append(history["\(index)"] as? Double ?? 0.0)
                }
            }
        }
        
        if let daily             = json[USER.EARNING_DAILY] as? [String: Any] {
            self.earning_daily  = daily["daily"] as? Double ?? 0.0
            
            if let history = daily["timely_history"] as? [Double] {
                for index in 0..<24 {
                    self.timely_history.append(history[index])
                }
            }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userID, forKey: USER.ID)
        aCoder.encode(self.firstName, forKey: USER.FIRST_NAME)
        aCoder.encode(self.lastName, forKey: USER.LAST_NAME)
        aCoder.encode(self.email, forKey: USER.EMAIL)
        aCoder.encode(self.username, forKey: USER.USER_NAME)
        aCoder.encode(self.userPhoto, forKey: USER.PHOTO)
        
        aCoder.encode(self.phone, forKey: USER.PHONE)
        aCoder.encode(self.birthday, forKey: USER.BIRTHDAY)
        
        aCoder.encode(self.privateOn, forKey: USER.PRIVATE_ON)
        aCoder.encode(self.bio, forKey: USER.BIO)
        
        aCoder.encode(self.fullname, forKey: USER.FULL_NAME)
        aCoder.encode(self.total_amount, forKey: USER.TOTAL_AMOUNT)
        aCoder.encode(self.followers_count, forKey: USER.FOLLOWERS_COUNT)
        aCoder.encode(self.followings_count, forKey: USER.FOLLOWINGS_COUNT)
        aCoder.encode(self.this_week_followers, forKey: USER.THIS_WEEK_FOllOWERS)
        aCoder.encode(self.posts_count, forKey: USER.POSTS_COUNT)
        aCoder.encode(self.posts_image_count, forKey: USER.POSTS_IMAGE_COUNT)
        aCoder.encode(self.posts_video_count, forKey: USER.POSTS_VIDEO_COUNT)
        
        aCoder.encode(self.view_count_total, forKey: USER.VIEW_COUNT_TOTAL)
        aCoder.encode(self.view_count_daily, forKey: USER.VIEW_COUNT_DAILY)
        aCoder.encode(self.view_count_weekly, forKey: USER.VIEW_COUNT_WEEKLY)
        aCoder.encode(self.view_count_monthly, forKey: USER.VIEW_COUNT_MONTHLY)
        aCoder.encode(self.view_count_yearly, forKey: USER.VIEW_COUNT_YEARLY)
        aCoder.encode(self.earning_total, forKey: USER.EARNING_TOTAL)
        aCoder.encode(self.earning_daily, forKey: USER.EARNING_DAILY)
        aCoder.encode(self.earning_monthly, forKey: USER.EARNING_MONTHLY)
        aCoder.encode(self.earning_yearly, forKey: USER.EARNING_YEARLY)
        aCoder.encode(self.withdrawns_total, forKey: USER.WITHDRAWNS_TOTAL)
        aCoder.encode(self.color, forKey: USER.COLOR)
        aCoder.encode(self.gender, forKey: USER.GENDER)
        
        aCoder.encode(self.monthly_history, forKey: USER.MONTHLY)
        aCoder.encode(self.daily_history, forKey: USER.DAILY)
        aCoder.encode(self.timely_history, forKey: USER.TIMELY)
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        
        let userId          = aDecoder.decodeObject(forKey: USER.ID) as! Int
        let userAvatar      = aDecoder.decodeObject(forKey: USER.PHOTO) as? String ?? ""
        let userFirstName   = aDecoder.decodeObject(forKey: USER.FIRST_NAME) as? String ?? ""
        let userLastName    = aDecoder.decodeObject(forKey: USER.LAST_NAME) as? String ?? ""
        let userEmail       = aDecoder.decodeObject(forKey: USER.EMAIL) as? String ?? ""
        let username        = aDecoder.decodeObject(forKey: USER.USER_NAME) as? String ?? ""
        let fullname        = aDecoder.decodeObject(forKey: USER.FULL_NAME) as? String ?? ""
        
        let phone           = aDecoder.decodeObject(forKey: USER.PHONE) as? String ?? ""
        let birthday        = aDecoder.decodeObject(forKey: USER.BIRTHDAY) as? String ?? ""
        
        let privateOn      = aDecoder.decodeObject(forKey: USER.PRIVATE_ON) as? Int ?? 0
        let bio             = aDecoder.decodeObject(forKey: USER.BIO) as? String ?? ""
        
        let total_amount = aDecoder.decodeInteger(forKey: USER.TOTAL_AMOUNT)
        let followers_count = aDecoder.decodeInteger(forKey: USER.FOLLOWERS_COUNT)
        let followings_count = aDecoder.decodeInteger(forKey: USER.FOLLOWINGS_COUNT)
        let this_week_followers = aDecoder.decodeInteger(forKey: USER.THIS_WEEK_FOllOWERS)
        let posts_count     = aDecoder.decodeInteger(forKey: USER.POSTS_COUNT)
        let image_count     = aDecoder.decodeInteger(forKey: USER.POSTS_IMAGE_COUNT)
        let video_count     = aDecoder.decodeInteger(forKey: USER.POSTS_VIDEO_COUNT)
        
        let view_total      = aDecoder.decodeInteger(forKey: USER.VIEW_COUNT_TOTAL)
        let view_daily      = aDecoder.decodeInteger(forKey: USER.VIEW_COUNT_DAILY)
        let view_weekly      = aDecoder.decodeInteger(forKey: USER.VIEW_COUNT_WEEKLY)
        let view_monthly    = aDecoder.decodeInteger(forKey: USER.VIEW_COUNT_MONTHLY)
        let view_yearly     = aDecoder.decodeInteger(forKey: USER.VIEW_COUNT_YEARLY)
        
        let earning_total   = aDecoder.decodeDouble(forKey: USER.EARNING_TOTAL)
        let earning_daily   = aDecoder.decodeDouble(forKey: USER.EARNING_DAILY)
        let earning_monthly = aDecoder.decodeDouble(forKey: USER.EARNING_MONTHLY)
        let earning_yearly  = aDecoder.decodeDouble(forKey: USER.EARNING_YEARLY)
        let withdrawn_total = aDecoder.decodeDouble(forKey: USER.WITHDRAWNS_TOTAL)
        
        let color           = aDecoder.decodeObject(forKey: USER.COLOR) as? String ?? "FFFFFF"
        let gender          = aDecoder.decodeInteger(forKey: USER.GENDER)
        
        let monthly         = aDecoder.decodeObject(forKey: USER.MONTHLY) as? [Double] ?? []
        let daily           = aDecoder.decodeObject(forKey: USER.DAILY) as? [Double] ?? []
        let timely          = aDecoder.decodeObject(forKey: USER.TIMELY) as? [Double] ?? []
        


        self.init(userID: userId, firstName: userFirstName, lastName: userLastName, email: userEmail, username: username, userPhoto: userAvatar, fullname: fullname, phone: phone, birthday: birthday, privateOn: privateOn, bio: bio, followers_count: followers_count, followings_count: followings_count,this_week_followers: this_week_followers, posts_count: posts_count, posts_image_count: image_count, posts_video_count: video_count, view_count_total: view_total, view_count_daily: view_daily,
                  view_count_weekly: view_weekly,view_count_monthly: view_monthly, view_count_yearly: view_yearly, earning_total: earning_total, earning_daily: earning_daily, earning_monthly: earning_monthly, earning_yearly: earning_yearly, withdrawns_total: withdrawn_total, color: color, gender: gender, monthly: monthly, daily: daily, timely: timely)

    }
    
    func isLogged() -> Bool {
        return TokenManager.alreadyLogged()
    }
}
