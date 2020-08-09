//  CashInfo.swift
//  NowYou
//
//  Created by 111 on 3/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
class CashInfo : NSObject, NSCoding {
  
    var total_cash          : Double = 0.0
    var total_click_count   : Int = 0
    var total_view_count    : Int = 0
    var total_post_clicked  : Int = 0
    var total_post_viewed   : Int = 0
    var entire_click_count  : Int = 0
    var entire_view_count   : Int = 0
    var entire_post_clicked : Int = 0
    var entire_post_viewed  : Int = 0
    var withdrawed_cash     : Double = 0.0
    
    var monthly          : Double = 0.0
    var this_week        : Double = 0.0
    var yearly           : Double = 0.0
    var daily            : Double = 0.0
    var this_week_followers : Int = 0
    var monthly_history = [Double]()
    var daily_history = [Double]()
    var timely_history = [Double]()
    
    init(total_cash: Double,
         total_click_count: Int,
         total_view_count: Int,
         total_post_clicked: Int,
         total_post_viewed: Int,
         entire_click_count: Int,
         entire_view_count: Int,
         entire_post_clicked: Int,
         entire_post_viewed: Int,
         withdrawed_cash: Double,
         this_week: Double,
         monthly: Double,
         yearly: Double,
         daily: Double,
         this_week_followers: Int,
         monthly_history: [Double],
         timely_history:[Double],
         daily_history: [Double])
    {
        super.init()
        self.total_cash = total_cash
        self.total_click_count = total_click_count
        self.total_view_count = total_view_count
        self.total_post_viewed = total_post_viewed
        self.total_click_count = total_post_clicked
        self.entire_click_count = entire_click_count
        self.entire_view_count = entire_view_count
        self.entire_post_clicked = entire_post_clicked
        self.entire_post_viewed = entire_post_viewed
        self.withdrawed_cash = withdrawed_cash
        self.this_week = this_week
        self.monthly = monthly
        self.yearly = yearly
        self.daily = daily
        self.this_week_followers = this_week_followers
        self.timely_history = timely_history
        self.monthly_history = monthly_history
        self.daily_history = daily_history
    }
    
    init(json: [String: Any]) {
        self.total_cash     = json["total_cash"] as? Double ?? 0.0
        self.total_click_count = json["total_click_count"] as? Int ?? 0
        self.total_view_count = json["total_view_count"] as? Int ?? 0
        self.total_post_viewed = json["total_post_viewed"] as? Int ?? 0
        self.total_click_count = json["total_click_count"] as? Int ?? 0
        self.entire_click_count = json["entire_click_count"] as? Int ?? 0
        self.entire_view_count = json["entire_view_count"] as? Int ?? 0
        self.entire_post_clicked = json["entire_post_clicked"] as? Int ?? 0
        self.entire_post_viewed = json["entire_post_viewed"] as? Int ?? 0
        self.withdrawed_cash = json["withdrawed_cash "] as? Double ?? 0.0
        self.this_week_followers = json[USER.THIS_WEEK_FOllOWERS] as? Int ?? 0
        self.this_week = json["this_week "] as? Double ?? 0.0

        if let today = json["today"] as? [String: Any] {
            self.daily = today["daily"] as? Double ?? 0.0

            if let history = today["timely_history"] as? [Double] {
                for index in 0..<24 {
                    self.timely_history.append(history[index] as? Double ?? 0.0)
                }
            }
        }
        if let this_month = json["this_month"] as? [String: Any] {
            self.monthly = this_month["monthly"] as? Double ?? 0.0

            if let history = this_month["daily_history"] as? [String: Any] {
                for index in 1..<31 {
                    self.daily_history.append(history["\(index)"] as? Double ?? 0.0)
                }
            }
        }
        if let this_year = json["this_year"] as? [String: Any] {
           self.yearly = this_year["Yearly"] as? Double ?? 0.0
           
           if let history = this_year["monthly_history"] as? [String: Any] {
               for index in 1..<13 {
                   monthly_history.append(history["\(index)"] as? Double ?? 0.0)
               }
           }
        }
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.total_cash, forKey: "total_cash")
        aCoder.encode(self.total_click_count, forKey: "total_click_count")
        aCoder.encode(self.total_view_count, forKey: "total_view_count")
        aCoder.encode(self.total_post_viewed, forKey: "total_post_viewed")
        aCoder.encode(self.total_post_clicked, forKey: "total_post_clicked")
        aCoder.encode(self.entire_click_count, forKey: "entire_click_count")
        aCoder.encode(self.this_week_followers, forKey: USER.THIS_WEEK_FOllOWERS)
        aCoder.encode(self.entire_view_count, forKey: "entire_view_count")
        aCoder.encode(self.entire_post_clicked, forKey: "entire_post_clicked")
        aCoder.encode(self.entire_post_viewed, forKey: "entire_post_viewed")
        aCoder.encode(self.monthly, forKey: "monthly")
        aCoder.encode(self.yearly, forKey: "yearly")
        aCoder.encode(self.daily, forKey: "daily")
        aCoder.encode(self.monthly_history, forKey: "monthly_history")
        aCoder.encode(self.daily_history, forKey: "daily_history")
        aCoder.encode(self.timely_history, forKey: "timely_history")
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        let total_cash = aDecoder.decodeDouble(forKey: "total_cash")
        let total_click_count =  aDecoder.decodeInteger(forKey: "total_click_count")
        let total_view_count = aDecoder.decodeInteger(forKey: "total_view_count")
        let total_post_viewed = aDecoder.decodeInteger(forKey: "total_post_viewed")
        let total_post_clicked = aDecoder.decodeInteger(forKey: "total_post_clicked")
        let entire_click_count = aDecoder.decodeInteger(forKey: "entire_click_count")
        let entire_view_count =  aDecoder.decodeInteger(forKey: "entire_view_count")
        let entire_post_clicked = aDecoder.decodeInteger(forKey: "entire_post_clicked")
        let entire_post_viewed = aDecoder.decodeInteger(forKey: "entire_post_viewed")
        let this_week_followers = aDecoder.decodeInteger(forKey: USER.THIS_WEEK_FOllOWERS)

        let withdrawed_cash = aDecoder.decodeDouble(forKey: "withdrawed_cash")
        let this_week = aDecoder.decodeDouble(forKey: "this_week")
        let monthly =  aDecoder.decodeDouble(forKey: "monthly")
        let yearly = aDecoder.decodeDouble(forKey: "yearly")
        let daily = aDecoder.decodeDouble(forKey: "daily")
        let monthly_history = aDecoder.decodeObject(forKey: "monthly_history") as? [Double] ?? []
        let daily_history =  aDecoder.decodeObject(forKey: "daily_history") as? [Double] ?? []
        let timely_history =  aDecoder.decodeObject(forKey: "timely_history") as? [Double] ?? []

        
        self.init(total_cash: total_cash,
            total_click_count: total_click_count,
            total_view_count: total_view_count,
            total_post_clicked: total_post_clicked,
            total_post_viewed: total_post_viewed,
            entire_click_count: entire_click_count,
            entire_view_count: entire_view_count,
            entire_post_clicked: entire_post_clicked,
            entire_post_viewed: entire_post_viewed,
            withdrawed_cash: withdrawed_cash,
            this_week: this_week,
            monthly: monthly,
            yearly: yearly,
            daily:daily,
            this_week_followers: this_week_followers,
            monthly_history: monthly_history,
            timely_history: timely_history,
            daily_history: daily_history)
    }

    func isLogged() -> Bool {
        return TokenManager.alreadyLogged()
    }
}

