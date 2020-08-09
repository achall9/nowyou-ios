//
//  BaseViewController.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVFoundation
class BaseViewController: UIViewController {
    
    // Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        if let color = UserManager.currentUser()?.color {
            self.view.backgroundColor = UIColor(hexString: color)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(appThemeUpdated(_:)), name: NSNotification.Name(rawValue: NOTIFICATION.APP_COLOR_UPDATED), object: nil)
    }
    
    @objc func appThemeUpdated(_ notification: Notification) {
        if let color = UserManager.currentUser()?.color {
            self.view.backgroundColor = UIColor(hexString: color)
        }
    }

    func tutorOpenPostNotification(){
        NotificationCenter.default.post(name: .openTutorboardNotification,object:nil ,userInfo:nil)
    }
    func tutorClosePostNotification(){
        let alert = UIAlertController(title: "Are you sure you want to close the tutorial?", message: "You can replay it later from the settings page.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
           NotificationCenter.default.post(name: .closeTutorboardNotification,object:nil,userInfo:nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
}

extension Notification.Name{
    static let closeTutorboardNotification = Notification.Name("CloseTutorboardNotificataion")
    static let openTutorboardNotification = Notification.Name("OpenTutorboardNotification")
}
