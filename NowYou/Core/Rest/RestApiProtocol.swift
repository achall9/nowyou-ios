//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation


typealias Parameters = [String:Any]

protocol RestAPIProtocol: CustomStringConvertible, CustomDebugStringConvertible {
    var method: String { get }
    var param: Parameters { get }
    var queryItems: [URLQueryItem]? { get }
}


extension RestAPIProtocol {
    
    var url: URL {
        var compomnets = URLComponents()
        compomnets.scheme = API.URL_SCHEME
        compomnets.host = API.HOST
        compomnets.queryItems = self.queryItems
        precondition(compomnets.url != nil, "Failed to coding url for request")
        return compomnets.url!
    }
    
    var debugDescription: String {
        return ""
    }
}
