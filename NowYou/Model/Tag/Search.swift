//
//  Search.swift
//  NowYou
//
//  Created by 111 on 6/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

class SearchUser: NSObject {
    var user: User?
    var isFollowing: Bool = false
    var posts = [Media]()
    
    init(searchUser: User, following: Bool, posts: [Media]) {
        user = searchUser
        isFollowing = following
        self.posts = posts
    }
}

class SearchTag: NSObject {
    var tag: String
    var tag_id: Int
    var isFollowing: Bool = false
    var posts = [Media]()
    
    init(searchTag: String,tagId: Int, following: Bool, searchPosts: [Media]) {
        self.tag = searchTag
        tag_id = tagId
        isFollowing = following
        self.posts = searchPosts
    }
}

class Tag: NSObject {
    var id: Int
    var name: String
    var updated_at: Date
    var created_at: Date
    
  init(json: [String: Any]) {
    id = json["id"] as! Int
    name = json["name"] as! String
    let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    updated_at  = dateFormatter.date(from: json["updated_at"] as! String)!
    created_at  = dateFormatter.date(from: json["created_at"] as! String)!
    }
}
