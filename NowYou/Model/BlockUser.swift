//
//  BlockUser.swift
//  NowYou
//
//  Created by 111 on 5/25/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class BlockUser: NSObject {
    var user: User?
    var posts = [Media]()
    
    init(blockUser: User, posts: [Media]) {
        user = blockUser
        self.posts = posts
    }
}
