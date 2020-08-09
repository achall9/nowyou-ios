//
//  Audios.swift
//  NowYou
//
//  Created by 111 on 1/15/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class Audios: NSObject {
    var id:             Int
    var name:           String
    var station_id:     Int
    var views:          Int
    var path:           String?
//    var updated_at:     Date
//    var created_at:     Date

    
    init(json: [String: Any]) {
        id              = json["id"] as? Int ?? 0
        name            = json["name"] as? String ?? ""
        station_id      = json["station_id"] as? Int ?? 0
        views           = json["views"] as? Int ?? 0
        
//        let dateFormatter = DateFormatter()
//           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//           dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//
//        updated_at  = dateFormatter.date(from: json["updated_at"] as! String)!
//        created_at  = dateFormatter.date(from: json["created_at"] as! String)!
        if let audioPath = json["path"] as? String {
            path    = Utils.getFullPath(path: audioPath)
        }
    }
}
