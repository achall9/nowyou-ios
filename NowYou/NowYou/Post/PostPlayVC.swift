//
//  PostPlayVC.swift
//  NowYou
//
//  Created by 111 on 6/2/20.
//  Copyright © 2020 Apple. All rights reserved.
//


import UIKit
import AVFoundation
import AnimatedCollectionViewLayout
//import Appodeal
import Player
import CRRefresh
import SwiftyJSON


import FBAudienceNetwork



class PostPlayVC: EmbeddedViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var dismissGesture: UISwipeGestureRecognizer!
    
    
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
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    var isFirstLoad: Bool = true
    var isPaged: Bool = false
    
    /// The interstitial ad.
    //var interstitial: GADInterstitial!
    /// The reward-based video ad.
    //var rewardBasedVideo: GADRewardBasedVideoAd?
        
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
    
    var longPress = false
    
    var original_user_id : Int? = 0
    var sharer_id : Int? = 0
   
    var bannerAd: FBAdView!
    var lblBannerReview: UILabel!
    
    
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
        initBannerAds()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reportedPost(notification:)),
        name: .reportedPostSuccessfully, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIApplication.shared.isStatusBarHidden = true

        initValue()
        //openBannerAd()

       NotificationCenter.default.addObserver(self, selector: #selector(reportedPost(notification:)),
           name: .reportedPostSuccessfully, object: nil)
        if self.videoPlayer.playbackState == .paused {
           self.videoPlayer.playFromCurrentTime()
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? audioSession.setCategory(.ambient, options: .mixWithOthers)
        try? audioSession.setActive(true)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    func initBannerAds() {
        /*
        self.adView = [[FBAdView alloc] initWithPlacementID:@"YOUR_PLACEMENT_ID"
                                                     adSize:kFBAdSizeHeight250Rectangle
                                         rootViewController:self];
        self.adView.frame = CGRectMake(0, 0, 320, 250);
        self.adView.delegate = self;
        [self.adView loadAd];
         */
        let height = self.tabBarController?.tabBar.frame.height ?? 49.0
        self.bannerAd = FBAdView.init(placementID: FBADS.BANNER_PLACEMENT_ID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        self.bannerAd.frame = CGRect.init(x: 0, y: self.view.bounds.height - height - 50 - UIManager.bottomPadding(), width: self.view.bounds.width, height: 50)
        self.bannerAd.delegate = self
        self.bannerAd.loadAd()
        
        self.lblBannerReview = UILabel.init(frame: CGRect.init(x: 0, y: self.view.bounds.height - height - 50 - UIManager.bottomPadding(), width: self.view.bounds.width, height: 50))
        self.lblBannerReview.text = "Reviewing ads by Facebook team"
        self.lblBannerReview.textAlignment = .center
        self.lblBannerReview.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments1" {
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
        if viewFromFeed || viewFromProfile{
            print ("scroll to index \(currentIndex)")
            viewFromFeed = false
            
            viewFromProfile = false
            if medias.count > 0, currentIndex < medias.count {
                collectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredVertically, animated: false)
            }else{
                transitionDismissal()
            }
            playerUrls.removeAll()
            let media = medias[currentIndex]
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
                playVideoItems(currentCellIndex: currentIndex)
            }
            //openBannerAd()

        }        
    }

    private func initValue(){
        //Appodeal.setInterstitialDelegate(self)
        //Appodeal.setRewardedVideoDelegate(self)
        //Appodeal.setBannerDelegate(self)
        mEndPageSelected = false
        mIndexpathRow = 0
        
    }
    
    private func initCollectionView(){
        collectionView?.isPagingEnabled = true
        if let layout = collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
            layout.scrollDirection = direction
//            layout.animator = animator.0
        }
        
    }

    
    @objc func reportedPost(notification: Notification){
        if medias.count > 0, mIndexpathRow < medias.count {
            medias.remove(at: mIndexpathRow)
            currentIndex = mIndexpathRow
            collectionView.reloadData()
        }else{
            transitionDismissal()
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
        let pointInCollectionView: CGPoint = gesture.location(in: self.collectionView)
        
        let selectedIndexPath: IndexPath = collectionView.indexPathForItem(at: pointInCollectionView)!
        
        if gesture.state == .began {
            if self.videoPlayer.playbackState == .playing {
                longPress = true
                self.videoPlayer.pause()
            }
        } else if gesture.state == .ended {
            if self.videoPlayer.playbackState == .paused {
                longPress = false
                self.videoPlayer.playFromCurrentTime()
            }
        }
    }
    
    @objc func didSingleTapCollectionView(gesture: UITapGestureRecognizer) {
        
    }
    
    /*
    private func openBannerAd(){
        if Appodeal.isReadyForShow(with: .bannerBottom){
           Appodeal.hideBanner()
           Appodeal.banner()?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50 )
           Appodeal.showAd(AppodealShowStyle.bannerBottom, rootViewController: self)
        }else if  Appodeal.isReadyForShow(with: .bannerTop) {
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
    */
    
    @IBAction func actionSharePost(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Share", message: "Do you want to continue?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            
            print("clicked share button")
            let media = self.medias[self.currentIndex]
            
             
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
                                     //self.getAllViralData()
                                 } else {
                                     self.present(Alert.alertWithTextInfo(errorText: "Please try again!"), animated: true, completion: nil)
                                     return
                                 }
                                 
                             } catch {}
                     }
                     
                 }
             }
            
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func onReport(_ sender: Any){
        let reportVC = ReportVC(nibName: String(describing: ReportVC.self), bundle: nil)
        reportVC.postId = medias[mIndexpathRow].id
        present(reportVC, animated: false)
    }
    @IBAction func didSwipeUp(_ sender: Any) {
//        print ("to comments")
//        performSegue(withIdentifier: "toComments", sender: nil)
    }
    

    @objc func onMute(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        self.videoPlayer.muted = !self.videoPlayer.muted
    }
    
    @IBAction func onClose(_ sender: Any) {
        transitionDismissal()
    }
    
    @objc func onComments(sender: UIButton) {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        performSegue(withIdentifier: "toComments1", sender: nil)
    }
    
    
    @IBAction func gotoSharerProfile(_ sender: UIButton) {
        
        print("other profile")
        //guard let userID = medias[mIndexpathRow].userId else { return }
        guard let userID = self.sharer_id else { return }
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
                               profile.interactor = self.interactor!
                               if searchUser.user?.userID == UserManager.currentUser()?.userID {
                                    profile.isSelf = true
                               } else {
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
    
    @IBAction func gotoProfile(_ sender: Any) {
        print("other profile")
        //guard let userID = medias[currentIndex].userId else{return}
        guard let userID = self.original_user_id else{return}
        timer?.invalidate()
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
                                    profile.interactor = self.interactor!
                                    self.transition(to: profile)
                            }
                        }
                    } catch {
                    }
                }//--end  switch response
            }//--end  DispatchQueue.main.async
        }//--end
    }
    // ------ tabs

    
    //-------- tabs end//
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

extension PostPlayVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row % 3 == 0 && indexPath.row != 0 {
            self.lblBannerReview.isHidden = true
            self.logAdViewOrClickFromFeed(clickAd: 0)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FacebookAdsCell", for: indexPath) as! FacebookAdsCell
            return cell
            
        } else {
            //------------------
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PostViewCell
            let media = medias[indexPath.row]
        
            //openBannerAd()

                 
            let selfID = UserManager.currentUser()?.userID

            cell.imgBottomConstraint.constant = 90.0
            cell.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 90.0)
            cell.containerView.layoutIfNeeded()

            // remove image
            cell.imageView.image = nil
            cell.btnLike.isSelected = false
            if media.liked {
                cell.btnLike.isSelected = true
            } else {
                cell.btnLike.isSelected = false
            }
            cell.lblViewsCount.text = "\(media.views)" + " Views"
        
        
        
            self.original_user_id = media.original_user_id  ?? 0
            self.sharer_id        = media.userId            ?? 0
        
        
        
        // Original poster
            if let original_user_id = media.original_user_id, original_user_id != media.userId {
                // load user info
                NetworkManager.shared.getUserDetails(userId: original_user_id) { (response) in
                    switch response {
                    case .error(let error):
                        DispatchQueue.main.async {
                            self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                        }
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let json = jsonRes as? [String: Any] {
                                if let userJson = json["user"] as? [String: Any] {
                                    let user = User(json: userJson)
                                    // set the user name
                                    DispatchQueue.main.async {
                                        
                                        let formatter = DateFormatter()
                                        formatter.timeZone = TimeZone.current
                                        formatter.dateFormat = "MMM dd, hh:mm a"
                                        cell.lblTimestamp.text = user.username!// + ", " + formatter.string(from: media.created)
                                        print(formatter.timeZone ?? "")
                                        cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                                        cell.imgProfile.setCircular()
                                        
                                        let media_username = media.username ?? ""
                                        cell.lblSharer.text = "Shared by: " + media_username
                                        cell.imgSharer.sd_setImage(with: URL(string: Utils.getFullPath(path: media.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                                        cell.imgSharer.setCircular()
                                    }
                                    
                                }
                            }
                        } catch {
                            
                        }
                    }
                }
                
            } else {
                // TimeStamp
                        let formatter = DateFormatter()
                        formatter.timeZone = TimeZone.current
                        formatter.dateFormat = "MMM dd, hh:mm a"
                        cell.lblTimestamp.text = media.username! + ", " + formatter.string(from: media.created)
                        print(formatter.timeZone ?? "")
                        cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: media.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                        cell.imgProfile.setCircular()
                //--End TimeStamp
            }
            
        

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
            
            } else {
                // add progress bar
          
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
                    }
                }
                
                cell.containerView.layoutIfNeeded()
                
//                if indexPath.row == currentIndex {
                    totalLengthOfPlayItems = 0.0
                    playerUrls.removeAll()
                    let media = medias[indexPath.row]
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
                    cell.containerView.insertSubview(self.videoPlayer.view, at: 0)
                    self.videoPlayer.playFromBeginning()
//                }
            }

            if Utils.isIPhoneX() {
                cell.closeBtnTopConstraint.constant = 30
            } else {
                cell.closeBtnTopConstraint.constant = 0
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
            return cell
        }
        //------------------
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        
        if mIndexpathRow == (medias.count - 1) {
            if mEndPageSelected == false{
                mEndPageSelected = true
            }else{
                self.transitionDismissal()
            }
        }
        self.photoShowTime = 0.0
        self.timer?.invalidate()
        self.timer = nil
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
      
        // Do whatever with currentPage.
        if(!longPress){
            
            let y = scrollView.contentOffset.y
            let h = scrollView.bounds.size.height
            let currentPage = Int(ceil(y/h))
            
            //openBannerAd()
            //openAd(currentPage)
            print ("current page = \(currentPage)")
            if currentPage >= medias.count {
                return
            }

            isPaged = true

            NotificationCenter.default.removeObserver(self)

            playerUrls.removeAll()

            totalLengthOfPlayItems = 0.0

            if self.videoPlayer.view.superview != nil {
                self.videoPlayer.view.removeFromSuperview()
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
                     
                playVideoItems(currentCellIndex: currentPage)
                
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

         return CGSize(width: view.bounds.width , height: view.bounds.height)
//        return CGSize(width: view.bounds.width / CGFloat(animator.2), height: view.bounds.height / CGFloat(animator.3))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        collectionView.deselectItem(at: indexPath, animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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

/*
extension PostPlayVC: AppodealInterstitialDelegate {
    // Method called when precache (cheap and fast load) or usual interstitial view did load
    //
    // - Warning: If you want show only expensive ad, ignore this callback call with precache equal to YES
    // - Parameter precache: If precache is YES it's mean that precache loaded
    func interstitialDidLoadAdIsPrecache(_ precache: Bool) {
        
    }

    // Method called if interstitial mediation failed
    func interstitialDidFailToLoadAd() {
        
    }
    
    // Method called if interstitial mediation was success, but ready ad network can't show ad or
    // ad presentation was to frequently according your placement settings
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

extension PostPlayVC: AppodealRewardedVideoDelegate {
    // Method called when rewarded video loads
    //
    // - Parameter precache: If precache is YES it means that precached ad loaded
    func rewardedVideoDidLoadAdIsPrecache(_ precache: Bool) {
        
    }
    
    // Method called if rewarded video mediation failed
    func rewardedVideoDidFailToLoadAd() {
        
    }

    // Method called if rewarded mediation was successful, but ready ad network can't show ad or
    // ad presentation was too frequent according to your placement settings
    //
    // - Parameter error: Error object that indicates error reason
    func rewardedVideoDidFailToPresentWithError(_ error: Error) {
        
    }

    // Method called after rewarded video start displaying
    func rewardedVideoDidPresent() {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        print("Opened reward based video ad.")
    }
    
    // Method called before rewarded video leaves screen
    //
    // - Parameter wasFullyWatched: boolean flag indicated that user watch video fully
    func rewardedVideoWillDismissAndWasFullyWatched(_ wasFullyWatched: Bool) {
        
    }

    //  Method called after fully watch of video
    //
    // - Warning: After call this method rewarded video can stay on screen and show postbanner
    // - Parameters:
    //   - rewardAmount: Amount of app curency tuned via Appodeal Dashboard
    //   - rewardName: Name of app currency tuned via Appodeal Dashboard
    func rewardedVideoDidFinish(_ rewardAmount: Float, name rewardName: String?) {
        if self.videoPlayer.playbackState == .paused {
            self.videoPlayer.playFromCurrentTime()
        }
        logAdViewOrClickFromFeed(clickAd: 0)
    }

    // Method is called when rewarded video is clicked
    func rewardedVideoDidClick() {
        if self.videoPlayer.playbackState == .playing {
            self.videoPlayer.pause()
        }
        logAdViewOrClickFromFeed(clickAd: 1)
    }

    // Method called when rewardedVideo did expire and can not be shown
    func rewardedVideoDidExpired(){
        
    }
}

// Banner ad
extension PostPlayVC: AppodealBannerDelegate
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
 */

extension PostPlayVC: PlayerDelegate {
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

extension PostPlayVC: PlayerPlaybackDelegate {
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
        }else{
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




extension PostPlayVC: FBAdViewDelegate {
    
    func adViewDidClick(_ adView: FBAdView) {
        print("banner ads click")
        logAdViewOrClickFromFeed(clickAd: 1)
    }
    
    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
        print("adViewDidFinishHandlingClick")
    }
    
    func adViewWillLogImpression(_ adView: FBAdView) {
        print("adViewWillLogImpression")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        self.view.addSubview(self.lblBannerReview)
        self.lblBannerReview.isHidden = false
        print("banner ads loading failed")
    }
    
    func adViewDidLoad(_ adView: FBAdView) {
        self.lblBannerReview.isHidden = true
        self.showBanner()
    }
    
    func showBanner() {
        self.view.addSubview(self.bannerAd)
    }
    
}
