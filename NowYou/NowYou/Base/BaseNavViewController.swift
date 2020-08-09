//
//  BaseNavViewController.swift
//  NowYou
//
//  Created by Apple on 1/22/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class BaseNavViewController: UINavigationController {

    // Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
    }
}
