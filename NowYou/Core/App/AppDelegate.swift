//
//  AppDelegate.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseCore
import FirebaseMessaging
import Fabric
import FirebaseAuth
import Crashlytics
import UserNotifications
//import GoogleMobileAds
import AVFoundation
import Stripe

//import Appodeal
import StackConsentManager

import Braintree



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let shared = AppDelegate()
    
    var window: UIWindow?
    
    var fcmToken  : String = ""
    
    private struct AppodealConstants {
        
        static let key: String =
               "f3f242a36e3c06d0259f439fa771da4f61c57abb6ccab5ba"
//        static let adTypes: AppodealAdType = [.interstitial, .rewardedVideo, .banner]
//        static let logLevel: APDLogLevel = .debug
//        static let testMode: Bool = true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        Fabric.with([Crashlytics.self])

        //GADMobileAds.sharedInstance().start(completionHandler: nil)
        //Override point for customization after application launch.
        //initializeAppodealSDK()

        loadFramework()
        // Remote notifications
        registerForRemoteNotifications(application)
        NotificationManager.shared.initRun()
        NotificationManager.shared.notificationDelegate = self
        IQKeyboardManager.shared.enable = true
        BTAppSwitch.setReturnURLScheme("com.eduard.NowYou.toplev.payments")
        //Allow audio to play from other apps
        if AVAudioSession.sharedInstance().isOtherAudioPlaying {
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, options: AVAudioSession.CategoryOptions.mixWithOthers)
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.videoRecording, options: AVAudioSession.CategoryOptions.mixWithOthers)
          try? AVAudioSession.sharedInstance().setActive(true)
            
        } else{
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
                NSLog("Playback OK")
                
                try AVAudioSession.sharedInstance().setActive(true)
                NSLog("Session is Active")
                
            } catch {
                NSLog("ERROR: CANNOT PLAY MUSIC IN BACKGROUND. Message from code: \"\(error)\"")
                
            }
        }
        
        //play sound in recorded videos
        //try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        IQKeyboardManager.shared.disabledToolbarClasses.insert(PhotoEditorViewController.self, at: 0)
        IQKeyboardManager.shared.disabledToolbarClasses.insert(CommentViewController.self, at: 1)
        IQKeyboardManager.shared.disabledToolbarClasses.insert(RadioDetailsViewController.self, at: 2)
        IQKeyboardManager.shared.disabledToolbarClasses.insert(StreamViewController.self, at: 3)
        
        self.window?.makeKeyAndVisible()
                
        //request Stripe Api
        Stripe.setDefaultPublishableKey(API.STRIPE_PUBLISH_KEY)
        
        let launchScreen = UIViewController.viewControllerWith("LaunchViewController") as! LaunchViewController
        self.window?.rootViewController = launchScreen
        
//        synchroniseConsent()
        return true
    }
    
//--- Appodeal : start
    // MARK: Appodeal Initialization
    /*
    private func initializeAppodealSDK() {

        Appodeal.setTestingEnabled(AppodealConstants.testMode)
        Appodeal.setLogLevel(AppodealConstants.logLevel)
        Appodeal.setAutocache(true, types: AppodealConstants.adTypes)
        
        let consent = STKConsentManager.shared().consentStatus != .nonPersonalized
        Appodeal.initialize(
            withApiKey: AppodealConstants.key,
            types: AppodealConstants.adTypes,
            hasConsent: consent
        )
    }
    */
    
    // MARK: Consent manager
    private func synchroniseConsent() {
        STKConsentManager.shared().synchronize(withAppKey: AppodealConstants.key) { error in
            error.map { print("Error while synchronising consent manager: \($0)")}
            guard STKConsentManager.shared().shouldShowConsentDialog == .true else {
                //self.initializeAppodealSDK()
                return
            }

            STKConsentManager.shared().loadConsentDialog { [unowned self] error in
                error.map { print("Error while loading consent dialog: \($0)") }
                guard let controller = self.window?.rootViewController, STKConsentManager.shared().isConsentDialogReady else {
                    //self.initializeAppodealSDK()
                    return
                }
                STKConsentManager.shared().showConsentDialog(fromRootViewController: controller,delegate: self)
            }
        }
    }
//--- Appodeal : End

    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.eduard.NowYou.toplev.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }

    // Respond to Universal Links
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.isOtherAudioPlaying {
                   _ = try? audioSession.setCategory(AVAudioSession.Category.ambient, options: AVAudioSession.CategoryOptions.mixWithOthers)
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.shared.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}


// MARK: - AppDelegate helper methods
extension AppDelegate {
    func loadFramework() {
        // Firebase
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        // IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }

    // [START handle_remote_notification_app_launch]
    func handleRemoteNotificationAppLaunch(_ launchOptions: [AnyHashable: Any]?) {
        guard let launchOptions = launchOptions else { return }
        guard let notificationInfo = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] else { return }
    }
    // [END handle_remote_notification_app_launch]
}


// MARK: - UNUserNotificationDelegate

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NotificationManager.shared.handleRemoteNotification(userInfo)
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationManager.shared.handleRemoteNotification(userInfo)
        completionHandler()
    }
    
}
extension AppDelegate: NotificationDelegate{
    
    func pushDirect(_ userInfo: [AnyHashable: Any]) {
        if userInfo["radioStationId"] == nil {return}
        if userInfo["profileIconPath"] == nil {return}
        let radioStationId = (userInfo["radioStationId"] as! String)
            print("radioStaionId= ",radioStationId)
        let profileIconPath = (userInfo["profileIconPath"] as! String)
            print("profileIconPath= ",profileIconPath)
// -------testing-------
//        let radioObj = RadioStation(json:
//        ["name": "Something",
//        "views":0,
//        "category_name":"Second",
//        "user_id":75,
//        "id":129,
//        "category_id":84,
//        "hash_tag_array":["world"],
//        "hash_tag":"world",
//        "updated_at": "2020-01-18 23:44:53",
//        "radios":[
//            "id": 217,
//            "created_at":"2020-01-18 23:44:58",
//            "station_id":129,
//            "path":"/radio/audio-5e23360a4484e.m4a",
//            "views":12,
//            "name":"Something",
//            "updated_at":"2020-01-30 05:22:38"],
//        "created_at": "2020-01-18 23:44:53"])
//
//
//        let homeVC = UIApplication.shared.windows[0].rootViewController as! HomeViewController
//        let home = UIStoryboard(name: "Main", bundle: nil)
//        let vc = home.instantiateViewController(withIdentifier: "RadioDetailsVC") as! RadioDetailsViewController
//        vc.radio = radioObj
//        let radioNav = UINavigationController(rootViewController: vc)
//        homeVC.focusViewController?.navigationController?.topViewController?.present(radioNav, animated: true, completion: nil)
//
        NotificationCenter.default.post(name:.radioIsOnBroadcastingNotification, object: nil, userInfo: ["radioStationId" : radioStationId, "profileIconPath" : profileIconPath])
        NetworkManager.shared.getRadioStation(radio_station_id: Int(radioStationId)!) { (response) in

          switch response {
          case .error( _):
            break
          case .success(let data):
              do {
                  let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                  if let json = jsonRes as? [String: Any], let radioJson = json["radio_station"] as? [String: Any] {

                    let radioObj = RadioStation(json: radioJson)
                    NotificationCenter.default.post(name:.radioIsOnBroadcastingToFeedNotification, object: nil, userInfo: ["radioObj" : radioObj, "profileIconPath" : profileIconPath])
                      DispatchQueue.main.async {
                        if let homeVC = Utils.shared.getTopViewController(){
                            let home = UIStoryboard(name: "Main", bundle: nil)
                            let vc = home.instantiateViewController(withIdentifier: "RadioDetailsVC") as! RadioDetailsViewController
                            vc.radio = radioObj
                            let radioNav = UINavigationController(rootViewController: vc)
                            homeVC.present(radioNav, animated: true, completion: nil)
                        }
                      }
                  }
              } catch {

              }
          }
        }
        return 
    }
}


extension Notification.Name {
    static let radioIsOnBroadcastingNotification = Notification.Name("RadioIsOnBroadcastingNotification")
    static let radioIsOnBroadcastingToFeedNotification =
        Notification.Name("RadioIsOnBroadcastingToFeedNotification")
    static let taggedUserNotification = Notification.Name("TaggedUserNotification")
}

extension AppDelegate: STKConsentManagerDisplayDelegate {
    func consentManagerWillShowDialog(_ consentManager: STKConsentManager) {}
    
    func consentManager(_ consentManager: STKConsentManager, didFailToPresent error: Error) {
        //initializeAppodealSDK()
    }
    
    func consentManagerDidDismissDialog(_ consentManager: STKConsentManager) {
        //initializeAppodealSDK()
    }
}
