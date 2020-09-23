//
//  UIManager.swift
//  NowYou
//
//  Created by 111 on 2020/9/22.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
class UIManager {
    static let shared = UIManager()
    
    static func showView(with storyboard: String, identifier: String, animated: Bool = false) {
        if let controller = loadViewController(storyboard: storyboard, controller: identifier) {
            self.setRootViewController(controller: controller, animated: animated)
        }
    }
    
    static func showMain(animated: Bool = false) {
        self.setRootViewController(controller: NYTabBarProvider.customIrregularityStyle(delegate: nil), animated: animated)
    }
    
    static func showIntro(animated: Bool = false) {
    }
    
    static func showLogin(animated: Bool = false) {
        
    }
    
    static func showSignUp(animated: Bool = false) {
        
    }
    
}

//Safe area
extension UIManager {
    static func bottomPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    static func topPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow else {
            return 0
        }
        return window.safeAreaInsets.top
    }
    
    static func windowFrame(of view: UIView) -> CGRect {
        var maskRect = view.convert(view.frame, to: UIApplication.shared.keyWindow!)
        maskRect.origin.y = maskRect.origin.y + UIManager.topPadding()
        return maskRect
    }
}

//Primary
extension UIManager {
    
    static func loadViewController(storyboard name: String, controller identifier: String? = nil) -> UIViewController? {
        guard let identifier = identifier else {
            return UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()
        }
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    //change root view controller
    static func setRootViewController(controller: UIViewController, animated: Bool = false) {
        DispatchQueue.main.async {
            if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
                guard let rootViewController = window.rootViewController else {
                    return
                }
                
                controller.view.frame = rootViewController.view.frame
                controller.view.layoutIfNeeded()
                
                if animated {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        let oldState: Bool = UIView.areAnimationsEnabled
                        UIView.setAnimationsEnabled(false)
                        window.rootViewController = controller
                        UIView.setAnimationsEnabled(oldState)
                    }, completion: nil)
                }
                else {
                    window.rootViewController = controller
                }
            }
            else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                appDelegate.window?.backgroundColor = UIColor.white
                appDelegate.window?.rootViewController = controller
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
