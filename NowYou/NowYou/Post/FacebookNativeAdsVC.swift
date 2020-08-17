//
//  FacebookNativeAdsVC.swift
//  NowYou
//
//  Created by mobiledev coach on 8/16/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FacebookNativeAdsVC: UIViewController {

    
    @IBOutlet var adUIView: UIView!
    @IBOutlet weak var adIconImageView: FBAdIconView!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adCoverMediaView: FBMediaView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    var nativeAd: FBNativeAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAds()
    }
    
    func initAds() {
        // Instantiate a NativeAd object.
        // NOTE: the placement ID will eventually identify this as your App, you can ignore it for
        // now, while you are testing and replace it later when you have signed up.
        // While you are using this temporary code you will only get test ads and if you release
        // your code like this to the App Store your users will not receive ads (you will get a no fill error).
        
        
        self.nativeAd = FBNativeAd.init(placementID: FBADS.PLACEMENT_ID)
        self.nativeAd.delegate = self
        self.nativeAd.loadAd()
    }
    
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
}

// MARK: FB Interstitial SDK Extensio
extension FacebookNativeAdsVC: FBNativeAdDelegate, FBMediaViewDelegate {
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
        self.adCoverMediaView.delegate = self
        nativeAd.downloadMedia()
        self.nativeAd = nativeAd
        
        self.showNativeAd()
    }
    
    func showNativeAd() {
        if self.nativeAd.isAdValid {
            self.nativeAd.unregisterView()
            
            
            self.nativeAd.registerView(forInteraction: self.adUIView, mediaView: self.adCoverMediaView, iconView: self.adIconImageView, viewController: self, clickableViews: [self.adCallToActionButton, self.adCoverMediaView])
            
            // Render Native ads onto UIView
            self.adTitleLabel.text = self.nativeAd.advertiserName
            //self.adBodyLabel.text = self.nativeAd.bodyText
            //self.adSocialContextLabel.text = self.nativeAd.socialContext
            self.sponsoredLabel.text = self.nativeAd.sponsoredTranslation
            
            self.adCallToActionButton.setTitle(self.nativeAd.callToAction, for: .normal)
            //self.adOptionsView.nativeAd = self.nativeAd
        }
    }
    
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("Native ad was clicked.")
    }
    
    func nativeAdDidFinishHandlingClick(_ nativeAd: FBNativeAd) {
        print("Native ad did finish click handling")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        print("Native ad impression is being captured")
    }
    
    
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print(error.localizedDescription)
        print("Native ad failed to load with error")
       
    }
        
}
