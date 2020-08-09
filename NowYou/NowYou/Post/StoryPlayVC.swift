//
//  StoryPlayVC.swift
//  NowYou
//
//  Created by Apple on 5/17/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class StoryPlayVC: UIViewController,UIViewControllerTransitioningDelegate {

    var medias = [Media]()
    var isFromFeedView : Bool!
    var sortedMedias = [[Media]]()
    var rowIndex: Int!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var hProgressBar: UIStackView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTimeStamp: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    var player: AVPlayer?
    var playerItem: CachingPlayerItem?
    var playerObserver: Any?
    var timer: Timer?
    
    var singleTapGesture: UITapGestureRecognizer!
    
    let audioSession = AVAudioSession.sharedInstance()
    
    var photoShowTime: Float = 0.0

    var playingMedia: Media? {
        didSet {
            let formatter = DateFormatter()
            
            formatter.timeZone = TimeZone.current
            
            formatter.dateFormat = "MMM dd, hh:mm a"
            lblTimeStamp.text = playingMedia!.username! + ", " +
                formatter.string(from: playingMedia!.created)
            print(formatter.timeZone ?? "")
            print(playingMedia!.created ?? "")
            print(lblTimeStamp.text ?? "")
            imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: playingMedia?.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
            imgProfile.setCircular()
            if playingMedia?.type == 0 { // photo - show 5 seconds in progress
                timer?.invalidate()
                timer = nil
                
                self.imgView.isHidden = false
                self.player?.pause()
                
                if let sublayers = self.view.layer.sublayers {
                    for sublayer in sublayers {
                        if let layer = sublayer as? AVPlayerLayer {
                            layer.removeFromSuperlayer()
                            break
                        }
                    }
                }
                
                self.imgView.sd_setImage(with: URL(string: Utils.getFullPath(path: playingMedia?.path ?? ""))) { (image, error, cacheType, url) in

                    // get index of current playing media
                    var playingMediaIdx = 0
                    for mediaIdx in 0..<self.medias.count {
                        if self.medias[mediaIdx] == self.playingMedia {
                            playingMediaIdx = mediaIdx
                            break
                        }
                    }
                    print ("photo - mediaIdx = \(playingMediaIdx)")
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (_) in
                        if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                            if subProgressView.tag == playingMediaIdx {
                                self.photoShowTime += 0.01
                                subProgressView.progress = self.photoShowTime
                                
                                if subProgressView.progress == 1.0 {
                                    if playingMediaIdx == self.medias.count - 1 {
                                        // played last media - exit
                                        if self.isFromFeedView{
                                            if self.sortedMedias.count - 1 > self.rowIndex{
                                                playingMediaIdx = 0
                                                self.rowIndex += 1
                                                self.medias  = self.sortedMedias[self.rowIndex]
                                                self.initProgressBar()
                                                self.playNextMedia(nextMediaIdx: playingMediaIdx)
                                                self.photoShowTime = 0.0
                                            }else
                                            {
                                                self.photoShowTime = 0.0
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                                                self.transitionDismissal()
                                            }
                                        }else{
                                            self.timer?.invalidate()
                                            self.timer = nil
                                            self.photoShowTime = 0.0
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                                            self.transitionDismissal()
                                        }
//                                        self.dismiss(animated: true, completion: nil)
                                    } else {
                                        self.photoShowTime = 0.0
                                        self.playNextMedia(nextMediaIdx: playingMediaIdx + 1)
                                    }
                                }
                            }
                        }
                    })
                }
            } else { // video
                // get video file reference
                self.imgView.isHidden = true
                
                timer?.invalidate()
                timer = nil
                
                self.photoShowTime = 0.0
                
                if let sublayers = self.view.layer.sublayers {
                    for sublayer in sublayers {
                        if let layer = sublayer as? AVPlayerLayer {
                            layer.removeFromSuperlayer()
                            break
                        }
                    }
                }
                self.getVideoURL(media: playingMedia!) { (url, err) in
                    if let videoURL = url {
                        self.playerItem = CachingPlayerItem(url: videoURL)
//                        self.playerItem?.delegate = self
                        // get index of current playing media
                        var playingMediaIdx = 0
                        for mediaIdx in 0..<self.medias.count {
                            if self.medias[mediaIdx] == self.playingMedia {
                                playingMediaIdx = mediaIdx
                                break
                            }
                        }
                        print ("video - mediaIdx = \(playingMediaIdx)")
                        self.player = AVPlayer(playerItem: self.playerItem)
                        self.player?.volume = 10.0
                        
                        let playerLayer = AVPlayerLayer(player: self.player)
                        playerLayer.frame = self.view.bounds
                        playerLayer.videoGravity = .resizeAspect
                        self.view.layer.insertSublayer(playerLayer, at: 0)
                        self.player?.automaticallyWaitsToMinimizeStalling = false
                        self.playerObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main, using: { (time) in
                            
                            if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                                if subProgressView.tag == playingMediaIdx {
                                    subProgressView.progress = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(self.playerItem!.duration))
                                    print("item duration = \(self.playerItem!.duration)")
                                    print("played time = \(CMTimeGetSeconds(time))")
                                    if CMTimeGetSeconds(time) == 0.0 || CMTimeGetSeconds(self.playerItem!.duration) == 0 {
                                        return
                                    }
                                    
                                    if subProgressView.progress == 1.0 {
                                        if self.playerObserver != nil {
                                            self.player?.removeTimeObserver(self.playerObserver!)
                                            self.playerObserver = nil
                                        }
                                        if subProgressView.progress == 1.0 {
                                            if playingMediaIdx == self.medias.count - 1 {
                                                // played last media - exit
                                                if self.isFromFeedView{
                                                    if self.sortedMedias.count - 1 > self.rowIndex{
                                                        playingMediaIdx = 0
                                                        self.rowIndex += 1
                                                        self.medias  = self.sortedMedias[self.rowIndex]
                                                        self.initProgressBar()
                                                        self.playNextMedia(nextMediaIdx: playingMediaIdx)
                                                        self.photoShowTime = 0.0
                                                    }else
                                                    {
                                                        self.photoShowTime = 0.0
                                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                                                        self.transitionDismissal()
                                                    }
                                                }else{
                                                    self.timer?.invalidate()
                                                    self.timer = nil
                                                    self.photoShowTime = 0.0
                                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                                                    self.transitionDismissal()
                                                }
        //                                        self.dismiss(animated: true, completion: nil)
                                            } else {
                                                self.photoShowTime = 0.0
                                                self.playNextMedia(nextMediaIdx: playingMediaIdx + 1)
                                            }
                                        }
//                                        if playingMediaIdx == self.medias.count - 1 {
//                                            // played last media - exit
//                                            self.timer?.invalidate()
//                                            self.timer = nil
//                                            self.photoShowTime = 0.0
//                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
//                                            self.transitionDismissal()
//                                        } else {
//                                            self.timer?.invalidate()
//                                            self.timer = nil
//                                            self.photoShowTime = 0.0
//
//                                            self.playNextMedia(nextMediaIdx: playingMediaIdx + 1)
//                                        }
                                    }
                                }
                            }
                        })
                        self.player?.play()
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initProgressBar()
        
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didSingleTap(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//        view.addGestureRecognizer(recognizer)
        
        let longTapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        self.view.addGestureRecognizer(longTapGesture)

        if medias.count > 0 {
            if medias[0].id != UserManager.currentUser()?.userID{
               NetworkManager.shared.logViewFeed(media_id: medias[0].id!) {(response) in
                   switch response{
                       case .error(let error):
                           print (error.localizedDescription)
                       case .success(_):
                           print("view logged for media id - \(self.medias[0].id!)")
                   }
               }
            }
            playingMedia = medias[0]
            if playingMedia?.type == 0{
                btnMute.isEnabled = false
                btnMute.alpha = 0.0
            }else{
                btnMute.isEnabled = true
                btnMute.alpha = 1.0
            }
        }

        listenVolumeButton()
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            
        downSwipe.direction = .down
        upSwipe.direction = .up

        view.addGestureRecognizer(downSwipe)
        view.addGestureRecognizer(upSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if player != nil
        {
            player?.play()
        }
        if timer != nil {
            timer?.fire()
        }
        
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
            
        if (sender.direction == .up) {
            didSwipeUp(self)
            print("Swipe up")
        }
        if (sender.direction == .down) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
            transitionDismissal()
            print("Swipe down")
        }
    }
    func listenVolumeButton(){
        audioSession.addObserver(self, forKeyPath: "outputVolume",
                                 options: NSKeyValueObservingOptions.new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            print ("volume changed")
            try? audioSession.setCategory(.ambient, options: .mixWithOthers)
            try? audioSession.setActive(true)
        }
    }
    deinit {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func longTapGesture(gesture: UITapGestureRecognizer) {
        
        if gesture.state == .began {
            if player != nil {
                player?.pause()
            }
            
            if timer != nil {
                timer?.invalidate()
                timer = nil
            }
            
            btnBack.isHidden = true
            
            btnMute.isHidden = true
            hProgressBar.isHidden = true
        } else if gesture.state == .ended {
            if player != nil {
                player?.play()
            } else {
                for mediaIdx in 0..<self.medias.count {
                    if self.medias[mediaIdx] == self.playingMedia {
                        self.playingMedia = self.medias[mediaIdx]
                        break
                    }
                }
            }
            btnBack.isHidden = false
            btnMute.isHidden = false
            
            hProgressBar.isHidden = false
        }
    }
    
    @objc func didSingleTap(gesture: UITapGestureRecognizer) {
        let pointInView: CGPoint = gesture.location(in: self.view)

        let isBack = pointInView.x < 60 ? true : false
        // get current play item index
        var playingMediaIdx = 0


        for mediaIdx in 0..<self.medias.count {
            if self.medias[mediaIdx] == self.playingMedia {
                playingMediaIdx = mediaIdx
                break
            }
        }
        
        if playerObserver != nil {
            self.player?.removeTimeObserver(playerObserver!)
            playerObserver = nil
        }
        
        self.photoShowTime = 0.0
        
        timer?.invalidate()
        timer = nil
        
        if isBack {
            if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                subProgressView.progress = 0.0
            }

            if playingMediaIdx == 0 {
                playingMediaIdx = 0
            } else {
                playingMediaIdx -= 1
            }
            
            if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                subProgressView.progress = 0.0
            }
            
            self.playingMedia = medias[playingMediaIdx]
        } else {
            if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                subProgressView.progress = 1.0
            }
//            if playingMediaIdx == medias.count - 1 {
//                transitionDismissal()
//            } else {
//                playingMediaIdx += 1
//            }
//-----------
            if playingMediaIdx == self.medias.count - 1 {
                // played last media - exit
                if self.isFromFeedView{
                    if self.sortedMedias.count - 1 > self.rowIndex{
                        playingMediaIdx = 0
                        self.rowIndex += 1
                        self.medias  = self.sortedMedias[self.rowIndex]
                        self.initProgressBar()
                    }else
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                        transitionDismissal()
                    }
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
                    transitionDismissal()
                }
            } else {
                playingMediaIdx += 1
            }
//-----------
            if let subProgressView = self.hProgressBar.arrangedSubviews[playingMediaIdx] as? UIProgressView {
                subProgressView.progress = 0.0
            }
            self.playingMedia = medias[playingMediaIdx]
        }
    }
    
    func getVideoURL(media: Media, completion: @escaping (URL?, Error?) -> Void) {
        let path = Utils.getFullPath(path: media.path ?? "")
        
        completion(URL(string: path), nil)
    }
    
    func playNextMedia(nextMediaIdx: Int) {
        print("playing index = \(nextMediaIdx)")
        playingMedia = medias[nextMediaIdx]
//        NetworkManager.shared.logViewFeed(media_id: medias[nextMediaIdx].id!) { (_) in
//            print("view logged for media id - \(self.medias[nextMediaIdx].id!)")
//        }
        if medias[nextMediaIdx].id != UserManager.currentUser()?.userID{
            NetworkManager.shared.logViewFeed(media_id: medias[nextMediaIdx].id!) {(response) in
               switch response{
                   case .error(let error):
                       print (error.localizedDescription)
                   case .success(_):
                        print("view logged for media id - \(self.medias[nextMediaIdx].id!)")
               }
           }
        }       
    }
    
    func initProgressBar() {
        hProgressBar.removeAllArrangedSubviews()
        for mediaIdx in 0..<medias.count{
            let progressView = UIProgressView(progressViewStyle: .default)
            progressView.progress = 0.0
            progressView.tintColor = UIColor.white
            progressView.tag = mediaIdx
            hProgressBar.addArrangedSubview(progressView)
        }
    }
        
//    @objc func gesture(_ sender: UIPanGestureRecognizer) {
//
//        let percentThreshold: CGFloat = 0.15
//        let translation = sender.translation(in: view)
//        let fingerMovement = translation.y / view.bounds.height
//        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
//        let rightMovementPercent = fminf(rightMovement, 1.0)
//        let progress = CGFloat(rightMovementPercent)
//
//        switch sender.state {
//        case .began:
//
//            interactor?.hasStarted = true
////            navigationController?.popViewController(animated: true)
////            dismiss(animated: true)
////            didSwipeUp(self)
//
//        case .changed:
//
//            interactor?.shouldFinish = progress > percentThreshold
//            interactor?.update(progress)
//
//        case .cancelled:
//
//            interactor?.hasStarted = false
//            interactor?.cancel()
//
//        case .ended:
//
//            guard let interactor = interactor else { return }
//            interactor.hasStarted = false
//
//            if interactor.shouldFinish {
//
//                player?.currentItem?.cancelPendingSeeks()
//                if let asset = player?.currentItem?.asset {
//                    asset.cancelLoading()
//                }
//
//                player?.replaceCurrentItem(with: nil)
//
//                timer?.invalidate()
//                timer = nil
//                self.photoShowTime = 0.0
//
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
//                interactor.finish()
//            } else {
//                interactor.cancel()
//            }
//        default:
//            break
//        }
//    }
    @IBAction func didSwipeUp(_ sender: Any) {
        print ("to comments from story")
        performSegue(withIdentifier: "toCommentsFromStory", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentsFromStory" {
            let vc = segue.destination as! CommentViewController
            vc.media = self.playingMedia
        }
    }
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    func transitionDismissal() {
        transition.duration = 0.1
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromBottom
        view.window?.layer.add(transition, forKey: nil)
        
        if let homeVc = presentingViewController {
            homeVc.view.alpha = 1.0
        }
        
        player?.pause()
        player?.currentItem?.cancelPendingSeeks()
        if let asset = player?.currentItem?.asset {
            asset.cancelLoading()
        }
        
        player?.replaceCurrentItem(with: nil)
        timer?.invalidate()
        timer = nil
        self.photoShowTime = 0.0
        navigationController?.popViewController(animated: true)
//        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onMute(_ sender: Any) {
        btnMute.isSelected = !btnMute.isSelected
        
        if btnMute.isSelected {
            player?.isMuted = true
        } else {
            player?.isMuted = false
        }
    }
    
    @IBAction func onGoToProfile(_ sender: Any) {
        print("other profile")
        guard let userID = playingMedia?.userId else{return}
        player?.pause()
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
                                if searchUser.user?.userID == UserManager.currentUser()?.userID{
                                    let profile = UIViewController.viewControllerWith("ProfileViewController") as! ProfileViewController
                                    profile.transitioningDelegate = self
//                                    profile.interactor = self.interactor!
                                    self.transition(to: profile)
                                }else{
                                    let profile = UIViewController.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
                                    profile.blockerTap = false
                                    profile.user = searchUser
                                    profile.transitioningDelegate = self
                                    profile.interactor = self.interactor!
                                    self.transition(to: profile)
                                }
                            }
                        }
                    } catch {
                    }
                }//--end  switch response
            }//--end  DispatchQueue.main.async
        }//--end  NetworkManager.shared.getUserDetails(userId: userID)
    }
    @IBAction func onLike(_ sender: Any) {
    }
    
    @IBAction func onComment(_ sender: Any) {
    }
    
    @IBAction func onBack(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": true])
        transitionDismissal()
    }
}

extension StoryPlayVC: CachingPlayerItemDelegate {
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        print("media item ready to play")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print("download failed = \(error.localizedDescription)")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("downloaded bytes = \(bytesDownloaded)")
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("downloading finished")
    }
}
