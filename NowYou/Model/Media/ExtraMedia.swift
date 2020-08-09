//
//  ExtraMedia.swift
//  NowYou
//
//  Created by Apple on 2/2/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ExtraMedia: NSObject {
    var createdDate: Date?
    var path: String?
    var id: Int
    
    var x: Int = 0
    var y: Int = 0
    var width: Int = 0
    var height: Int = 0
    
    var link: String?
    
    var angle: Float = 0.0
    
    var screenWidth: Int = 0
    var screenHeight: Int = 0
    
    init(json: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        createdDate  = dateFormatter.date(from: json[MEDIA.CREATED_AT] as? String ?? "") ?? Date()
        
        path        = json[MEDIA.PATH] as? String
        
        id          = json["id"] as! Int
        
        link        = json[MEDIA.LINK] as? String
        
        x           = json[MEDIA.LINK_X] as? Int ?? 0
        y           = json[MEDIA.LINK_Y] as? Int ?? 0
        width       = json[MEDIA.LINK_W] as? Int ?? 0
        height      = json[MEDIA.LINK_H] as? Int ?? 0
        
        angle       = Float(json[MEDIA.LINK_ANGLE] as? CGFloat ?? 0.0)
        
        screenWidth = json[MEDIA.LINK_SCREEN_W] as? Int ?? 0
        screenHeight = json[MEDIA.LINK_SCREEN_H] as? Int ?? 0
    }
}
