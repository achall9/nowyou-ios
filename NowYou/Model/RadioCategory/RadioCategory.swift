//
//  RadioCategory.swift
//  NowYou
//
//  Created by Apple on 1/10/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SwiftyJSON

class RadioCategory: NSObject {
    var name: String
    var logo: URL?
    var id: Int?
    
    init(json:[String: Any]) {
        name        = json["name"] as? String ?? ""
        logo        = URL(string: Utils.getFullPath(path: json["logo"] as? String ?? ""))
        id          = json["id"] as? Int
    }
    
//    func getname() -> String{
//        return name
//    }
}
