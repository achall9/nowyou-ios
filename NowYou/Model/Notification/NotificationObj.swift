//
//  Notification.swift
//  NowYou
//
//  Created by Apple on 3/25/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

enum NotificationAction: Int {
    case Comment = 0
    case Like
    case Follow
}

class NotificationObj: NSObject {
    var action: NotificationAction = .Comment
    var time: Date?
    var body: String?
    var sender_name: String?
    var sender_photo: String?
    var sender_id: Int?
    var feed_id: Int?
    
    init(json: [String: Any]) {
        if let type = json["comment_or_like"] as? Int {
            if type == 0 {
                action = .Comment
            } else if type == 1 {
                action = .Like
            } else {
                action = .Follow
            }
        }
        
        if let timeStr = json["created_at"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            time     = dateFormatter.date(from: timeStr)
        }
        
        body            = json["body"] as? String
        sender_name     = json["sender_username"] as? String
        sender_photo    = Utils.getFullPath(path: json["sender_photo"] as? String ?? "")
        sender_id       = json["sender_id"] as? Int
        feed_id         = json["feed_id"] as? Int
    }
}
