//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

enum ServerError: Error {
    
    case connectionError
    case timeoutError
    case unknownHTTPResponse
    case httpResponseError(code: Int)
    case wrongResponseData
    case serverError(error: Error)
}
