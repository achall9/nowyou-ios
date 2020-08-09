//
//  Radio.swift
//  NowYou
//
//  Created by Apple on 1/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class Radio: NSObject {
    var id: Int
    var name: String
    var views: Int
    var user_id: Int
    var category_id: Int
    var user: User?
    var path: String?
    
    var category_name: String
    
    var total_view_count: Int
    
    var isLive: Bool = false
    
    var hashTags = [String]()
    
    init(json: [String: Any]) {
        id          = json["id"] as! Int
        name        = json["name"] as? String ?? ""
        views       = json["views"] as? Int ?? 0
        user_id     = json["user_id"] as! Int
        category_id = json["category_id"] as! Int
        
        if let userData = json["user"] as? [String: Any] {
            user    = User(json: userData)
        }
        
        total_view_count = json["total_view_count"] as? Int ?? 0
        
        if let radioPath = json["path"] as? String {
            path    = Utils.getFullPath(path: radioPath)
        }
        
        if let tags = json["hash_tag_array"] as? [String] {
            for tag in tags {
                if tag.count > 0 {
                    self.hashTags.append(tag.lowercased())
                }
            }
        }
        
        category_name = json["category_name"] as? String ?? ""
    }
}
