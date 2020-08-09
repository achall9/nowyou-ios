//
//  RadioComment.swift
//  NowYou
//
//  Created by Apple on 1/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class RadioComment: NSObject {
    var commentId: String
    var parentId: String
    var parentName: String
    var userId: Int
    var username: String
    var like: Int
    var likeCount: Int
    var comment: String
    var photo: String
    var created_at: Date
    var timestamp: Double

    init(json: [String: Any]) {
        commentId   = json["commentId"] as? String ?? ""
        parentId    = json["parentId"] as? String ?? ""
        like        = json["like"] as? Int ?? 0
        comment     = json["comment"] as? String ?? ""
        photo       = json["photo"] as? String ?? ""
        timestamp   = json["timestamp"] as? Double ?? Date().timeIntervalSince1970
        username    = json["username"] as? String ?? ""
        userId      = json["userId"] as? Int ?? 0
        likeCount   = json["likeCount"] as? Int ?? 0
        created_at  = Date(timeIntervalSince1970: timestamp)
        parentName  = json["parentName"] as? String ?? ""
    }
}

