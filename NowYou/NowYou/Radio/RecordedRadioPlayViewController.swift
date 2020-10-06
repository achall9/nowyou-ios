//
//  RecordedRadioPlayViewController.swift
//  NowYou
//
//  Created by 111 on 2/8/20.
//  Copyright © 2020 Apple. All rights reserved.
//
import UIKit
import Firebase
import AVFoundation
import IQKeyboardManagerSwift
import FBAudienceNetwork
//import GoogleMobileAds
//import Appodeal
public protocol RecordedRaidoFollowDelegate: AnyObject {
    func increaseFollowing();
    func decreaseFollowing();
}
class RecordedRadioPlayViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var viewVideoContainer: UIView!
    @IBOutlet weak var vLogo: UIView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var playBtnView: UIView!
    
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var imgFollowTick: UIImageView!
    @IBOutlet weak var followBtnView: UIView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblRadioName: UILabel!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var emptyCommentsView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRecorderName: UILabel!
    var comments = [RadioComment]()
//----comment
    open weak var recordedRadioFollowDelegate: RecordedRaidoFollowDelegate?
//    var radio: Radio!
    var radio : RadioStation!
    var isPlaying: Bool = false
    
    var player: AVPlayer?
    
    var decodeAudioProcessor: AudioPlay?
    
    var radioRef: DatabaseReference!
    
    var isKeyboardOn: Bool = false
    
    var interactor = Interactor()
    var transition = CATransition()
    
    var adRequestInProgress = false
    
    var adTimer: Timer!
    var adTimer_banner: Timer!
    
    var timeFromAdFired: Int = 0
    var randomDuration: Int = 0
    
    var timeFromAdFired_banner: Int = 0
    var randomDuration_banner: Int = 0

    var searchUser: SearchUser!
    
    var parentId: String = ""
    var parentName: String = ""
    
    var selectedCell: MessageTableViewCell!
    var selectedComment: Comment!
    
    var isLike : Bool = false
    var isDelete : Bool = false
    var isCommentInComment : Bool = false
    let identifier1 = "messageCell"
    let identifier2 = "replyCell"
    var bannerAd: FBAdView!
    var lblBannerReview: UILabel!
    var failedOfBanner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPosterDetails(radio.user_id)
        initValue()
        initUI()

        updateDeletedComment()
        updateComment()
        loadComments()
        addRigthSwipe()
        initBannerAds()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverNotification()
          randomDuration = Int.random(in: 3..<5)
          randomDuration_banner = Int.random(in: 2..<3)
            if isPlaying {
            player?.play()
            decodeAudioProcessor?.start()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.pause()
        
        decodeAudioProcessor?.stop()
        
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnProfile.setCircular()
        imgProfile.setCircular()
        btnSend.setCircular()
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
        self.bannerAd = FBAdView.init(placementID: FBADS.BANNER_PLACEMENT_ID, adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        self.bannerAd.frame = CGRect.init(x: 0, y: self.viewVideoContainer.frame.size.height - 50, width: self.viewVideoContainer.frame.size.width, height: 50)
        self.bannerAd.delegate = self
       
        
        self.lblBannerReview = UILabel.init(frame: CGRect.init(x: 0, y: self.viewVideoContainer.frame.size.height - 50, width: self.viewVideoContainer.frame.size.width, height: 50))
        self.lblBannerReview.text = "Reviewing ads by Facebook team"
        self.lblBannerReview.textAlignment = .center
        self.lblBannerReview.backgroundColor = .white
        self.perform(#selector(showAds), with: self, afterDelay: 120)
    }
    @objc func showAds(){
            self.bannerAd.loadAd()
            self.perform(#selector(hideAds), with: self, afterDelay: 180)
    }
    @objc func hideAds(){
            self.bannerAd.removeFromSuperview()
            self.lblBannerReview.removeFromSuperview()
    }
    
    private func initValue(){
        adTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(showAd), userInfo: nil, repeats: true)
        adTimer_banner = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(showAd_banner), userInfo: nil, repeats: true)
        //Appodeal.setInterstitialDelegate(self)
        //Appodeal.setRewardedVideoDelegate(self)
        IQKeyboardManager.shared.enable = false
        
        // log view count
        DataBaseManager.shared.logRadioView(radioID: radio.id) { (error) in
            print("")
        }
        joinRadioStation()
    }
    func initUI() {
        
        if let radioPath = radio.audios.path {
            print(radioPath)
            // play recorded stream
            initPlayer(path: radioPath)
        } else {
                decodeAudioProcessor = AudioPlay()
                decodeAudioProcessor?.radioId = radio.audios.id
                decodeAudioProcessor?.start()
                
                imgPlay.image = PAUSE_IMG
                lblPlay.text = "Pause"
                isPlaying = true
        }
        
        lblTitle.text = radio.name
        
        btnProfile.layer.borderWidth = 1
        btnProfile.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        
        
        vLogo.layer.borderColor = UIColor(hexValue: 0x744AF2).cgColor
        vLogo.layer.borderWidth = 3
        
        
        playBtnView.layer.borderColor = UIColor(hexValue: 0x60DF76).cgColor
        playBtnView.layer.borderWidth = 1
        playBtnView.setRoundCorner(radius: 6)
        
        followBtnView.setRoundCorner(radius: 6)
        
        vLogo.layer.borderColor = UIColor(hexValue: 0x744AF2).cgColor
        vLogo.layer.borderWidth = 3
        
        textView.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = textView.frame.height / 2
        textView.clipsToBounds = true
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        textView.font = UIFont.systemFont(ofSize: 17)
        
        imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: UserManager.currentUser()?.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .highPriority, completed: nil)

        self.lblViewCount.text = "0"
        lblRadioName.text = radio.name
        

    }
    private func addObserverNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
//       if (sender.direction == .right) {
//            player?.pause()
//            decodeAudioProcessor?.stop()
//            
//            if adTimer != nil {
//                adTimer.invalidate()
//                
//                adTimer = nil
//            }
//            
//            player?.currentItem?.cancelPendingSeeks()
//            player?.replaceCurrentItem(with: nil)
//            navigationController?.popViewController(animated: true)
//            print("Swipe right")
//       }
    }

    @objc func showAd_banner() {
        self.timeFromAdFired_banner += 1
        print("timeFromAdFired_banner = \(self.timeFromAdFired_banner), random = \(randomDuration_banner)")
        /*
        if self.timeFromAdFired_banner > randomDuration_banner {
           if Appodeal.isReadyForShow(with: .bannerBottom){
                Appodeal.banner()?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height * 0.3 + 20 )
                Appodeal.showAd(AppodealShowStyle.bannerBottom, rootViewController: self)
               self.timeFromAdFired_banner = 0
               randomDuration_banner = Int.random(in: 2..<3)
           }
        } else {
            Appodeal.hideBanner()
        }
         */
    }
    @objc func showAd() {
        self.timeFromAdFired += 1
        print("timeFromAdFired = \(self.timeFromAdFired), random = \(randomDuration)")
        if self.timeFromAdFired > randomDuration {
            // show ad
            /*
            if Appodeal.isReadyForShow(with: .rewardedVideo){
               Appodeal.showAd(AppodealShowStyle.rewardedVideo, rootViewController: self)
                if adTimer != nil {
                   adTimer.invalidate()
                   adTimer = nil
                }
               self.timeFromAdFired = 0
               randomDuration = Int.random(in: 3..<5)
            }else{
                print ("rewarded ad is not ready") // show interstitial ad video instead if possible
               Appodeal.showAd(AppodealShowStyle.interstitial, rootViewController: self)
               if adTimer != nil {
                   adTimer.invalidate()
                   adTimer = nil
               }
               self.timeFromAdFired = 0
               randomDuration = Int.random(in: 3..<5)
            }
             */
        }
    }
    
    // MARK: - Notifications
    @objc func keyboardWasShown(notification: Notification) {
        
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            CGRect {
            if isKeyboardOn {
                return
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y -= keyboardSize.height
                
                self.isKeyboardOn = true
                DispatchQueue.main.async {
                    if self.comments.count > 0 {
                        self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.isKeyboardOn = false
            
            DispatchQueue.main.async {
                if self.comments.count > 0 {
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    func initPlayer(path: String) {
        let playerItem = AVPlayerItem(url: URL(string: path)!)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

        
        player?.volume = 10.0
        player?.play()

        imgPlay.image = PAUSE_IMG
        lblPlay.text = "Pause"
        isPlaying = true
        requestListen(radio_station_id : radio.id)
    }
        
    @objc func loadViewCounts(){
        DataBaseManager.shared.getRadioViews(radioID: radio.id) { (viewers, error) in
            self.lblViewCount.text = "\(viewers)"
        }
    }
    
    func joinRadioStation(){
        guard let currentUser = UserManager.currentUser() else {
            return
        }
        radioRef = Database.database().reference().child("Radio").child("\(radio.id)").child("RadioListener")
        let param: NSDictionary = [
                   "userID":currentUser.userID ?? -1
               ]
        radioRef.child("\(currentUser.userID ?? -1)").setValue(param)
        radioRef.observe(.childAdded, with: { (snapshot) in
            self.loadViewCounts()
        })
    }
        
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
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
    func followBtnPressed() {
        let user = UserManager.currentUser()!
        if searchUser == nil {return}
        if searchUser.isFollowing {
            NetworkManager.shared.unfollow(userId: (searchUser.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    DispatchQueue.main.async {
                        self.searchUser.isFollowing = false
                        self.lblFollow.text = "Follow"
                        self.imgFollowTick.isHidden = true
                        user.followings_count = user.followings_count - 1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_FOLLOWING_COUNT_UPDATED),object: nil, userInfo: nil)
                    }
                }
            }
        } else {
            NetworkManager.shared.follow(userId: (searchUser.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    DispatchQueue.main.async {
                        self.searchUser.isFollowing = true
                        self.lblFollow.text = "Followed"
                        self.imgFollowTick.isHidden = false
                        user.followings_count = user.followings_count + 1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_FOLLOWING_COUNT_UPDATED),object: nil, userInfo: nil)
                    }
                   
                }
            }
        }
    }
    func getPosterDetails(_ userId: Int){
         print("other profile")
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        NetworkManager.shared.getUserDetails(userId: radio.user_id) { (response) in
            
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            
            switch response {
            case .error(let error):
                DispatchQueue.main.async {
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                }
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
                            DispatchQueue.main.async {
                                self.searchUser = SearchUser(searchUser: user, following: isFollowing, posts: posts)
                                self.lblRecorderName.text = user.fullname
                                let recorderImg = UIImageView()
                                recorderImg.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .highPriority, completed: nil)
                                self.btnProfile.setImage(recorderImg.image, for: .normal)
                                if isFollowing {
                                    self.lblFollow.text = "Followed"
                                    self.imgFollowTick.isHidden = false
                                } else {
                                    self.lblFollow.text = "Follow"
                                    self.imgFollowTick.isHidden = true
                                }
                            }
                        }
                    }
                } catch {
                }
            }
        }
    }
    
    @IBAction func onFollow(_ sender: Any) {
        followBtnPressed()
    }
    @IBAction func onPlay(_ sender: Any?) {
        isPlaying = !isPlaying
        if isPlaying {
            imgPlay.image = PAUSE_IMG
            lblPlay.text = "Pause"
            player?.play()
            requestListen(radio_station_id : radio.id)
            decodeAudioProcessor?.start()
        } else {
            imgPlay.image = PLAY_IMG
            lblPlay.text = "Play"
            player?.pause()
            rejecttListen(radio_station_id: radio.id)
            decodeAudioProcessor?.stop()
        }
    }
    
    @IBAction func onProfile(_ sender: Any) {
       let profile = UIViewController.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
       profile.user = searchUser
        profile.blockerTap = false
       profile.transitioningDelegate = self
       profile.interactor = self.interactor
       self.transition(to: profile)
    }
    
    //Action
    @objc func tapProfile(gesture: UITapGestureRecognizer) {
        
        let index = gesture.view!.tag
        let userId = comments[index].userId
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        NetworkManager.shared.getUserDetails(userId: userId) { (response) in
            
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            
            switch response {
            case .error(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(jsonRes)
                    
                    if let json = jsonRes as? [String: Any] {
                        let isFollowing = json["is_following"] as? Bool ?? false
                        if let userJson = json["user"] as? [String: Any] {
                            let user = User(json: userJson)
                            
                            var posts = [Media]()
                            if let postsJson = userJson["posts"] as? [[String: Any]] {
                                for post in postsJson {
                                    posts.append(Media(json: post))
                                }
                            }
                            
                            let searchUser = SearchUser(searchUser: user, following: isFollowing, posts: posts)
                            
                            let profile = UIViewController.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
                            profile.user = searchUser
                            profile.blockerTap = false
                            DispatchQueue.main.async {
                                profile.transitioningDelegate = self
                                profile.interactor = self.interactor
                                
                                self.transition(to: profile)
                            }
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
        
    @IBAction func onBack(_ sender: Any) {
        player?.pause()
        decodeAudioProcessor?.stop()
        
        if adTimer != nil {
            adTimer.invalidate()
            
            adTimer = nil
        }
        
        if adTimer_banner != nil {
            adTimer_banner.invalidate()
            adTimer_banner = nil
        }
        player?.currentItem?.cancelPendingSeeks()
        player?.replaceCurrentItem(with: nil)

        navigationController?.popViewController(animated: true)
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        // Your code here
        imgPlay.image = PLAY_IMG
        lblPlay.text = "Play"
        isPlaying = false
        
        player?.seek(to: CMTime.zero)
    }
    
    func requestListen(radio_station_id : Int) {

        NetworkManager.shared.requestListen(radio_Station_id: radio_station_id) { (response) in
        DispatchQueue.main.async {
            switch response{
            case .error(let error):
                print(error.localizedDescription)
                return
            case .success(let success):
                   print(success, "please listen")
            }

            }
           
        }
    }
    func rejecttListen(radio_station_id : Int) {

        NetworkManager.shared.rejectListen(radio_Station_id: radio_station_id) { (response) in
            DispatchQueue.main.async {
                switch response{
                case .error(let error):
                        print(error.localizedDescription)
                        return
                case .success(let success):
                       print(success, "Rejected")
            }

            }
        }
    }
    
    func logAdViewOrClickFromRadio(clickAd: Int) {
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.logAdView(postId: radio.id, type: 1, clickAd: clickAd) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            switch response {
               case .error(let error):
                   print (error.localizedDescription)
                   break
               case .success(let data):
                   print("Sent logAdView infor successfully")
                   do {
                       let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                   } catch {
                       
                   }
                   break
               }
            }
            self.adTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.showAd), userInfo: nil, repeats: true)
        }
    }
    
    func logAdClickFromRadio() {}
//-------Comment

    @IBAction func onPostComment(_ sender: Any) {
        // post data
        guard let text = textView.text else {
            return
        }
        guard text.count > 0 else {
            return
        }
        sendComment()
    }
    
    @IBAction func onLike(_ sender: UIButton) {
        isLike = true
        let index = sender.tag - 1000
        if comments.count > 0
        {
            let comment = comments[index]
            onShowCommentThread(comment)
        }
    }
    @IBAction func onCommentInComment(_ sender: UIButton) {
        isCommentInComment = true
        textView.text = ""
        let index = sender.tag - 2000
        if comments.count > 0
        {
           let comment = comments[index]
           textView.text = "@\(comment.username) "
           onShowCommentThread(comment)

        }
    }
    @IBAction func onDelete(_ sender: UIButton) {
        isDelete = true
        let index = sender.tag - 3000
        if comments.count > 0
        {
            let comment = comments[index]
            if comment.userId == UserManager.currentUser()?.userID {
                onShowCommentThread(comment)
            }
        }
    }
}

extension RecordedRadioPlayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let comment = comments[indexPath.row]
      let cellId =  comment.parentId == "" ? identifier1 : identifier2
      let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageTableViewCell
      cell.avatarImg.tag = indexPath.row
      cell.senderLbl.text = comment.username
      if comment.parentName == "" {
          cell.msgLbl.text = comment.comment
      }else{
          cell.msgLbl.text = comment.comment
      }
      
      cell.likeCountLbl.text = "\(comment.likeCount)" + " likes"
      print (Utils.getFullPath(path: comment.photo))
      cell.avatarImg.sd_setImage(with: URL(string: Utils.getFullPath(path: comment.photo)), placeholderImage: PLACEHOLDER_IMG, options: .refreshCached, completed: nil)

      cell.timeLbl.text = comment.created_at.timeAgo()
      cell.likeBtn.tag = 1000 + indexPath.row
      cell.commentBtn.tag = 2000 + indexPath.row
      if comment.userId == UserManager.currentUser()?.userID {
          cell.deleteBtn.tag = 3000 + indexPath.row
          cell.deleteBtn.alpha = 1.0
      }else{
          cell.deleteBtn.alpha = 0.0
      }
      // -----comment thread
      if comment.like == 1 {
          cell.likeBtn.setImage(UIImage(named: "NY_post_like"), for: .normal)
      }else{
          cell.likeBtn.setImage(UIImage(named: "NY_post_dislike"), for: .normal)
      }
      return cell
    }
    //------Comment Thread
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

/*
extension RecordedRadioPlayViewController: AppodealInterstitialDelegate {
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
        onPlay(nil)
    }

    // Method called after interstitial leave screeen
    func interstitialDidDismiss() {
        print("ad dismissed")
        onPlay(nil)
        logAdViewOrClickFromRadio(clickAd: 0)
    }

    // Method called when user tap on interstitial
    func interstitialDidClick() {
        onPlay(nil)
        logAdViewOrClickFromRadio(clickAd: 1)
        print("interstitialWillLeaveApplication")
    }
    
    // Method called when interstitial did expire and could not be shown
    func interstitialDidExpired(){
        
    }
}

extension RecordedRadioPlayViewController: AppodealRewardedVideoDelegate {
    // Method called when rewarded video loads
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
        onPlay(nil)
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
        onPlay(nil)
        logAdViewOrClickFromRadio(clickAd: 0)
    }

    // Method is called when rewarded video is clicked
    func rewardedVideoDidClick() {
        onPlay(nil)
        logAdViewOrClickFromRadio(clickAd: 1)
    }

    // Method called when rewardedVideo did expire and can not be shown
    func rewardedVideoDidExpired(){
        
    }
}

// Banner ad
extension RecordedRadioPlayViewController: AppodealBannerDelegate
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
//------Comment Thread
extension RecordedRadioPlayViewController{
    func onShowCommentThread( _ comment: RadioComment) {
        // show picker
        if isLike == true {
            if comment.like == 1 {
                self.sendUnlikeComment( comment)
            }else{
                self.sendLikeComment( comment)
            }
            self.isLike = false
        } else if isCommentInComment == true {
            self.sendCommentInComment( comment)
            self.isCommentInComment = false
        } else if isDelete == true {
            self.sendDeleteComment( comment)
            self.isDelete = false
        }
    }
    
    func sendLikeComment( _ comment : RadioComment){
        radioRef.child("\(comment.commentId)").updateChildValues(["like":1, "likeCount": comment.likeCount + 1])
    }
    func sendUnlikeComment( _ comment : RadioComment){
        radioRef.child("\(comment.commentId)").updateChildValues(["like":0, "likeCount": comment.likeCount - 1])
    }
    func sendCommentInComment( _ comment : RadioComment){
        textView.becomeFirstResponder()
        parentId = comment.commentId
        parentName = comment.username
    }
    func sendDeleteComment( _ comment : RadioComment){
        radioRef.child("\(comment.commentId)").removeValue()
        for commentMember in self.comments {
            if commentMember.parentId == comment.commentId {
                sendDeleteComment(commentMember)
            }
        }
    }
    func sendComment(){
        let user = UserManager.currentUser()!
        let data : [String: Any] = ["comment": textView.text ?? "", "username": user.username ?? "", "photo": user.userPhoto!, "timestamp": Date().timeIntervalSince1970, "userId": user.userID ?? "", "parentId": parentId, "parentName": parentName, "like": 0, "likeCount": 0]
        radioRef.childByAutoId().setValue(data)
        textView.text = ""
        parentId = ""
        parentName = ""
    }
               
    private func loadComments(){
        // load comments
        comments.removeAll()
        radioRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        if let index = self.comments.firstIndex(where: {$0.commentId == comment.parentId}) {
                            self.comments.insert(comment, at: index + 1)
                        }else{
                            self.comments.append(comment)
                        }
                    }
                }
                if self.comments.count == 0 {
                    self.emptyCommentsView.isHidden = false
                    self.tblComments.reloadData()
                } else {
                    self.emptyCommentsView.isHidden = true
                    
                    self.tblComments.beginUpdates()
                    self.tblComments.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: .automatic)
                    self.tblComments.endUpdates()
                    
                    // scroll to bottom
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.emptyCommentsView.isHidden = false
            }
        })
    }
    
    private func updateComment(){
        // load comments
        self.radioRef.observe(.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        if let index = self.comments.firstIndex(where: {$0.commentId == key}) {
                            self.comments[index].like = comment.like
                            self.comments[index].likeCount = comment.likeCount
                        }
                    }
                }
                if self.comments.count == 0 {
                    self.emptyCommentsView.isHidden = false
                    self.tblComments.reloadData()
                } else {
                    self.emptyCommentsView.isHidden = true
                    self.tblComments.reloadData()
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.emptyCommentsView.isHidden = false
            }
        })
    }
    
    private func updateDeletedComment(){
        // load comments
        self.comments.removeAll()
        radioRef.observe(.childRemoved, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        if let index = self.comments.firstIndex(where: {$0.commentId == key})
                        {
                            self.comments.remove(at: index)
                        }
                    }
                }
                if self.comments.count == 0 {
                    self.emptyCommentsView.isHidden = false
                    self.tblComments.reloadData()
                } else {
                    self.emptyCommentsView.isHidden = true
                    self.tblComments.reloadData()
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.emptyCommentsView.isHidden = false
            }
        })
    }
}
extension RecordedRadioPlayViewController: FBAdViewDelegate {
    
    func adViewDidClick(_ adView: FBAdView) {
        print("banner ads click")
//        logAdViewOrClickFromFeed(clickAd: 1)
    }
    
    func adViewDidFinishHandlingClick(_ adView: FBAdView) {
        print("adViewDidFinishHandlingClick")
    }
    
    func adViewWillLogImpression(_ adView: FBAdView) {
        print("adViewWillLogImpression")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        self.lblBannerReview.frame = CGRect.init(x: 0, y: self.viewVideoContainer.frame.size.height - 50, width: self.viewVideoContainer.frame.size.width, height: 50)
        self.viewVideoContainer.addSubview(self.lblBannerReview)
        self.lblBannerReview.isHidden = false
        self.failedOfBanner = true
        print("banner ads loading failed")
    }
    
    func adViewDidLoad(_ adView: FBAdView) {
        self.lblBannerReview.isHidden = true
        self.showBanner()
    }
    
    func showBanner() {
        self.bannerAd.frame = CGRect.init(x: 0, y: self.viewVideoContainer.frame.size.height - 50, width: self.viewVideoContainer.frame.size.width, height: 50)
        self.viewVideoContainer.addSubview(self.bannerAd)
    }
    
}
