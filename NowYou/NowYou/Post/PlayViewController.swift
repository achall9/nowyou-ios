//
//  PlayViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import AnimatedCollectionViewLayout
import Appodeal
import Player
import CRRefresh
import SwiftyJSON

class PlayViewController: EmbeddedViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var dismissGesture: UISwipeGestureRecognizer!
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var feedIntroIV: UIImageView!
    @IBOutlet weak var btnCloseTutor: UIButton!

    var videoPlayer:Player = Player()
    var playerUrls = [URL]()
    
    var animator = (CubeAttributesAnimator(), true, 1, 1)
    var direction: UICollectionView.ScrollDirection = .vertical

    let cellIdentifier = "cell"
    
    var totalLengthOfPlayItems = Double(0.0) // min
    
    var medias = [Media]()
    var currentIndex: Int = 0
    
    var viewFromFeed: Bool = false
    var viewFromProfile: Bool = false
    var viewFromUserStory: Bool = false
    
    var interactor =  Interactor()
    let transition = CATransition()
    
    var isFirstLoad: Bool = true
    var isPaged: Bool = false
    
    /// The interstitial ad.
    var interstitial: GADInterstitial!
    /// The reward-based video ad.
    var rewardBasedVideo: GADRewardBasedVideoAd?
        
    var adFiredIndex: Int = 0
    var adFiredIndex_banner: Int = 0
    var timeFromAdFired: Double = 0.0
    var singleTapGesture: UITapGestureRecognizer!
    
    let audioSession = AVAudioSession.sharedInstance()
    
    var volumeObserved: Bool = false
    
    var mEndPageSelected : Bool = false
    var mIndexpathRow : Int = 0
    
    var progressValue : Float = 0
    var timer : Timer?
    var photoShowTime: Float = 0.0
    var boundsHeight : Int = 0
    
    var prevButton: Int = 100
    
    var firstPlay = false
    
    //-----Added for Tabs
    var storys = [Media]()
    var posts = [Media]()
    var sortedPosts = [[Media]]() // sorted by created date
    var todayUserPosts = [Media]() // posted in last 24 hours by current user
    
    var broadcastCount : Int = 0 // for radio broadcasting
    var radioObjArray = [Int: RadioStation]()
    var profileIconPathArray = [Int: String]()
    var profileIconFullPath : String = ""

    var feedPageId: Int = 0
    var viralPageId: Int = 0
    var tagPageId: Int = 0
    
    var feedPosts = [Media]()
    var viralPosts = [Media]()
    var tagPosts = [Media]()
    
    var tabFeedTimer : Timer?
    var tabViralTimer : Timer?
    var tabTagTimer : Timer?
    
    var viralDataCounts : Int = 0
    var feedDataCounts: Int = 0
    var tagDataCounts: Int = 0
    var tutorboardShown: Bool = false
    let pageLimit = 10
    var longPress = false
    //-------------------
    // MARK: object lifecycle
    deinit {
        self.videoPlayer.willMove(toParent: nil)
        if self.videoPlayer.view.superview != nil {
            self.videoPlayer.view.removeFromSuperview()
        }
        
        self.videoPlayer.removeFromParent()
        
        if volumeObserved {
            audioSession.removeObserver(self, forKeyPath: "outputVolume")
            volumeObserved = false
        }
                
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCollectionView()
        setupGesture()
        listenVolumeButton()
        initVideoPlayer()
        initTabs()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reportedPost(notification:)),
        name: .reportedPostSuccessfully, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
        
      
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        profileIconFullPath  = ""
        initValue()

        feedIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
        let feedShown = UserDefaults.standard.bool(forKey: "feedShown")
        if !feedShown {
           feedIntroIV.alpha = 1.0
           btnCloseTutor.alpha = 1.0
           UserDefaults.standard.set(true, forKey: "feedShown")
           btnCloseTutor.isEnabled = true
           tutorboardShown = true
        }else{
            tutorboardShown = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(firstVideoPlay(notification:)), name: .gotoPlayViewController, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reportedPost(notification:)),
        name: .reportedPostSuccessfully, object: nil)
        
        if self.videoPlayer.playbackState == .paused {
           self.videoPlayer.playFromCurrentTime()
        }
        
       }
       @objc func openTutor(notification: Notification){
           feedIntroIV.alpha = 1.0
           btnCloseTutor.alpha = 1.0
           UserDefaults.standard.set(true, forKey: "feedShown")
           btnCloseTutor.isEnabled = true
           tutorboardShown = true
       }
       @objc func closeTutor(notification: Notification){
           feedIntroIV.alpha = 0.0
           btnCloseTutor.alpha = 0.0
           btnCloseTutor.isEnabled = false
           tutorboardShown = false
       }
       @objc func firstVideoPlay(notification: Notification){
        
            playerUrls.removeAll()
            if self.medias.count == 0 {
                return
            }else{
                self.openBannerAd()
                let media = self.medias[0]
                if media.type != 0 { // video
                    let path = Utils.getFullPath(path: media.path!)
                    playerUrls.append(URL(string: path)!)
                    if media.extras.count > 0 {
                        for extraIndex in 0...media.extras.count - 1 {
                            let extraMedia = media.extras[extraIndex]
                            let extraMediaPath = Utils.getFullPath(path: extraMedia.path!)
                            let extraItem = URL(string: extraMediaPath)!
                            playerUrls.append(extraItem)
                        }
                    }
                    firstPlay = true
                    playVideoItems(currentCellIndex: 0)
                }
            }
       }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        try? audioSession.setCategory(.ambient, options: .mixWithOthers)
        try? audioSession.setActive(true)
        UIApplication.shared.isStatusBarHidden = false
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let vc = segue.destination as! CommentViewController
            vc.media = medias[mIndexpathRow]
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume" {
             print ("volume changed")
             try? audioSession.setCategory(.ambient, options: .mixWithOthers)
             try? audioSession.setActive(true)
         }
     }
    
    override func viewDidLayoutSubviews() {
        if viewFromFeed || viewFromProfile {
            print ("scroll to index \(currentIndex)")
            viewFromFeed = false
            
            viewFromProfile = false
            if medias.count > 0, currentIndex < medias.count {
                collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredVertically, animated: true)
                
            }else{
                print("exit")
            }
        }
    }
 
    private func initValue(){
        Appodeal.setInterstitialDelegate(self)
        Appodeal.setRewardedVideoDelegate(self)
        Appodeal.setBannerDelegate(self)
        mEndPageSelected = false
        mIndexpathRow = 0
        
        feedPageId = 0
        tagPageId = 0
        viralPageId = 0
        
    
    }
    
    private func initCollectionView(){
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = direction
//            layout.animator = animator.0
        }

    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    @objc func reportedPost(notification: Notification){
        if medias.count > 0, mIndexpathRow < medias.count {
            medias.remove(at: mIndexpathRow)
            currentIndex = mIndexpathRow
            collectionView.reloadData()
        }else{
            print("exit")
        }
    }
    private func setupGesture(){
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapCollectionView(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2  // add double tap
        self.collectionView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTapCollectionView(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1  // add single tap
        singleTapGesture.require(toFail: doubleTapGesture)
        self.collectionView.addGestureRecognizer(singleTapGesture)
        
        let longTapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longTapGesture)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    private func initVideoPlayer(){
        
        self.videoPlayer.playerDelegate = self
        self.videoPlayer.playbackDelegate = self

        self.videoPlayer.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 90.0)
        self.videoPlayer.playerView.playerBackgroundColor = .black
        self.videoPlayer.autoplay = false
        self.videoPlayer.fillMode = .resize
        self.addChild(self.videoPlayer)
        self.videoPlayer.didMove(toParent: self)
    }
    

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if !tutorboardShown {
            if (sender.direction == .left) {
                print("Swipe left")
                tabsLeftSwipe()
            }
        }
        if (sender.direction == .right) {
            print("Swipe right")
            tabsRightSwipe()
        }
    }
    
    private func initTabs(){
//        getAllFeedData()
//        btnTabs[0].removeBottomLine()
//        btnTabs[2].removeBottomLine()
//        btnTabs[1].drawBottomLine()
//        prevButton = 100
        getAllViralData()
//        NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
        btnTabs[1].removeBottomLine()
        btnTabs[2].removeBottomLine()
        btnTabs[0].drawBottomLine()
        prevButton = 101
     }
    func tabsLeftSwipe(){
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        if self.videoPlayer.view.superview != nil {
            self.videoPlayer.view.removeFromSuperview()
        }
        self.timer?.invalidate()
        self.timer = nil
        
        mIndexpathRow = 0
        currentIndex = mIndexpathRow
        switch prevButton {
           case 100:
//               getAllViralData()
//               NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
//               btnTabs[1].removeBottomLine()
//               btnTabs[2].removeBottomLine()
//               btnTabs[0].drawBottomLine()
//               prevButton = 101
               break
           case 101:
//               getAllTagData()
//               NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
//               btnTabs[0].removeBottomLine()
//               btnTabs[1].removeBottomLine()
//               btnTabs[2].drawBottomLine()
//               prevButton = 102
               break
           default:
               break
        }
    }
    
    func tabsRightSwipe(){
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        if self.videoPlayer.view.superview != nil {
            self.videoPlayer.view.removeFromSuperview()
        }
        self.timer?.invalidate()
        self.timer = nil
        
        mIndexpathRow = 0
        currentIndex = mIndexpathRow
        switch prevButton {
           case 100:
                self.videoPlayer.pause()
                NotificationCenter.default.post(name: .goToHomeFromPlayViewEnable, object: self)
                break
           case 101:
//               btnTabs[0].removeBottomLine()
//               btnTabs[2].removeBottomLine()
//               btnTabs[1].drawBottomLine()
//               prevButton = 100
//               medias.removeAll()
//               medias = feedPosts
//               collectionView.reloadData()
//               NotificationCenter.default.post(name: .goToHomeFromPlayViewEnable, object: self)
               break
           case 102:
//               NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
//               btnTabs[1].removeBottomLine()
//               btnTabs[2].removeBottomLine()
//               btnTabs[0].drawBottomLine()
//               medias.removeAll()
//               medias = viralPosts
//               collectionView.reloadData()
//               prevButton = 101
               break
           default:
               break
        }
    }
    
    // ------ tabs

    @IBAction func onTapTabs(_ sender: UIButton) {
        
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        if self.videoPlayer.view.superview != nil {
            self.videoPlayer.view.removeFromSuperview()
        }
        self.timer?.invalidate()
        self.timer = nil
        
        mIndexpathRow = 0
        currentIndex = mIndexpathRow
        switch sender.tag {
        case 100:
            getAllFeedData()
            sender.drawBottomLine()
            btnTabs[0].removeBottomLine()
            btnTabs[2].removeBottomLine()
            prevButton = sender.tag
//            medias.removeAll()
//            medias = feedPosts
//            collectionView.reloadData()
        
            NotificationCenter.default.post(name: .goToHomeFromPlayViewEnable, object: self)
            break
        case 101:
            getAllViralData()
            sender.drawBottomLine()
            btnTabs[1].removeBottomLine()
            btnTabs[2].removeBottomLine()
            prevButton = sender.tag
//            medias.removeAll()
//            medias = viralPosts
//            collectionView.reloadData()
//             NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
            break
        case 102:
            getAllTagData()
            sender.drawBottomLine()
            btnTabs[0].removeBottomLine()
            btnTabs[1].removeBottomLine()
            prevButton = sender.tag
//            medias.removeAll()
//            medias = tagPosts
//            collectionView.reloadData()
//            NotificationCenter.default.post(name: .goToHomeFromPlayViewDisable, object: self)
            break
        default:
            break
        }
    }
    
    //-------- tabs end//
    
    func listenVolumeButton(){
        volumeObserved = true
        audioSession.addObserver(self, forKeyPath: "outputVolume",
                                 options: NSKeyValueObservingOptions.new, context: nil)
    }
 
    
    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromBottom
        view.window?.layer.add(transition, forKey: nil)

        if let homeVc = presentingViewController {
            homeVc.view.alpha = 1.0
        }
        
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        self.timer?.invalidate()
        self.timer = nil
        
        self.tabViralTimer?.invalidate()
        self.tabViralTimer = nil
        
        self.tabFeedTimer?.invalidate()
        self.tabFeedTimer = nil
        
        self.tabTagTimer?.invalidate()
        self.tabTagTimer = nil
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
        NotificationCenter.default.post(name: .goToHomeFromPlayViewEnable, object: self)
        navigationController?.popViewController(animated: false)
    }
    
    
    @objc func didDoubleTapCollectionView(gesture: UITapGestureRecognizer) {

        let pointInCollectionView: CGPoint = gesture.location(in: self.collectionView)
        let selectedIndexPath: IndexPath = collectionView.indexPathForItem(at: pointInCollectionView)!
        
        let indexPath = IndexPath(row: selectedIndexPath.row, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! PostViewCell
        cell.btnLike.isSelected = !cell.btnLike.isSelected
        
        let media = medias[selectedIndexPath.row]

        if media.liked {
            NetworkManager.shared.unlike(media_id: media.id!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    media.liked = false
                }
            }
        } else {
            NetworkManager.shared.like(media_id: media.id!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    media.liked = true
                }
            }
        }
    }

    @objc func longTapGesture(gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            
            if self.videoPlayer.playbackState == .playing {
                longPress = true
                self.videoPlayer.pause()
                
            }
        }
        else if gesture.state == .ended {
            if self.videoPlayer.playbackState == .paused {
                longPress = false
                self.videoPlayer.playFromCurrentTime()
            }
        }
        
    }
    
    @objc func didSingleTapCollectionView(gesture: UITapGestureRecognizer) {

//        self.photoShowTime = 0.0
//        self.timer?.invalidate()
//        self.timer = nil
//        print ("scroll to index \(currentIndex)")
//        currentIndex = mIndexpathRow
//        currentIndex = currentIndex + 1
//        if medias.count > 0, currentIndex < medias.count {
//            if(gesture.state == .ended){
//                totalLengthOfPlayItems = 0.0
//                collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredVertically, animated: true)
//            }
//
//        }else{
//            print("exit")
//        }
    }
    private func openBannerAd(){
        if Appodeal.isReadyForShow(with: .bannerBottom){
             Appodeal.hideBanner()
             Appodeal.banner()?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50 )
             Appodeal.showAd(AppodealShowStyle.bannerBottom, rootViewController: self)
        }else if  Appodeal.isReadyForShow(with: .bannerTop){
             Appodeal.hideBanner()
             Appodeal.banner()?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
             Appodeal.showAd(AppodealShowStyle.bannerTop, rootViewController: self)
        }
    }
    
    private func openAd(_ selectedIndex: Int){
    // decide to show interestitial ad or reward video ad
        let randomDiff = Int.random(in: 10..<15)
        if abs(selectedIndex - 1 - adFiredIndex) > randomDiff {
            if randomDiff % 2 == 0 { // interestitial
                    if Appodeal.isReadyForShow(with: .interstitial){
                            Appodeal.showAd(AppodealShowStyle.interstitial, rootViewController: self)
                        adFiredIndex = selectedIndex
                    } else {
                        print ("interestitial ad is not ready") // show reward ad video instead if possible
                        if Appodeal.isReadyForShow(with: .rewardedVideo){
                            Appodeal.showAd(AppodealShowStyle.rewardedVideo, rootViewController: self)
                            adFiredIndex = selectedIndex
                        }
                    }
                } else { // reward
                    if Appodeal.isReadyForShow(with: .rewardedVideo){
                        Appodeal.showAd(AppodealShowStyle.rewardedVideo, rootViewController: self)
                        adFiredIndex = selectedIndex
                    }else{
                         print ("rewarded ad is not ready") // show interstitial ad video instead if possible
                        if Appodeal.isReadyForShow(with: .interstitial){
                                Appodeal.showAd(AppodealShowStyle.interstitial, rootViewController: self)
                                    adFiredIndex = selectedIndex
                        }
                    }
                }//---end if randomDiff % 2 == 0
           }//-- end  if abs(selectedIndexPath.row - 1 - adFiredIndex) > randomDiff {
    }
    
    @IBAction func onReport(_ sender: Any){
        let reportVC = ReportVC(nibName: String(describing: ReportVC.self), bundle: nil)
        reportVC.postId = medias[mIndexpathRow].id
        present(reportVC, animated: false)
    }
    
    @IBAction func actionSharePost(_ sender: UIButton) {
        print("clicked share button")
        let media = self.medias[currentIndex]
       
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.sharePost(postId: media.id!) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if jsonRes as? Int == 1 {
                                self.present(Alert.alertWithTextInfo(errorText: "Shared the post!"), animated: true, completion: nil)
                                self.getAllViralData()
                            } else {
                                self.present(Alert.alertWithTextInfo(errorText: "Please try again!"), animated: true, completion: nil)
                                return
                            }
                            
                        } catch {}
                }
                
            }
        }
    }
    
    
    @IBAction func didSwipeUp(_ sender: Any) {
//        print ("to comments")
//        performSegue(withIdentifier: "toComments", sender: nil)
    }

    @objc func onMute(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        self.videoPlayer.muted = !self.videoPlayer.muted
    }
    
    @objc func onComments(sender: UIButton) {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    @IBAction func gotoProfile(_ sender: Any) {
        print("other profile")
        guard let userID = medias[mIndexpathRow].userId else{return}
        timer?.invalidate()
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.getUserDetails(userId: userID) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let json = jsonRes as? [String: Any] {
                            let isFollowing = json["is_following"] as? Bool ?? false
                            if let userJson = json["user"] as? [String: Any] {
                               let user = User(json: userJson)
                                
                                var postsSeenIds = [Int]()
                                if let postsSeen = userJson["posts_seen"] as? [[String: Any]] {
                                    for post in postsSeen {
                                        let post = Media(json: post)
                                        postsSeenIds.append(post.id!)
                                    }
                                }
                                var posts = [Media]()
                                if let postsJson = userJson["posts"] as? [[String: Any]] {
                                    for post in postsJson {
                                        let p = Media(json: post)
                                        if postsSeenIds.contains(p.id!) {
                                            p.isSeen = true
                                        }
                                        posts.append(p)
                                    }
                                }
                                let searchUser = SearchUser(searchUser: user, following: isFollowing, posts: posts)
                                
                               let profile = UIViewController.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
                               profile.blockerTap = false
                               profile.user = searchUser
                               profile.transitioningDelegate = self
                               profile.interactor = self.interactor
                               if searchUser.user?.userID == UserManager.currentUser()?.userID{
                                    profile.isSelf = true
                               }else{
                                    profile.isSelf = false
                               }
                               self.transition(to: profile)
                            }
                        }
                    } catch {
                    }
                }//--end  switch response
            }//--end  DispatchQueue.main.async
        }//--end
    }

    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    @objc func onLikes(sender: UIButton)  {
        sender.isSelected = !sender.isSelected
        
        let index = sender.tag - 101
        
        let media = medias[index]
        
        if media.liked {
            NetworkManager.shared.unlike(media_id: media.id!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    media.liked = false
                }
            }
        } else {
            NetworkManager.shared.like(media_id: media.id!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    media.liked = true
                }
            }
        }
    }
    func logAdViewOrClickFromFeed(clickAd: Int) {
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        guard medias.count > self.adFiredIndex else { return }
        guard let mediaID = medias[self.adFiredIndex].id else { return }
        NetworkManager.shared.logAdView(postId: mediaID, type: 0, clickAd: clickAd) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            switch response {
               case .error(let error):
                   print (error.localizedDescription)
                   break
               case .success(let data):
                   do {
                       let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                       if let json = jsonRes as? [String: Any] {
                           if let message = json["success"] as? String {

                             print(message)
                             print("Sent logAdView infor successfully")
                            }
                       }
                   } catch {
                       
                   }
                   break
               }
            }
        }
    }
}


extension PlayViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostViewCell
            // remove image
        
            openBannerAd()

            cell.imageView.image = nil
            cell.btnLike.isSelected = false
//            if medias.count > 0 {
                let media = self.medias[indexPath.row]
               
                if media.liked {
                    cell.btnLike.isSelected = true
                } else {
                    cell.btnLike.isSelected = false
                }
                cell.lblViewsCount.text = "\(media.views)" + " Views"
        // TimeStamp
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "MMM dd, hh:mm a"
                cell.lblTimestamp.text = media.username! + ", " + formatter.string(from: media.created)
                print(formatter.timeZone ?? "")
                cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: media.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                cell.imgProfile.setCircular()
        //--End TimeStamp
                print ("current cell index = \(indexPath.row)")
                print(media)
                if media.type == 0 {
                    cell.imageView.sd_setImage(with: URL(string: Utils.getFullPath(path: media.path!)), completed: nil)
        //--show time bar
                    for subview in cell.progressContainer.arrangedSubviews {
                        subview.removeFromSuperview()
                    }
                    cell.progressContainer.isHidden = false
                    
                    let defaultProgressView = UIProgressView(progressViewStyle: .default)
                    defaultProgressView.progress = 0.0
                    defaultProgressView.tintColor = UIColor.white
                    
                    cell.progressContainer.addArrangedSubview(defaultProgressView)
                    
                    //-- Show time bar
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (_) in
                            print("image")
                            if let subProgressView = cell.progressContainer.arrangedSubviews[0] as? UIProgressView {
                                if self.photoShowTime >= 1.0 {
                                    self.timer?.invalidate()
                                    self.timer = nil
                                }else{
                                    self.photoShowTime += 0.005
                                    subProgressView.progress = self.photoShowTime
                                }
                            }
                        })
                    //--End time bar
                    cell.btnMute.alpha = 0.0
                    cell.btnMute.isEnabled = false
                } else {
                    // add progress bar
                    cell.btnMute.alpha = 1.0
                    cell.btnMute.isEnabled = true
                    cell.progressContainer.isHidden = false
                    cell.imageView.sd_setImage(with: URL(string: Utils.getFullPath(path: media.thumbnail ?? "")), completed: nil)
                    
                    for subview in cell.progressContainer.arrangedSubviews {
                        subview.removeFromSuperview()
                    }
                    
                    let defaultProgressView = UIProgressView(progressViewStyle: .default)
                    defaultProgressView.progress = 0.0
                    defaultProgressView.tintColor = UIColor.white
                    
                    cell.progressContainer.addArrangedSubview(defaultProgressView)
                    
                    if media.extras.count > 0 {
                        for extraIndex in 0...media.extras.count - 1 {
                            let extraMedia = media.extras[extraIndex]
                            
                            let progressView = UIProgressView(progressViewStyle: .default)
                            progressView.progress = 0.0
                            progressView.tintColor = UIColor.white
                            progressView.tag = extraMedia.id
                            cell.progressContainer.addArrangedSubview(progressView)
                            // addd link button for each extra media
                        }
                    }
                    
                    cell.containerView.layoutIfNeeded()
                    
    //                if indexPath.row == currentIndex {
                        totalLengthOfPlayItems = 0.0
                        playerUrls.removeAll()
                        let media = self.medias[indexPath.row]
                        
                        let path = Utils.getFullPath(path: media.path!)
                        playerUrls.append(URL(string: path)!)
                        totalLengthOfPlayItems += CMTimeGetSeconds(AVPlayerItem(url: URL(string: path)!).duration) / 60.0
                        
                        if media.extras.count > 0 {
                            for extraIndex in 0...media.extras.count - 1 {
                                let extraMedia = media.extras[extraIndex]
                                
                                let extraMediaPath = Utils.getFullPath(path: extraMedia.path!)
                                let extraItem = URL(string: extraMediaPath)!
                                playerUrls.append(extraItem)
                                
                                totalLengthOfPlayItems += CMTimeGetSeconds(AVPlayerItem(url: extraItem).duration) / 60.0
                            }
                        }
                        
                        self.videoPlayer.view.frame = cell.imageView.frame
                        self.videoPlayer.url = playerUrls.first
                        if self.videoPlayer.view.superview != nil {
                            self.videoPlayer.view.removeFromSuperview()
                        }
                        if indexPath.row == 0 && prevButton == 100 {
                           
                        } else if self.firstPlay {
                            
                             self.videoPlayer.playFromBeginning()
                        } else {
                            
                    }
                        cell.containerView.insertSubview(self.videoPlayer.view, at: 0)
    //                }
                }
                
                if let link = media.link {
                    
                    cell.lblLink.isHidden = true
                    
                    cell.lblLink.customize { (label) in
                        label.text = link
                        label.textColor = UIColor.white
                        label.URLColor = UIColor.white
                        label.URLSelectedColor = UIColor.white
                        
                        label.enabledTypes = [.url]
                        
                        label.handleURLTap({ (url) in
                            Utils.openURL(url.absoluteString)
                        })
                        
                        label.configureLinkAttribute = { (type, attributes, isSelected) in
                            
                            var atts = attributes
                            
                            switch type {
                            case .url:
                                atts[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                                break
                            default:
                                break
                            }
                            return atts
                        }
                    }
                } else {
                    cell.lblLink.isHidden = true
                }
                if media.userId != UserManager.currentUser()?.userID{
                    NetworkManager.shared.logViewFeed(media_id: media.id!) { (_) in
                               
                    }
                }
               
                cell.btnComment.tag = indexPath.row + 100
                cell.btnComment.addTarget(self, action: #selector(onComments(sender:)), for: .touchUpInside)
                
                cell.btnLike.tag = indexPath.row + 101
                cell.btnLike.addTarget(self, action: #selector(onLikes(sender:)), for: .touchUpInside)
                
                cell.btnMute.tag = 104
                cell.btnMute.addTarget(self, action: #selector(onMute(sender:)), for: .touchUpInside)
                // add button for link view area
                
                for subview in cell.contentView.subviews {
                    if subview is UIButton {
                        subview.removeFromSuperview()
                    }
                }
                
                let linkButton = UIButton(frame: CGRect(x: media.x, y: media.y, width: media.width, height: media.height))
                cell.contentView.addSubview(linkButton)
                
                linkButton.addTarget(self, action: #selector(openLink(sender:)), for: .touchUpInside)
                linkButton.tag = indexPath.row + 102
                
                let rotation = linkButton.transform.rotated(by: CGFloat(media.angle))
                linkButton.transform = rotation

                for extraMediaIdx in 0..<media.extras.count {
                    let extraMedia = media.extras[extraMediaIdx]
                    guard let _ = extraMedia.link else {continue}
                    
                    let extraLinkButton = UIButton(frame: CGRect(x: extraMedia.x, y: extraMedia.y, width: extraMedia.width, height: extraMedia.height))
                    cell.contentView.addSubview(extraLinkButton)
                    extraLinkButton.addTarget(self, action: #selector(openExtraMediaLink(sender:)), for: .touchUpInside)
                    extraLinkButton.tag = indexPath.row + 103
                    
                    let exrotation = extraLinkButton.transform.rotated(by: CGFloat(extraMedia.angle))
                    extraLinkButton.transform = exrotation
                }
                mIndexpathRow = indexPath.row
//            }
            
            return cell
//        }
        //------------------
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        if mIndexpathRow == (medias.count - 1) {
            if mEndPageSelected == false{
                mEndPageSelected = true
            }else{
                print("exit")
            }
            
        }else{
            
            print("Continue")
            self.photoShowTime = 0.0
            self.timer?.invalidate()
            self.timer = nil
        }
       
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        let h = scrollView.bounds.size.height
        let currentPage = Int(ceil(y/h))
        // Do whatever with currentPage.
       
        print ("current page = \(currentPage)")

        if currentPage < medias.count {
            openAd(currentPage)
            openBannerAd()
            isPaged = true

            NotificationCenter.default.removeObserver(self)

            playerUrls.removeAll()

            totalLengthOfPlayItems = 0.0

            if self.videoPlayer.playbackState == .playing {
                self.videoPlayer.pause()
            }
            let media = medias[currentPage]
            if media.type != 0 { // video
                let path = Utils.getFullPath(path: media.path!)
                playerUrls.append(URL(string: path)!)
                if media.extras.count > 0 {
                    for extraIndex in 0...media.extras.count - 1 {
                        let extraMedia = media.extras[extraIndex]

                        let extraMediaPath = Utils.getFullPath(path: extraMedia.path!)
                        let extraItem = URL(string: extraMediaPath)!
                        playerUrls.append(extraItem)
                    }
      
                }
                
                if(!longPress){
                    playVideoItems(currentCellIndex: currentPage)
                }
                    
            }
        } else{
             self.collectionView.scrollToItem(at: IndexPath(row: currentPage - 1, section: 0), at: .centeredVertically, animated: false)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: view.bounds.width , height: view.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        collectionView.deselectItem(at: indexPath, animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func openExtraMediaLink(sender: UIButton) {
        let tag = sender.tag - 103
        
        let media = medias[tag]
        
        if media.type == 1 && playerUrls.count > 1 {
            for itemIndex in 0...playerUrls.count - 1 {
                let playerItem = playerUrls[itemIndex]
                
                if playerItem == self.videoPlayer.url {
                    // get extra media
                    let extraMedia = media.extras[itemIndex - 1]
                    
                    if let link = extraMedia.link {
                        if link.hasPrefix("http") {
                            Utils.openURL(link)
                        } else {
                            Utils.openURL("http://\(link)")
                        }
                    }
                }
            }
        }
    }
    
    @objc func openLink(sender: UIButton) {
        let tag = sender.tag - 102
        
        let media = medias[tag]
        
        print ("link clicked")
        
        if let link = media.link {
            if link.hasPrefix("http") {
                Utils.openURL(link)
            } else {
                Utils.openURL("http://\(link)")
            }
            
        }
    }
    
    func playNextItem(nextPlayItem: URL) {
        if self.videoPlayer.playbackState == .playing || self.videoPlayer.playbackState == .paused {
            self.videoPlayer.stop()
        }
        self.videoPlayer.url = nextPlayItem
        self.videoPlayer.playFromBeginning()
    }
    
    func playVideoItems(currentCellIndex: Int) {
        
        guard playerUrls.count != 0 else {
            return
        }
     
        
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentCellIndex, section: 0)) as? PostViewCell else {
            return
        }
        
        self.videoPlayer.url = playerUrls.first
        if self.videoPlayer.view.superview != nil {
            self.videoPlayer.view.removeFromSuperview()
        }
        cell.containerView.insertSubview(self.videoPlayer.view, at: 0)
        self.videoPlayer.playFromBeginning()
    }
    
    func playAtIndex(index: NSInteger) {
        
    }
    
    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        print("")
    }
}

extension PlayViewController: AppodealInterstitialDelegate {
    // Method called when precache (cheap and fast load) or usual interstitial view did load
    //
    // - Warning: If you want show only expensive ad, ignore this callback call with precache equal to YES
    // - Parameter precache: If precache is YES it's mean that precache loaded
    func interstitialDidLoadAdIsPrecache(_ precache: Bool) {
        
    }

    // Method called if interstitial mediation failed
    func interstitialDidFailToLoadAd() {
        
    }

    func interstitialDidFailToPresent() {

    }
    // Method called when interstitial will display on screen
    func interstitialWillPresent() {
        
    }

    // Method called after interstitial leave screeen
    func interstitialDidDismiss() {
        print("ad dismissed")
        if self.videoPlayer.playbackState == .paused {
            self.videoPlayer.playFromCurrentTime()
        }
        logAdViewOrClickFromFeed(clickAd: 0)
    }

    // Method called when user tap on interstitial
    func interstitialDidClick() {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        logAdViewOrClickFromFeed(clickAd: 1)
        print("interstitialWillLeaveApplication")
    }
    
    // Method called when interstitial did expire and could not be shown
    func interstitialDidExpired(){
        
    }
}

extension PlayViewController: AppodealRewardedVideoDelegate {
    // Method called when rewarded video loads
    // - Parameter precache: If precache is YES it means that precached ad loaded
    func rewardedVideoDidLoadAdIsPrecache(_ precache: Bool) {
    }
    // Method called if rewarded video mediation failed
    func rewardedVideoDidFailToLoadAd() {
    }

    func rewardedVideoDidFailToPresentWithError(_ error: Error) {
    }

    func rewardedVideoDidPresent() {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        print("Opened reward based video ad.")
    }

    func rewardedVideoWillDismissAndWasFullyWatched(_ wasFullyWatched: Bool) {
    }
    func rewardedVideoDidFinish(_ rewardAmount: Float, name rewardName: String?) {
        if self.videoPlayer.playbackState == .paused {
            self.videoPlayer.playFromCurrentTime()
        }
        logAdViewOrClickFromFeed(clickAd: 0)
    }
    func rewardedVideoDidClick() {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        logAdViewOrClickFromFeed(clickAd: 1)
    }
    func rewardedVideoDidExpired(){
        
    }
}

// Banner ad
extension PlayViewController: AppodealBannerDelegate
{
    // banner was loaded (precache flag shows if the loaded ad is precache)
    func bannerDidLoadAdIsPrecache(_ precache: Bool) {}
    // banner was shown
    func bannerDidShow() {}
    // banner failed to load
    func bannerDidFailToLoadAd() {}
    // banner was clicked
    func bannerDidClick() {}
    // banner did expire and could not be shown
    func bannerDidExpired() {}
}

extension PlayViewController: PlayerDelegate {
    func playerReady(_ player: Player) {
        print("\(#function) ready")
        
        let y = collectionView.contentOffset.y
        let h = collectionView.bounds.size.height
        let currentPage = Int(ceil(y/h))

        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? PostViewCell else {
            return
        }
        cell.imageView.isHidden = true
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function) error.description")
    }
}

extension PlayViewController: PlayerPlaybackDelegate {
    func playerCurrentTimeDidChange(_ player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
        
        let y = collectionView.contentOffset.y
        let h = collectionView.bounds.size.height
        let currentPage = Int(ceil(y/h))
        
        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? PostViewCell else {
            return
        }
        var playerItemIndex = 0
        if playerUrls.count != 0 {
            for itemIndex in 0...playerUrls.count - 1 {
               let playerItem = playerUrls[itemIndex]
               if playerItem == videoPlayer.url {
                   playerItemIndex = itemIndex
                   break
               }
           }
        }
        if let subCurrentProgressView = cell.progressContainer.arrangedSubviews[playerItemIndex] as? UIProgressView {
            subCurrentProgressView.progress = Float(fraction)
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        print("started")
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        if playerUrls.count < 2 {
            self.videoPlayer.playFromBeginning()
            return
        }else {
            for itemIndex in 0...playerUrls.count - 1 {
                let playItem = playerUrls[itemIndex]
                if playItem == self.videoPlayer.url {
                    if itemIndex == playerUrls.count - 1 {
                        
                        return
                    } else {
                        let nextPlayItem = playerUrls[itemIndex + 1]
                        let y = collectionView.contentOffset.y
                        let h = collectionView.bounds.size.height
                        let currentPage = Int(ceil(y/h))
                        guard let cell = collectionView.cellForItem(at: IndexPath(row: currentPage, section: 0)) as? PostViewCell else {
                            return
                        }
                        
                        for progressViewIndex in 0...playerUrls.count - 1 {
                            if let subProgressView = cell.progressContainer.arrangedSubviews[progressViewIndex] as? UIProgressView {
                                
                                if itemIndex == playerUrls.count - 1 {
                                    subProgressView.progress = 0.0
                                } else {
                                    if progressViewIndex <= itemIndex {
                                        subProgressView.progress = 1.0
                                    } else {
                                        subProgressView.progress = 0.0
                                    }
                                }
                            }
                        }
                        self.videoPlayer.url = nextPlayItem
                        self.videoPlayer.playFromBeginning()
                    }
                }
                break
            }
        }
    }
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    func playerPlaybackDidLoop(_ player: Player) {
        
    }
}

extension Notification.Name {
    static let goToHomeFromPlayViewEnable = Notification.Name("GoToHomeFromPlayViewEnable")
    static let goToHomeFromPlayViewDisable = Notification.Name("GoToHomeFromPlayViewDisable")
}
//---------- getting feeds according to the tabs
extension PlayViewController{
    
    func getAllViralData(){
        self.medias.removeAll()
        self.viralPosts.removeAll()
        self.viralPageId = 0
        self.viralDataCounts = 0
        getViralData(viralPageId)
        
    }
    @objc func getViralData(_ page: Int){
        
        Utils.showSpinner()
        DataBaseManager.shared.getViralFeed(pageId: self.viralPageId) { (result, error) in
           Utils.hideSpinner()
           if error != "" {
               self.medias.removeAll()
               self.collectionView.reloadData()
           }else{
               guard let viralFeedDatas : [Media] = result else { return }
               self.viralDataCounts = viralFeedDatas.count
               self.viralPageId += 1
                   for feed in viralFeedDatas {
                        var bAdded: Bool = false
                        for existingPost in self.viralPosts {
                            if feed.id == existingPost.id {
                                bAdded = true
                                break
                            }
                        }
                        if !bAdded {
                            self.viralPosts.append(feed)
                        }
                   }
               self.medias = self.viralPosts
               self.collectionView.reloadData()
               
            if self.medias.count > 0 {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                self.openBannerAd()
             }else{
                 print("exit")
             }
           }
        }
    }
    
    func getAllFeedData(){
        self.medias.removeAll()
        self.feedPosts.removeAll()
        self.feedPageId = 0
        self.feedDataCounts = 0

        getFeedData(feedPageId)
           
       //-- Show time bar
//       self.tabFeedTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getFeedData), userInfo: nil, repeats: true)
        //--End time bar
           
    }
    @objc func getFeedData(_ page: Int){
        
//        Utils.showSpinner()
        DataBaseManager.shared.getFeedData(pageId: feedPageId){(result, error) in
           Utils.hideSpinner()
           if error != "" {
                print(error)
                self.tabFeedTimer?.invalidate()
                self.tabFeedTimer = nil
                self.medias.removeAll()
                self.collectionView.reloadData()
           }else{
            guard let followingFeedData: [Media] = result else { return }
               self.feedDataCounts = followingFeedData.count
               self.feedPageId += 1
                   for feed in followingFeedData {
                        var bAdded: Bool = false
                        for existingPost in self.feedPosts {
                            if feed.id == existingPost.id {
                                bAdded = true
                                break
                            }
                        }
                        if !bAdded {
                            self.feedPosts.append(feed)
                        }
                    }
                    self.medias = self.feedPosts
                    self.collectionView.reloadData()
                    if self.medias.count > 0 {
                       self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                       self.openBannerAd()
                    }else{
                        print("exit")
                    }
               if self.tabFeedTimer != nil{
                   if self.feedDataCounts < self.pageLimit {
                       self.tabFeedTimer?.invalidate()
                       self.tabFeedTimer = nil
                   }
               }
           }
       }
   }
    
    func getAllTagData(){
        self.medias.removeAll()
        self.tagPosts.removeAll()
        self.tagPageId = 0
        self.tagDataCounts = 0

        getTagData(tagPageId)
        //-- Show time bar
//        self.tabTagTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(getTagData), userInfo: nil, repeats: true)
        //--End time bar
            
     }
     @objc func getTagData(_ page: Int){
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        DataBaseManager.shared.getTagData(pageId: tagPageId){(result, error) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                if error != "" {
                    print(error)
                    self.tabTagTimer?.invalidate()
                    self.tabTagTimer = nil
                    self.medias.removeAll()
                    self.collectionView.reloadData()
                }else{
                    guard let tagFeedData : [Media] = result else { return }
                    self.tagDataCounts = tagFeedData.count
                    self.feedPageId += 1
                        for feed in tagFeedData {
                             var bAdded: Bool = false
                             for existingPost in self.tagPosts {
                                 if feed.id == existingPost.id {
                                     bAdded = true
                                     break
                                 }
                             }
                             if !bAdded {
                                 self.tagPosts.append(feed)
                             }
                        }
                    self.medias = self.tagPosts
                    self.collectionView.reloadData()
                    if self.medias.count > 0 {
                       self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
                       self.openBannerAd()
                    }else{
                        print("exit")
                    }
                    if self.tabTagTimer != nil{
                        if self.tagDataCounts < self.pageLimit {
                            self.tabTagTimer?.invalidate()
                            self.tabTagTimer = nil
                        }
                    }
                }
            }
        }
    }
}

extension PlayViewController: UIViewControllerTransitioningDelegate{
    // MARK: - Animation
       func animationController(
           forDismissed dismissed: UIViewController)
           -> UIViewControllerAnimatedTransitioning? {
               return VerticalDismissAnimator()
       }
       
       func interactionControllerForDismissal(
           using animator: UIViewControllerAnimatedTransitioning)
           -> UIViewControllerInteractiveTransitioning? {
               return interactor.hasStarted
                   ? interactor
                   : nil
       }

}

