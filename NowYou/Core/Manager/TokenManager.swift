//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

private let TOKEN_KEY = "NOWYOU_SERVER_TOKEN_KEY"

class TokenManager: NSObject {
    private static var token:  String?
    
    // MARK: - Token Management
    
    class func alreadyLogged() -> Bool {
        return TokenManager.getToken() != nil
    }
    
    class func saveToken(token: String) {
        
        TokenManager.token = token
        UserDefaults.standard.set(token, forKey: TOKEN_KEY)
        UserDefaults.standard.synchronize()
    }
    
    class func getToken() -> String? {
        
        if TokenManager.token == nil {
            if let savedToken = UserDefaults.standard.object(forKey: TOKEN_KEY) as? String {
                TokenManager.token = savedToken
            }
        }
        
        return TokenManager.token
    }
    
    class func deleteToken() {
        TokenManager.token = nil
        UserDefaults.standard.removeObject(forKey: TOKEN_KEY)
    }
}
