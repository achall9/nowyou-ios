//
//  LaunchViewController.swift
//  NowYou
//
//  Created by Apple on 2/7/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import SwiftyGif
class LaunchViewController: UIViewController {

    let logoAnimationView = LogoAnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            if let _ = TokenManager.getToken() {
                UIManager.showMain()
            } else {
                let authNav = mainStoryboard.instantiateViewController(withIdentifier: "authNav") as? UINavigationController
                appDelegate.window?.rootViewController = authNav
            }
        }

        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            logoAnimationView.logoGifImageView.startAnimatingGif()
        }
}
extension LaunchViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}

