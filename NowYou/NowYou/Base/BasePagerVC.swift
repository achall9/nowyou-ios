//
//  BasePagerVC.swift
//  NowYou
//
//  Created by Apple on 4/21/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class BasePagerVC: ButtonBarPagerTabStripViewController {
    
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
