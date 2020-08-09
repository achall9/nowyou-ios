//
//  UIViewController+Extension.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

public extension UIViewController
{
    /// instaniate UIViewController from storyboard. by default the name of the storyboard and
    /// identifier should be the same as UIViewContoller's class name
    static func loadFromStoryboard<T: UIViewController>(storyboardName: String? = nil, storyboardId: String? = nil) -> T
    {
        let className   = String(describing: T.self)
        let storyboard  = UIStoryboard(name: storyboardName ?? className, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: storyboardId ?? className) as! T
    }
    
    /// Get Top Visible ViewController
    public func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
    
    /* Get ViewCtonroller From Storyboard */
    static func viewControllerWith(_ vcIdentifier: String, storyboardName: String = "Main") -> UIViewController?
    {
        let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
        let uiViewController = storyboard.instantiateViewController(withIdentifier: vcIdentifier) as UIViewController
        return uiViewController
    }
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
    }
}
