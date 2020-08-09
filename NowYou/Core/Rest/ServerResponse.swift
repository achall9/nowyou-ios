//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

/// Server Response enum
/// to use in completion
/// - error: current Server Error
/// - success: data with JSON answer
enum ServerResponse {

    case error(error: ServerError)
    case success(data: Data)
    
}


