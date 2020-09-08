//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class Media: NSObject {
    var id: Int?
    var shared_parent_id: Int?
    var original_user_id: Int?
    var userId: Int?
    var type: Int?
    var path: String?
    var hash_tag: [String]?
    var taggedUserId: String?
    
    var descStr: String?
    var forever: Bool = false
    var viewsCount: Int?
    var created: Date!
    var thumbnail: String?
    var liked: Bool = false
    var link: String?
    var username: String?
    var userPhoto: String?
    
    var extras = [ExtraMedia]()
    
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    var angle: Float = 0.0
    
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    var isSeen: Bool = false

    var views: Int = 0
    
    init(json: [String: Any]) {
        hash_tag    = json["hash_tag"] as? [String]
       taggedUserId = json["taggedUserId"] as? String
        
        id                  = json[MEDIA.ID] as? Int
        shared_parent_id    = json[MEDIA.SHARED_PARENT_ID] as? Int
        original_user_id    = json[MEDIA.ORIGINAL_USER_ID] as? Int
        userId              = json[MEDIA.USER_ID] as? Int
        type                = json[MEDIA.TYPE] as? Int
        path                = json[MEDIA.PATH] as? String
        descStr             = json[MEDIA.DESCRIPTION] as? String
        forever             = json[MEDIA.FOREVER] as? Bool ?? false
        viewsCount          = json[MEDIA.VIEWS] as? Int
    
        thumbnail           = json[MEDIA.THUMBNAIL] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        created     = dateFormatter.date(from: json[MEDIA.CREATED_AT] as? String ?? "") ?? Date()
        
        liked       = json[MEDIA.LIKED] as? Bool ?? false
        
        link        = json[MEDIA.LINK] as? String
        
        if let userNames = json["user_name_array"] as? [String: Any] {
            username = userNames["username"] as? String ?? "User"
        }
        
        if let extraMedias = json["extra_medias"] as? [[String: Any]], extraMedias.count > 0 {
            for extraMedia in extraMedias {
                extras.append(ExtraMedia(json: extraMedia))
            }
        }
        
        let deviceW = UIScreen.main.bounds.width
        let deviceH = UIScreen.main.bounds.height

        screenWidth = json[MEDIA.LINK_SCREEN_W] as? CGFloat ?? 0.0
        screenHeight = json[MEDIA.LINK_SCREEN_H] as? CGFloat ?? 0.0

        if screenHeight != 0.0 {
            x           = (json[MEDIA.LINK_X] as? CGFloat ?? 0.0) * deviceW / screenWidth
            y           = (json[MEDIA.LINK_Y] as? CGFloat ?? 0.0) * deviceH / screenHeight
            width       = (json[MEDIA.LINK_W] as? CGFloat ?? 0.0) * deviceW / screenWidth
            height      = (json[MEDIA.LINK_H] as? CGFloat ?? 0.0) * deviceH / screenHeight
        }
        
        angle       = Float(json[MEDIA.LINK_ANGLE] as? CGFloat ?? 0.0)
        
        userPhoto   = json["user_photo"] as? String

        isSeen      = json["is_seen"] as? Bool ?? false
        
        views       = json["views"] as? Int ?? 0
    }
    
    
}
