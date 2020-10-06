//
//  ExampleProvider.swift
//  ESTabBarControllerExample
//
//  Created by Yangting on 2020/9/22.

import UIKit

enum NYTabBarProvider {
    static func customIrregularityStyle(delegate: UITabBarControllerDelegate?) -> NYNavigationController {
        let tabBarController = ESTabBarController()
        tabBarController.delegate = delegate
        tabBarController.tabBar.shadowImage = UIImage(named: "transparent")
        tabBarController.tabBar.backgroundImage = UIImage(named: "background_dark")
        tabBarController.shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tabBarController.didHijackHandler = {
            [weak tabBarController] tabbarController, viewController, index in
            
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
				let vc = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
                let nav = UINavigationController(rootViewController: vc)
                nav.isNavigationBarHidden = true
                nav.modalPresentationStyle = .fullScreen
				tabBarController?.present(nav, animated: true, completion: nil)
			}
        }

        
        let v1 = storyboard.instantiateViewController(withIdentifier: "playvc") as! PlayViewController
        let v2 = storyboard.instantiateViewController(withIdentifier: "RadioViewController") as! RadioViewController
        let v3 = UIViewController()
        let v4 = storyboard.instantiateViewController(withIdentifier: "MetricsViewController") as! MetricsViewController
        let v5 = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        v1.tabBarItem = ESTabBarItem.init(NYIrregularityBasicContentView(), title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        v2.tabBarItem = ESTabBarItem.init(NYIrregularityBasicContentView(), title: "live", image: UIImage(named: "NY_radio_live"), selectedImage: UIImage(named: "NY_radio_live"))
        v3.tabBarItem = ESTabBarItem.init(NYIrregularityContentView(), title: nil, image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig"))
        v4.tabBarItem = ESTabBarItem.init(NYIrregularityBasicContentView(), title: "Metrics", image: UIImage(named: "favor"), selectedImage: UIImage(named: "favor"))
        v5.tabBarItem = ESTabBarItem.init(NYIrregularityBasicContentView(), title: "Me", image: UIImage(named: "me"), selectedImage: UIImage(named: "me"))
        
        tabBarController.viewControllers = [v1, v2, v3, v4, v5]
        
        let navigationController = NYNavigationController.init(rootViewController: tabBarController)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
}
