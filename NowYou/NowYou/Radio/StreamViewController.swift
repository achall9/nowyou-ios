//
//  StreamViewController.swift
//  NowYou
//
//  Created by Apple on 1/16/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import IQKeyboardManagerSwift
import SoundWave
//import GoogleMobileAds
import AgoraRtcKit
import FBAudienceNetwork

protocol StreamCompletionDelegate {
    func streamCompleted()
}

class StreamViewController: BaseViewController, AVAudioRecorderDelegate {

    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused

        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }
    var bannerAd: FBAdView!
    var lblBannerReview: UILabel!
    var failedOfBanner: Bool = false

    @IBOutlet weak var segmentVideo: UISegmentedControl!
    private let viewModel = ViewModel()

    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
        }
    }

    var delegate: StreamCompletionDelegate?

    private var chronometer: Chronometer?

    @IBOutlet weak var viewVideoContainer: UIView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var logoBorderView: UIView!
    @IBOutlet weak var tblComment: UITableView!
    @IBOutlet weak var vEmptyComments: UIView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblViewers: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var tblBottomConstraint: NSLayoutConstraint!
    // growing text view
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var textView: UITextView!

    
    var radio : RadioStation!
    
    var comments = [RadioComment]()
    var followings = [User]()

    // audio processing
    var audioProcessor: AudioProcessor?


    var isKeyboardOn: Bool = false
    
    var clientRole = AgoraClientRole.audience {
        didSet {
//            updateBroadcastButton()
        }
    }
    
    fileprivate var agoraKit: AgoraRtcEngineKit?
    fileprivate var logs = [String]()
    
    
    fileprivate var audioMuted = false {
        didSet {
//            muteAudioButton?.setImage(audioMuted ? #imageLiteral(resourceName: "btn_mute_blue") : #imageLiteral(resourceName: "btn_mute"), for: .normal)
        }
    }
    
    fileprivate var speakerEnabled = true {
        didSet {
//            speakerButton?.setImage(speakerEnabled ? #imageLiteral(resourceName: "btn_speaker_blue") : #imageLiteral(resourceName: "btn_speaker"), for: .normal)
//            speakerButton?.setImage(speakerEnabled ? #imageLiteral(resourceName: "btn_speaker") : #imageLiteral(resourceName: "btn_speaker_blue"), for: .highlighted)
        }
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
    @objc func hideAds(){
        self.bannerAd.removeFromSuperview()
        self.lblBannerReview.removeFromSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.askAudioRecordingPermission()

        IQKeyboardManager.shared.enable = false

        observeNotifications()
        initUI()
        loadComment()

        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        
        addRigthSwipe()
        onPause(self.btnPlay)
        initBannerAds()
    }
    func setupVideo() {
        let configuration = AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative)
        //        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative))
        agoraKit?.setVideoEncoderConfiguration(configuration)
        DispatchQueue.main.async {
            self.setupLocalVideo(uid: UInt(Int.random(in: 0..<5000)))
        }
        
        
    }
    func setupLocalVideo(uid: UInt) {
        
        print(uid)
        
        viewVideoContainer.tag = Int(uid)
        viewVideoContainer.backgroundColor = UIColor.clear
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = viewVideoContainer
        videoCanvas.renderMode = .hidden
        agoraKit?.setupLocalVideo(videoCanvas)
        
        
    }
    func addRigthSwipe(){
          let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
          rightSwipe.direction = .right
          view.addGestureRecognizer(rightSwipe)
      }
      @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
         if (sender.direction == .right) {
            stopStream()
            print("Swipe right")
         }
      }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func sendBroadcastForAudioRecording(_ audioTitle: String){
        NotificationManager.shared.getTokens { (tokens) in
            for token in tokens {
                NotificationManager.shared.sendPush(token: token, title: "BroadCast Audio", message: "BroadCasted \(audioTitle)", action_event: [:], userId: "\(UserManager.currentUser()?.userID ?? -1)", success: {
                    print("Successfully sent")
                }) { (error) in
                    print(error)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, options: .mixWithOthers)
        try? audioSession.setActive(true)
//        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: [])
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoBorderView.layer.borderWidth = 1.0
        logoBorderView.layer.borderColor = UIColor(hexValue: 0x744AF2).cgColor
        logoBorderView.setCircular()

        imgLogo.layer.borderWidth = 0.0
        imgLogo.layer.borderColor = UIColor(hexValue: 0x744AF2).cgColor

        btnPlay.layer.borderWidth = 0.5
        btnPlay.layer.borderColor = UIColor(hexValue: 0x979797).cgColor
        btnPlay.setCircular()

        imgProfile.setCircular()
        btnSend.setCircular()
    }
    @IBAction func onBack(_ sender: Any) {
        stopStream()
    }

    @IBAction func onSendComment(_ sender: Any) {
        let user = UserManager.currentUser()!

        let data : [String: Any] = ["comment": textView.text, "username": user.username, "photo": user.userPhoto, "timestamp": Date().timeIntervalSince1970, "userId": user.userID]
        Database.database().reference().child("Radio").child("\(radio.id)").child("comments").childByAutoId().setValue(data)

        textView.text = ""
    }

    @IBAction func onPause(_ sender: UIButton) {
        if self.audioProcessor != nil {
            self.audioProcessor?.stop()
            self.audioProcessor = nil
            btnPlay.isSelected = false
            self.chronometer?.pause()
            agoraKit?.pauseAllEffects()
            agoraKit?.disableVideo()
            do {
                try self.viewModel.pauseRecording()
            } catch {

            }
        } else {
            // start
            initAudioProcessor()
            btnPlay.isSelected = true
            self.chronometer?.start()
            self.viewModel.resumeRecording()
            loadAgoraKit()
            setupVideo()
            if(segmentVideo.selectedSegmentIndex == 1){
                agoraKit?.enableVideo()
            }else{
                agoraKit?.disableVideo()
            }
        }
        muteAudio()
    }
    
    // MARK: - Observe notifications
    func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }

    // MARK: - Notifications
    @objc func keyboardWasShown(notification: Notification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            CGRect {

            if isKeyboardOn {
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.isKeyboardOn = true
                self.tblBottomConstraint.constant = keyboardSize.height - self.view.safeAreaInsets.bottom

                DispatchQueue.main.async {
                    if self.comments.count > 0 {
                        self.tblComment.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        print ("keyboard was hidden")
        UIView.animate(withDuration: 0.3) {
            self.tblBottomConstraint.constant = self.view.safeAreaInsets.bottom
            print("bottom safe area = \(self.view.safeAreaInsets.bottom)")
            self.isKeyboardOn = false

            DispatchQueue.main.async {
                if self.comments.count > 0 {
                    self.tblComment.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }

    @IBAction func videoSegmentChanged(_ sender: Any) {
        if (segmentVideo.selectedSegmentIndex == 0){
            agoraKit?.disableVideo()
        }else{
            agoraKit?.enableVideo()
        }
    }
    @objc func applicationResignActive(notification: NSNotification) {
        // Application did become inactive
        //        onPause(btnPlay)
    }

    @objc func applicationBecomeActive(notification: NSNotification) {
        // Application is back in active
        //        onPause(btnPlay)
    }
//-------------------------------------------------
    // MARK: initialize UI

    func initUI() {
        let user = UserManager.currentUser()!
        imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto)), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)

        self.lblViewers.text = "\(radio.views)"
        lblTitle.text = radio.name
        lblCategory.text = radio.category_name

        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        textView.font = UIFont.systemFont(ofSize: 17)

        textView.layer.borderWidth = 0.5

        textView.layer.borderColor = UIColor(hexValue: 0x979797).cgColor
        textView.setRoundCorner(radius: textView.frame.height / 2)
        textView.clipsToBounds = true
    }

    // MARK: initialize audio processor
    func initAudioProcessor() {
        if audioProcessor == nil {
            audioProcessor = AudioProcessor()
            audioProcessor?.radioId = radio.id
            audioProcessor?.start()

            btnPlay.isSelected = true
            self.startRecording()
        }
    }

    func startRecording() {
        if self.currentState == .ready {
            self.viewModel.startRecording(radio_id: radio.id) { [weak self] soundRecord, error in
                if let _ = error {
                    return
                }
                self?.currentState = .recording

                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func finishRecording(success: Bool) {
        self.chronometer?.stop()
        self.chronometer = nil
        do {
            try self.viewModel.stopRecording()
            self.currentState = .ready
        } catch {
            self.currentState = .recorded
        }
        self.audioRecorderDidFinishRecording()

    }

    // quite
    func stopStream() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to stop audio streaming?", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Yes", style: .default) { (_) in
            if self.audioProcessor != nil {
                self.audioProcessor?.stop()
                self.audioProcessor = nil
            }

            self.finishRecording(success: true)
            self.leaveChannel()
        }
        let actionNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        alert.addAction(actionNo)
        self.present(alert, animated: true, completion: nil)

    }

    // load updated view count

    // load comments
    func loadComment() {
        Database.database().reference().child("Radio").child("\(radio.id)").child("comments").observe(.childAdded) { (snapshot) in
            if snapshot.exists() {

                if let value = snapshot.value as? [String: Any]{
                    let comment = RadioComment(json: value)

                    self.comments.append(comment)
                }

                if self.comments.count == 0 {
                    self.vEmptyComments.isHidden = false
                } else {
                    self.vEmptyComments.isHidden = true

                    self.tblComment.beginUpdates()
                    self.tblComment.insertRows(at: [IndexPath(row: self.comments.count - 1, section: 0)], with: .automatic)
                    self.tblComment.endUpdates()

                    // scroll to bottom
                    self.tblComment.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
                self.vEmptyComments.isHidden = false
            }
        }
    }
    
    func audioRecorderDidFinishRecording() {
//         upload audio file
           currentState = .recorded
           audioVisualizationView.stop()
        
        self.sendBroadcastForAudioRecording(self.radio.name)
            // upload to server
        if let url = viewModel.currentAudioRecord?.audioFilePathLocal {
            do {
                let audioData = try Data(contentsOf: URL(fileURLWithPath: url.path))
                NetworkManager.shared.uploadRadioFile(radio_station_id: radio.id, name: radio.name, audio: audioData) { (response) in
                    DispatchQueue.main.async {
                        switch response {
                        case .error(let error):
                            print(error.localizedDescription)
                            self.dismiss(animated: true, completion: {
                               self.delegate?.streamCompleted()
                           })
                        case .success(let data):
                            print(data ,"Uploading success")
                            
                            self.dismiss(animated: true, completion: {
                                self.delegate?.streamCompleted()
                            })
                        }// end -switch response
                    }
                }
            } catch {
                print("No Data")
                self.dismiss(animated: true, completion: {
                    self.delegate?.streamCompleted()
                })
            }
        } else {
            self.dismiss(animated: true, completion: {
                self.delegate?.streamCompleted()
            })
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_AUDIO_ADDED) , object: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    private func setClientRole(){
        agoraKit?.setClientRole(.broadcaster)
    }
    private func speakerPressed(){
        speakerEnabled = !speakerEnabled
        agoraKit?.setEnableSpeakerphone(speakerEnabled)
    }
    private func muteAudio(){
        audioMuted = !audioMuted
        agoraKit?.muteLocalAudioStream(audioMuted)
    }
    
    private func getViewers(){
        DataBaseManager.shared.getRadioViews(radioID: radio.id) { (viewers, error) in
            self.lblViewers.text = "\(viewers)"
        }
    }
    func logAdViewOrClickFromFeed(clickAd: Int) {
        
    }
}

// MARK: - Comment Table Delegate
extension StreamViewController: UITableViewDataSource, UITableViewDelegate {
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

        if cellId == identifier2 {
            cell.senderLbl.text = comment.username
        }

        cell.avatarImg.sd_setImage(with: URL(string: Utils.getFullPath(path: comment.photo)), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)

        cell.timeLbl.text = comment.created_at.timeAgo()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

//MARK: - engine
private extension StreamViewController {
    func append(log string: String) {
        guard !string.isEmpty else {
            return
        }
        
        print(string)
    }
    func loadAgoraKit() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        agoraKit?.setChannelProfile(.liveBroadcasting)
        agoraKit?.setClientRole(.broadcaster)
        
        
        guard let userID = UserManager.currentUser()?.userID else {return}
        agoraKit?.joinChannel(byToken: nil, channelId: "\(radio.id)", info: nil, uid: UInt(userID), joinSuccess: nil)
        
        agoraKit?.muteLocalAudioStream(false)
        agoraKit?.setEnableSpeakerphone(false)
    }
    
    func leaveChannel() {
        agoraKit?.leaveChannel(nil)
    }
}

extension StreamViewController: AgoraRtcEngineDelegate {
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
    
}
extension StreamViewController: FBAdViewDelegate {
    
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
    
}
