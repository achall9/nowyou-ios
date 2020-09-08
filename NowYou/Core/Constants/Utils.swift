//
//  Utils.swift
//  Bucket
//
//  Created by gstream on 6/26/18.
//  Copyright © 2018 Bucket. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Reachability

class Utils: NSObject {
    
//    private let reachability = Reachability(hostname: "https://www.google.com")
    static let shared = Utils()

//    var isReachableNetwork: Bool {
//        return reachability?.connection != .none
//    }
//    
//    var isOnCelluar: Bool {
//        return reachability?.connection == .cellular
//    }
//    
//    var isOnWifi: Bool {
//        return reachability?.connection == .wifi
//    }
    
    static func getStoryboardName(_ name: String) -> String {
        return isPad() ? "\(name)_iPad" : name
    }
    
    /* Get ViewCtonroller From Storyboard */
    static func viewControllerWith(_ vcIdentifier: String, storyboardName: String = "Main") -> UIViewController? {
        let storyboard = UIStoryboard.init(name: getStoryboardName(storyboardName), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: vcIdentifier)
    }
    
    static func isPhone4() -> Bool {
        return UIScreen.main.bounds.size.equalTo(CGSize.init(width: 320.0, height: 480.0))
    }
    
    /* Check if device is iPhoneX */
    static func isIPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            if (UIScreen.main.nativeBounds.height == 2436) {
                return true
            }
        }
        
        return false
    }
    
    /* Check Pad */
    static func isPad() -> Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    // MARK: - Validators
    
    class func isValidEmail(email: String?) -> Bool {
        
        if email == nil { return false }
        
        let emailRegEx = "[A-Za-z0-9._\\-\\+]+@[A-Za-z0-9._-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func isValidPass(password: String) -> Bool {
        return !password.isEmpty
    }
    
    
    static func showSpinner() {
        let activityData = ActivityData(size: CGSize(width: 30, height: 30), message: nil, messageFont: nil, messageSpacing: 0, type: .ballClipRotateMultiple, color: .white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }

    static func hideSpinner() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil)
    }
    
    
    
    
    class func getFullPath(path: String) -> String {
//       return "http://nowyou.toplev.io\(path)"
//        return "https://staging-nowyou.herokuapp.com\(path)"
//        return "https://nowyou-staging.s3-us-west-2.amazonaws.com\(path)"
        return "https://nowyou-dev.s3-us-east-2.amazonaws.com\(path)"
    }
    
    func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
    
    func setNYViewActive(nyView: NYView, color: UIColor) {
        
        nyView.backgroundColor  = color
        nyView.shadowColor      = color
    }
    
    static func openURL(_ string: String) {
        if let url = URL(string: string) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    // check microphone permission
    static func checkMicPermission() -> Bool {
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
            
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                permissionCheck = granted
            }
        case .denied:
            permissionCheck = false
        case .granted:
            permissionCheck = true
        }
        
        return permissionCheck
    }
    static func getThumbnailFrom(path: URL) -> UIImage? {
        
        do {
            
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
    }
}
