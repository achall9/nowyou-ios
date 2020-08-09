//
//  RadioStation.swift
//  NowYou
//
//  Created by 111 on 1/15/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import UIKit

class RadioStation: NSObject {
    var id: Int
    var name: String
    var user_id: Int
    var user_name: String
    var category_id: Int
    var category_name: String
    
    var hash_tag_array = [String]()
    var views: Int
    
    var updated_at: Date
    var created_at: Date
    var audios: Audios
    
    var hash_Tag = [String]()
    
    init(json: [String: Any]) {
        id          = json["id"] as! Int
        name        = json["name"] as? String ?? ""
        user_id     = json["user_id"] as! Int
        user_name     = json["user_name"] as? String ?? ""
        category_id = json["category_id"] as! Int
        category_name = json["category_name"] as? String ?? ""
        views       = json["views"] as? Int ?? 0
        
        let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        updated_at  = dateFormatter.date(from: json["updated_at"] as! String)!
        created_at  = dateFormatter.date(from: json["created_at"] as! String)!
        
        if let tags = json["hash_tag_array"] as? [String] {
            for tag in tags {
                if tag.count > 0 {
                    self.hash_tag_array.append(tag.lowercased())
                }
            }
        }
        if let audioJson = json["radios"] as? [[String: Any]] , audioJson.count != 0 {
            audios = Audios(json: audioJson[0])
        }else{
            audios = Audios(json: ["": ""])
            print("Error ! No audios")
            return
        }
//        if let audioJson = json["radios"] as? [[String: Any]] {
//            audios = Audios(json: audioJson[0])
//        }else{
//            audios = Audios(json: ["": ""])
//            print("Error ! No audios")
//            return
//        }
        
    }
}
