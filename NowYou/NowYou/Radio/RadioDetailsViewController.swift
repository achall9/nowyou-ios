//
//  RadioDetailsViewController.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import IQKeyboardManagerSwift
import AgoraRtcKit
import SoundWave

import FBAudienceNetwork

class RadioDetailsViewController: BaseViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var viewVideoContainer: UIView!
    @IBOutlet weak var btnBack: NSLayoutConstraint!
    @IBOutlet weak var vLogo: UIView!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var playBtnView: UIView!
    @IBOutlet weak var followBtnView: UIView!
    @IBOutlet weak var lblFollow: UILabel!
    @IBOutlet weak var imgFollowTick: UIImageView!
    
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
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    var bannerAd: FBAdView!
    var lblBannerReview: UILabel!
    var failedOfBanner: Bool = false

    var player: AVPlayer?
    var decodeAudioProcessor: AudioPlay?
    var comments = [RadioComment]()
    //----comment
    var tempComments = [RadioComment]()
    var radioRef: DatabaseReference?

    var radio : RadioStation!
    var isPlaying: Bool = true
    
    var isKeyboardOn: Bool = false
    var interactor = Interactor()
    var transition = CATransition()
    var searchUser: SearchUser!
    var clientRole = AgoraClientRole.audience {
        didSet {
//            updateBroadcastButton()
        }
    }
    
    fileprivate var agoraKit: AgoraRtcEngineKit!
    fileprivate var logs = [String]()
    
    
    fileprivate var audioMuted = false {
        didSet {
        }
    }
    
    fileprivate var speakerEnabled = true {
        didSet {
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = false
        getPosterDetails(radio.user_id)

        initUI()
        updateComment()
        updateDeletedComment()
        loadComments()
        loadAgoraKit()
        addRigthSwipe()
        joinRadioStation()
        initBannerAds()
        self.audioVisualizationView.audioVisualizationMode = .read
        self.audioVisualizationView.meteringLevels = [0.1, 0.67, 0.13, 0.78, 0.31]
        self.audioVisualizationView.play(for: 5.0)

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
        self.showAds()
    }
    @objc func showAds(){
         self.bannerAd.loadAd()
    }
    func setupVideo() {
            
            agoraKit.enableVideo()
            let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative)
    //        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative))
            agoraKit.setVideoEncoderConfiguration(configuration)
     
            
        }
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
       if (sender.direction == .right) {
            leaveChannel()
            navigationController?.popViewController(animated: true)
           print("Swipe right")
       }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        isPlaying = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnProfile.setCircular()
        imgProfile.setCircular()
        btnSend.setCircular()
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
   
  
    func initUI() {

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
        
        DataBaseManager.shared.getViewers(radioID: radio.id) { (viewers) in
            self.lblViewCount.text = "\(viewers)"
        }
        lblRadioName.text = radio.name
        guard let userID = UserManager.currentUser()?.userID else {return}
        if userID == radio.user_id {
            imgPlay.image = MICRO_ON
            lblPlay.text = "Un-Muted"
        }else{
            imgPlay.image = PAUSE_IMG
            lblPlay.text = "Playing"
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
          radioRef?.child("\(currentUser.userID ?? -1)").setValue(param)
          radioRef?.observe(.childAdded, with: { (snapshot) in
              self.getViewers()
          })
      }
    
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
//        present(controller, animated: false)
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
    
    @IBAction func onPlay(_ sender: Any?) {
        isPlaying = !isPlaying
        guard let userID = UserManager.currentUser()?.userID else {return}
        if userID == radio.user_id {
            if isPlaying {
                imgPlay.image = MICRO_OFF
                lblPlay.text = "Muted"
            } else {
                imgPlay.image = MICRO_ON
                lblPlay.text = "Un-Muted"
            }
            muteAudio()
        }else{
            if isPlaying {
                imgPlay.image = PAUSE_IMG
                lblPlay.text = "Playing"
            } else {
                imgPlay.image = PLAY_IMG
                lblPlay.text = "Paused"
            }
            speakerPressed()
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
    func followBtnPressed() {
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
    
    @IBAction func onBack(_ sender: Any) {
        
        leaveChannel()
        if let nav = self.navigationController{
            if (self.navigationController?.viewControllers.count ?? 0 > 1){
                nav.popViewController(animated: true)
            }else{
                self.dismiss(animated: true)
            }
        }else{
            self.dismiss(animated: true)
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        // Your code here
        imgPlay.image = MICRO_ON
        lblPlay.text = "Playing"
        isPlaying = false
        
    }
        
    private func setClientRole(){
        agoraKit.setClientRole(.broadcaster)
    }
    private func speakerPressed(){
        speakerEnabled = !speakerEnabled
        let res = agoraKit.setEnableSpeakerphone(speakerEnabled)
        let res1 = agoraKit.muteAllRemoteAudioStreams(!speakerEnabled)
        
        print("ChanelRes =\(self.speakerEnabled)",res)
        print("MuteRes =\(self.speakerEnabled)",res1)
    }
    private func muteAudio(){
        audioMuted = !audioMuted
        agoraKit.muteLocalAudioStream(audioMuted)
    }
    
    private func getViewers(){
        DataBaseManager.shared.getRadioViews(radioID: radio.id) { (viewers, error) in
            self.lblViewCount.text = "\(viewers)"
        }
    }
    
    //-------Comment
    @IBAction func onPostComment(_ sender: Any) {
        // post data
        sendComment()
    }
    private func loadComments(){
        // load comments
        comments.removeAll()
        radioRef?.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        self.comments.append(comment)
                    }
                }
                if self.comments.count == 0 {
                    self.emptyCommentsView.isHidden = false
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
        self.radioRef?.observe(.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        self.tempComments.append(comment)
                    }
                }
                if self.tempComments.count == 0 {
                    self.emptyCommentsView.isHidden = false
                } else {
                    self.emptyCommentsView.isHidden = true
                    self.comments = self.tempComments
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
        radioRef?.observe(.childRemoved, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = RadioComment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        self.comments.append(comment)
                    }
                }
                if self.comments.count == 0 {
                    self.emptyCommentsView.isHidden = false
                } else {
                    self.emptyCommentsView.isHidden = true
                    
                    self.tblComments.beginUpdates()
                    self.tblComments.deleteRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: .automatic)
                    self.tblComments.endUpdates()
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.emptyCommentsView.isHidden = false
            }
        })
    }
}
extension RadioDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier1 = "senderCellMessage"
        let identifier2 = "receiverCellMessage"
        
        let comment = comments[indexPath.row]
        
        let cellId =  comment.userId == UserManager.currentUser()?.userID ? identifier1 : identifier2
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageTableViewCell
        
        cell.avatarImg.setCornerRadius()
        cell.msgLbl.text = comment.comment
        
        cell.avatarImg.tag = indexPath.row
        
        if cellId == identifier2 {
            cell.senderLbl.text = comment.username
            
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapProfile(gesture:)))
            cell.avatarImg.isUserInteractionEnabled = true
            cell.avatarImg.addGestureRecognizer(singleTap)
        }
        print (Utils.getFullPath(path: comment.photo))
        cell.avatarImg.sd_setImage(with: URL(string: Utils.getFullPath(path: comment.photo)), placeholderImage: PLACEHOLDER_IMG, options: .refreshCached, completed: nil)
        
        cell.timeLbl.text = comment.created_at.timeAgo()
        
    // -----comment thread
         if comment.like == 1 {
             cell.imgLike.alpha = 1.0
         }else{
             cell.imgLike.alpha = 0.0
         }
         
         if comment.parentId == "" {
//             cell.quoteLbl.alpha = 0.0
         }else{
//             cell.quoteLbl.alpha = 1.0
//             cell.quoteLbl.text = comment.quotedeComment
         }
        
        return cell
    }
 //------Comment Thread
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let identifier1 = "senderCellMessage"
        let identifier2 = "receiverCellMessage"
        let isSend: Bool
        let comment = comments[indexPath.row]

        let cellId =  comment.userId == UserManager.currentUser()?.userID ? identifier1 : identifier2

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageTableViewCell
        
        if cellId == "senderCellMessage" {
            isSend = true
            onShowCommentThread(cell, comment, isSend)
        } else{
            isSend = false
            onShowCommentThread(cell, comment, isSend)
        }
    }
}
//MARK: - engine
private extension RadioDetailsViewController {
    func append(log string: String) {
        guard !string.isEmpty else {
            return
        }
        
        print(string)
    }
    func loadAgoraKit() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
        
        guard let userID = UserManager.currentUser()?.userID else {return}
        agoraKit.joinChannel(byToken: nil, channelId: "\(radio.id)", info: nil, uid: UInt(userID), joinSuccess: nil)
        
        if userID != radio.user_id {
            agoraKit.muteLocalAudioStream(true)
            agoraKit.setEnableSpeakerphone(true)
        }else{
            agoraKit.muteLocalAudioStream(false)
            agoraKit.setEnableSpeakerphone(false)
        }
        setupVideo()
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
    }
    private func audioUpdate(audioLevel: Float){
        self.audioVisualizationView.add(meteringLevel: audioLevel)
    }
}

extension RadioDetailsViewController: AgoraRtcEngineDelegate {
    func rtcEngineConnectionDidInterrupted(_ engine: AgoraRtcEngineKit) {
        append(log: "Connection Interrupted")
    }
    
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        append(log: "Connection Lost")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        append(log: "Occur error: \(errorCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        append(log: "Did joined channel: \(channel), with uid: \(uid), elapsed: \(elapsed)")
        self.getViewers()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        append(log: "Did joined of uid: \(uid)")
        self.getViewers()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        append(log: "Did offline of uid: \(uid), reason: \(reason.rawValue)")
        viewVideoContainer.isHidden = true
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, audioQualityOfUid uid: UInt, quality: AgoraNetworkQuality, delay: UInt, lost: UInt) {
        append(log: "Audio Quality of uid: \(uid), quality: \(quality.rawValue), delay: \(delay), lost: \(lost)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute api: String, error: Int) {
        append(log: "Did api call execute: \(api), error: \(error)")
    }
    
    // warning code
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("warning code: \(warningCode.description)")
    }
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
           
           viewVideoContainer.tag = Int(uid)
           viewVideoContainer.backgroundColor = UIColor.purple
    
           let videoCanvas = AgoraRtcVideoCanvas()
           videoCanvas.uid = uid
           videoCanvas.view = viewVideoContainer
           videoCanvas.renderMode = .hidden
           agoraKit.setupRemoteVideo(videoCanvas)
       }
     func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoEnabled enabled: Bool, byUid uid: UInt) {
        viewVideoContainer.isHidden = !enabled
    }
    
}


//------Comment Thread
extension RadioDetailsViewController{
    func onShowCommentThread(_ cell: MessageTableViewCell, _ comment: RadioComment, _ isSend: Bool) {
        // show picker
        let alert = UIAlertController(title: "Comment Thread", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let likeAction = UIAlertAction(title: "Like", style: .default)
        {
            UIAlertAction in
            self.sendLikeComment(cell, comment)
        }
        let unlikeAction = UIAlertAction(title: "UnLike", style: .default)
        {
            UIAlertAction in
            self.sendUnlikeComment(cell, comment)
        }
        let commentAction = UIAlertAction(title: "Comment", style: .default)
        {
            UIAlertAction in
            self.sendCommentInComment(cell, comment)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default)
        {
            UIAlertAction in
            self.sendDeleteComment(cell, comment)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        
        if isSend == true {
            alert.addAction(likeAction)
            alert.addAction(unlikeAction)
            alert.addAction(commentAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
        }else{
            alert.addAction(likeAction)
            alert.addAction(unlikeAction)
            alert.addAction(commentAction)
            alert.addAction(cancelAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendLikeComment(_ cell: MessageTableViewCell, _ comment : RadioComment){
        radioRef?.child("\(comment.commentId)").updateChildValues(["like":1])
    }
    func sendUnlikeComment(_ cell: MessageTableViewCell, _ comment : RadioComment){
        radioRef?.child("\(comment.commentId)").updateChildValues(["like":0])
    }
    func sendCommentInComment(_ cell: MessageTableViewCell, _ comment : RadioComment){
        let user = UserManager.currentUser()!
        let data : [String: Any] = ["comment": textView.text ?? "", "username": user.username ?? "", "photo": user.userPhoto!, "timestamp": Date().timeIntervalSince1970, "userId": user.userID ?? "", "parentId": "\(comment.commentId)", "like": 0,"quotedeComment" : "\(comment.comment)"]
        radioRef?.childByAutoId().setValue(data)
        textView.text = ""
    }
    func sendDeleteComment(_ cell: MessageTableViewCell, _ comment : RadioComment){
        radioRef?.child("\(comment.commentId)").removeValue()
    }
    func sendComment(){
        let user = UserManager.currentUser()!
        let data : [String: Any] = ["comment": textView.text ?? "", "username": user.username ?? "", "photo": user.userPhoto!, "timestamp": Date().timeIntervalSince1970, "userId": user.userID ?? "", "parentId": "", "like": 0,"quotedeComment" : ""]
        radioRef?.childByAutoId().setValue(data)
        textView.text = ""
    }
}
extension RadioDetailsViewController: FBAdViewDelegate {
    
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
    func logAdViewOrClickFromFeed(clickAd: Int) {
        
    }
    
}
