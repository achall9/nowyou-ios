//
//  CameraViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import SwiftVideoGenerator


class CameraViewController: BaseViewController,  UIViewControllerTransitioningDelegate {
    let cameraManager = CameraManager()
    
    @IBOutlet weak var previewView: UIView!
    
    
    // record button
    var recordButton : RecordButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 0
    
    var zoomGesture: UIPanGestureRecognizer!
    
    var isRecording: Bool = false
    var flashOn: Bool = false
    
    
    var frames = [URL]()
    var videoURL_1 = URL(string: "")
    var videoURL_2 = URL(string: "")
    
    let interactor = Interactor()
    let transition = CATransition()
    let audioSession = AVAudioSession.sharedInstance()

    @IBOutlet weak var recBtnView: UIView!
    @IBOutlet weak var imgCameraRoll: UIImageView!
    @IBOutlet weak var frameViewController: UICollectionView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var lblNotification: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.shouldEnableExposure = false
        cameraManager.shouldFlipFrontCameraImage = false
        cameraManager.showAccessPermissionPopupAutomatically = false
        frameViewController.register(UINib(nibName: "VideoFrameCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoFrameCell")
        
        recordButton = RecordButton(frame: CGRect(x: 0, y: 0, width: recBtnView.frame.width, height: recBtnView.frame.height))
        recordButton.progressColor = UIColor.red
        recordButton.closeWhenFinished = true

        PHPhotoLibrary.shared().register(self)
        
        // add tap gesture to previeLayer for camera switch
        let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        previewView.isUserInteractionEnabled = true
        previewView.addGestureRecognizer(tap)
        
        
        //add tap gesture to previewLayer for camera focus
        let focusTap = UITapGestureRecognizer(target: self, action: #selector(focusCamera(_:)))
        focusTap.numberOfTapsRequired = 1
        focusTap.delegate = self
        previewView.addGestureRecognizer(focusTap)
        focusTap.require(toFail: tap)
        
        
        
        zoomGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanZoom(_:)))
        zoomGesture.delegate = self
        //recordButton.addGestureRecognizer(zoomGesture)
        
        // add tap gesture to rec button for capture photo
        let cameraRollGesture = UITapGestureRecognizer(target: self, action: #selector(onCameraRoll(_:)))
        cameraRollGesture.numberOfTapsRequired = 1
        imgCameraRoll.isUserInteractionEnabled = true
        imgCameraRoll.addGestureRecognizer(cameraRollGesture)
        imgCameraRoll.isHidden = false
        
        
        checkAuthorizationForPhotoLibraryAndGet()
        NotificationCenter.default.addObserver(self, selector: #selector(pushReceived(_:)), name: NSNotification.Name(rawValue: "push_received"), object: nil)
        

        
        
        self.recBtnView.addSubview(self.recordButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            lblNotification.isHidden = false
        } else {
            lblNotification.isHidden = true
        }
        
        cameraManager.writeFilesToPhoneLibrary = false
        askForCameraPermissions()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cameraManager.stopCaptureSession()
    }
    
    fileprivate func addCameraToView() {
        
        
        cameraManager.addLayerPreviewToView(self.previewView, newCameraOutputMode: .videoOnly, completion: {() in
            print("Camera ready")
          
            DispatchQueue.main.async {
                let recGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.onRecVideo(_:)))
                recGesture.delegate = self
                self.recordButton.addGestureRecognizer(recGesture)
                
                // add tap gesture to rec button for capture photo
                let photoGesture = UITapGestureRecognizer(target: self, action: #selector(self.onTakePhoto(_:)))
                photoGesture.numberOfTapsRequired = 1
                self.recordButton.addGestureRecognizer(photoGesture)
                
                
                self.cameraManager.cameraOutputMode = .videoOnly
                self.cameraManager.resumeCaptureSession()
                
        
                  
            }
            
        })
              
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage:String) -> Void in
            self?.showAlertWithError(title: erTitle, message: erMessage)
        }
        
        
    }
    
    func changeCameraDevice() {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    
    func askForCameraPermissions(){
        self.cameraManager.askUserForCameraPermission { permissionGranted in
            if permissionGranted {
                self.addCameraToView()
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPreview" {
            let previewVC = segue.destination as! PostViewController
            previewVC.capturedImage = sender as? UIImage
            
        } else if segue.identifier == "toVideoPreview" {
            let previewVC = segue.destination as! PostViewController
            previewVC.videoUrl = sender as?   URL
        } else if segue.identifier == "toCameraRoll" {
            let cameraRollVC = segue.destination as! CameraRollViewController
            cameraRollVC.delegate = self
        }
    }
    
    @objc func pushReceived(_ notification: Notification) {
        if UIApplication.shared.applicationIconBadgeNumber != 0 {
            lblNotification.isHidden = false
        } else {
            lblNotification.isHidden = true
        }
    }
    
    private func getPhotosAndVideos(){

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        let imagesAndVideos = PHAsset.fetchAssets(with: fetchOptions)

        let last = imagesAndVideos.firstObject

        DispatchQueue.main.async {
            self.imgCameraRoll.image = last?.thumbnailImage
        }
    }
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        
        if controller is NotificationViewController {
            transition.subtype = CATransitionSubtype.fromRight
        } else {
            transition.subtype = CATransitionSubtype.fromTop
        }
        
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
//        present(controller, animated: false)
    }
    
    // MARK: - Animation
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
            if dismissed is NotificationViewController || dismissed is SearchViewController {
                return DismissAnimator()
            }
            
            return VerticalDismissAnimator()
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactor.hasStarted
                ? interactor
                : nil
    }
    
    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getPhotosAndVideos()
                }else {

                }
            })
        }
    }
    
    @objc func record() {
        
        if self.progressTimer != nil {
            self.progressTimer.invalidate()
            self.progressTimer = nil
        }
        
        self.isRecording = true
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.06667, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
         
        cameraManager.startRecordingVideo()
    }
    
    @objc func updateProgress() {
        
        let maxDuration = CGFloat(15) // Max duration of the recordButton
        
        progress = progress + (CGFloat(0.06667) / maxDuration)
        
        if progress >= 1 {
            progress = 0.0
            cameraManager.stopVideoRecording { (videoURL, error) in

                DispatchQueue.main.async {
                    if error != nil {
                        self.cameraManager.showErrorBlock("Error occurred", "Cannot save video.")
                    }else{
                        self.frames.append(videoURL!)
                        self.frameViewController.reloadData()
                    }
                    self.record()
                }
            }
        }
        recordButton.setProgress(progress)
    }
    
    @objc func stop() {
        self.progressTimer.invalidate()
        progress = 0.0
        
        recordButton.setProgress(progress)
        recordButton.buttonState = .idle
        
        self.isRecording = false
        cameraManager.zoom(0.0)
        
    }
    
    // record video
    @objc func onRecVideo(_ sender: UIGestureRecognizer){
        
        
        cameraManager.cameraOutputMode = .videoWithMic
        
        
        if sender.state == .began {
            
            self.recordButton.buttonState = .recording
            record()
            
        } else if sender.state == .ended {
            
            self.recordButton.setProgress(1)
            
            UIView.animate(withDuration: 0.05, animations: {
                self.recordButton.buttonState = .idle
            }, completion: { completion in
                self.recordButton.setProgress(0)
                self.recordButton.currentProgress = 0
            })
            self.stop()
            
            cameraManager.stopVideoRecording { (videoURL, error) in
                if error != nil {
                    self.cameraManager.showErrorBlock("Error occurred", "Cannot save video.")
                } else {
                    DispatchQueue.main.async {
                        
                        if self.videoURL_1?.absoluteString == "" || self.videoURL_1?.absoluteString == nil { // recoding WITHOUT flip
                            self.videoURL_1 = URL.init(string: "")
                            self.gotoPhotoEditorViewController(videoURL)
                        } else { // recording WITH flip
                            self.videoURL_2 = videoURL
                            // SHOULD generate a new video url which is combined with 2 videos (videoURL_1 + videoURL_2)
                                                              
                            
                            VideoGenerator.presetName = AVAssetExportPresetPassthrough
                            VideoGenerator.fileName = "MergedMovieFileName"
                            
                            VideoGenerator.mergeMovies(videoURLs: [self.videoURL_1!, self.videoURL_2!]) { (result: Result<URL, Error>) in
                                switch result {
                                    case .success(let url):
                                        print(url.absoluteString)
                                    self.gotoPhotoEditorViewController(url)
                                    case .failure(let error):
                                        print(error)
                                }
                            }
                            
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    func gotoPhotoEditorViewController(_ videoURL: URL?) {
        self.frames.append(videoURL!)
        let storyboard = UIStoryboard(name: "PhotoEditor", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as! PhotoEditorViewController
        vc.videoURL = videoURL
        vc.checkVideoOrIamge = false
        vc.photoEditorDelegate = self
        vc.frames = self.frames
        for i in 0...10 {
            vc.stickers.append(UIImage(named: i.description )!)
        }
        self.frames.removeAll()
        self.frameViewController.reloadData()
        try? self.audioSession.setCategory(.ambient, options: .mixWithOthers)
        try? self.audioSession.setActive(true)

        self.initTempURLs()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func initTempURLs() {
        self.videoURL_1 = URL.init(string: "")
        self.videoURL_2 = URL.init(string: "")
    }
    
    @objc func onCameraRoll(_ sender: UIGestureRecognizer){
        let cameraRollVC = UIViewController.viewControllerWith("CameraRollViewController") as! CameraRollViewController
        
        cameraRollVC.transitioningDelegate = self
        cameraRollVC.interactor = interactor
        cameraRollVC.delegate = self
        
        transition(to: cameraRollVC)
    }
    
    // zoom
    @objc func onPanZoom(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let panVelocityDividerFactor: CGFloat = 30.0
            
            let translation = sender.translation(in: self.view)
            let desiredZoomFactor = 1.0 - translation.y / panVelocityDividerFactor
            cameraManager.zoom(max(0.0, desiredZoomFactor))
        }
    }
    
    
    // take photo
    @objc func onTakePhoto(_ sender: UIGestureRecognizer){
        
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        
        cameraManager.cameraOutputMode = .stillImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cameraManager.capturePictureWithCompletion { (result) in
                switch result {
                case .failure:
                    activityView.stopAnimating()
                    activityView.hidesWhenStopped = true
                    self.cameraManager.showErrorBlock("Error occurred", "Cannot save picture")
                    
                case .success(content: let content):

                    DispatchQueue.main.async {
                        activityView.stopAnimating()
                        activityView.hidesWhenStopped = true
                        
                        
                        
                        if let capturedImage = content.asImage {
                            let storyboard = UIStoryboard(name: "PhotoEditor", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as! PhotoEditorViewController
                            vc.photo = capturedImage
                            vc.checkVideoOrIamge = true
                            vc.photoEditorDelegate = self
                            for i in 0...10 {
                                vc.stickers.append(UIImage(named: i.description )!)
                            }
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                activityView.stopAnimating()
                activityView.hidesWhenStopped = true
            }
        }
        
    }
    
    @objc func focusCamera(_ sender: UITapGestureRecognizer) {
        if (sender.state == .ended) {
            self.cameraManager.focusMode = .autoFocus
        }
    }
    
    @objc func flipCamera() {
        
        if self.isRecording {
            cameraManager.stopVideoRecording { (videoURL, error) in
                if error != nil {
                    
                    self.cameraManager.showErrorBlock("Error occurred", "Cannot save video.")
                } else {
                    DispatchQueue.main.async {
                        self.videoURL_1 = videoURL
                        self.changeCameraDevice()
                        self.record()
                    }
                }
            }
        } else {
            self.changeCameraDevice()
        }
        
        
    }

    @IBAction func onFlash(_ sender: Any) {
        flashOn = !flashOn
        if flashOn {
            flashBtn.setImage(UIImage(named: "NY_cam_flash"), for: .normal)
        }else{
            flashBtn.setImage(UIImage(named: "NY_cam_flash_outlined"), for: .normal)
        }
        cameraManager.flashMode = flashOn ? .on : .off
    }
    
    
    @IBAction func onNotification(_ sender: Any) {
        let settingsVC = UIViewController.viewControllerWith("NotificationViewController") as! NotificationViewController
        
        settingsVC.transitioningDelegate = self
        settingsVC.interactor = interactor
        
        transition(to: settingsVC)
        
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let playVC = UIViewController.viewControllerWith("SearchViewController") as! SearchViewController
        
        playVC.transitioningDelegate = self
        playVC.interactor = interactor
        transition(to: playVC)
    }
    
}

extension CameraViewController: PhotoEditorDelegate {
    

    func videoEdited(videoUrls: [URL], hashtag: String?, link: [String], linkRect: [CGRect], angle: [Float], taggedUserId: [String] ,sender: PhotoEditorViewController) {
        sender.dismiss(animated: true) {
            self.uploadPrimaryVideo(videoUrl: videoUrls, hashtag: hashtag, link: link, linkRect: linkRect, angle: angle)
//            DispatchQueue.main.async {
//                self.navigationController?.popViewController(animated: true)
//            }
            return
        }
    }

    func imageEdited(image: UIImage, hashtag: String?, link: String?, linkRect: CGRect, angle: Float, taggedUserId: [String], sender: PhotoEditorViewController) {
        
        sender.dismiss(animated: true) {
            let data = image.pngData()
            
            guard data != nil else {
                return
            }
            DispatchQueue.main.async {
                Utils.showSpinner()
            }
            
            var tag: String
            
            if hashtag == nil {
                tag = ""
            } else {
                tag = hashtag!
            }
            
            let tags = tag.components(separatedBy: "#")
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            NetworkManager.shared.postMedia(hash_tag: tags, description: "test", forever: true, isVideo: false, thumbnail: nil,  media: data!, link: link ?? "", user_id: (UserManager.currentUser()?.userID)!, screen_w: Int(screenWidth), screen_h: Int(screenHeight), x: linkRect.origin.x, y: linkRect.origin.y, width: linkRect.size.width, height: linkRect.size.height, angle: angle, scale: 0, taggedUserId: taggedUserId) { (response) in
                
                DispatchQueue.main.async {
                    Utils.hideSpinner()
                    switch response {
                    case .error(let error):
                        print (error.localizedDescription)
                        break
                    case .success(let data):
                        print("photo posted successfully")
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let bar = jsonRes as? [String: AnyObject] {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.NEW_MEDIA_POSTED), object: nil, userInfo: nil)
                            }
                        } catch {
                            
                        }
                        break
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
    
    func uploadExtraVideos(feed_id: Int, videoUrls: [URL], link: [String], linkRect: [CGRect], angle: [Float]) {
        var data: Data?
        
        do {
            data = try Data(contentsOf: videoUrls.first!)
        } catch {
            
        }
        
        guard data != nil else {
            return
        }
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        let rect = linkRect[0]
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        NetworkManager.shared.postVideoToFeed(feed_id: feed_id, media: data!, link: link[0], screen_w: Int(screenWidth), screen_h: Int(screenHeight), x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height, angle: CGFloat(angle[0]), scale: 0) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            
                switch response {
                    
                case .error(let error):
                    print(error)
                case .success(let data):
                    do {
                        
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        var extraVideos = [URL]()
                        var links = [String]()
                        var linkRects = [CGRect]()
                        var linkAngles = [Float]()
                        if videoUrls.count > 1 {
                            for extraVideoIndex in 1...videoUrls.count - 1 {
                                extraVideos.append(videoUrls[extraVideoIndex])
                                links.append(link[extraVideoIndex])
                                linkRects.append(linkRect[extraVideoIndex])
                                linkAngles.append(angle[extraVideoIndex])
                            }
                            self.uploadExtraVideos(feed_id: feed_id, videoUrls: extraVideos, link: links, linkRect: linkRects, angle: linkAngles)
                            
                        } else {
                            
                        }
                        
                        UserDefaults.standard.synchronize()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.NEW_MEDIA_POSTED), object: nil, userInfo: nil)

                    } catch {
                        
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func uploadPrimaryVideo(videoUrl: [URL], hashtag: String?, link: [String], linkRect: [CGRect], angle: [Float]) {
        var data: Data?
        var thumbnail: Data?
        guard videoUrl.count > 0 else {
            return
        }
        do {
            data = try Data(contentsOf: videoUrl.first!)
            let thumbImg = Utils.getThumbnailFrom(path: videoUrl.first!)?.resized(toWidth: 50)
            
            if thumbImg != nil {
                thumbnail = thumbImg?.pngData()
            }
        } catch {
        }
        guard data != nil else {
            return
        }
        
        var tag: String
        
        if hashtag == nil {
            tag = ""
        } else {
            tag = hashtag!
        }
        
        let tags = tag.components(separatedBy: "#")
        
        let rect = linkRect[0]
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.postMedia(hash_tag: ["128"], description: "test", forever: true, isVideo: true, thumbnail: thumbnail,  media: data!, link: link[0], user_id: (UserManager.currentUser()?.userID)!, screen_w: Int(screenWidth), screen_h: Int(screenHeight), x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height, angle: angle[0], scale: 0, taggedUserId: ["128"]) { (response) in
            
            DispatchQueue.main.async{
                Utils.hideSpinner()
                switch response {
                    case .error(let error):
                        print (error.localizedDescription)
                        break
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let res = jsonRes as? [String: AnyObject] {
                                let feed_id = res["feed_id"] as! Int
                                
                                var extraVideos = [URL]()
                                var links = [String]()
                                var linkRects = [CGRect]()
                                var linkAngles = [Float]()
                                
                                if videoUrl.count > 1 {
                                    for extraVideoIndex in 1...videoUrl.count - 1 {
                                        extraVideos.append(videoUrl[extraVideoIndex])
                                        links.append(link[extraVideoIndex])
                                        linkRects.append(linkRect[extraVideoIndex])
                                        linkAngles.append(angle[extraVideoIndex])
                                    }
                                }
                                
                                if extraVideos.count > 0 {
                                    self.uploadExtraVideos(feed_id: feed_id, videoUrls: extraVideos, link: links, linkRect: linkRects, angle: linkAngles)
                                }
                                
                                UserDefaults.standard.synchronize()
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.NEW_MEDIA_POSTED), object: nil, userInfo: nil)
                                print("Video posted successfully")
                            }
                        } catch {
                            
                        }
                        break
                    }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func editorCanceled() {
        
    }
    
}

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer == zoomGesture {
            print("other gesture is recognizing")
            return true
        }
        
        return false
    }
}

extension CameraViewController: CameraRollDelegate {
    func selectedAsset(asset: PHAsset) {
        if asset.mediaType == .image {
            let requestImageOption = PHImageRequestOptions()
            requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            
            let manager = PHImageManager.default()
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode:PHImageContentMode.default, options: requestImageOption) { (image:UIImage?, _) in
                let storyboard = UIStoryboard(name: "PhotoEditor", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as! PhotoEditorViewController
                vc.photo = image
                vc.checkVideoOrIamge = true
                vc.photoEditorDelegate = self
                for i in 0...10 {
                    vc.stickers.append(UIImage(named: i.description )!)
                }
                self.navigationController?.pushViewController(vc, animated: false)
//                self.present(vc, animated: false, completion: nil)
            }
        } else if asset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    let storyboard = UIStoryboard(name: "PhotoEditor", bundle: nil)
                    DispatchQueue.main.async {
                       let vc = storyboard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as! PhotoEditorViewController
                       self.frames.append(localVideoUrl)
                       vc.frames = self.frames
                       vc.videoURL = localVideoUrl
                       vc.checkVideoOrIamge = false
                       vc.photoEditorDelegate = self
                       for i in 0...10 {
                           vc.stickers.append(UIImage(named: i.description )!)
                       }
                       self.navigationController?.pushViewController(vc, animated: false)
                    }
//                    self.present(vc, animated: false, completion: nil)
                }
            })
        }
    }
    
    func checkIfCameraPermissionAllowed(_ completion: @escaping ((Bool)->())) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            //already authorized
            completion(true)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    completion(true)
                } else {
                    //access denied
                    completion(false)
                }
            })
        }
    }
}

extension CameraViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return frames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFrameCell", for: indexPath) as! VideoFrameCell
        
        let frameURL = frames[indexPath.row]
        
        cell.imgFrame.image = Utils.getThumbnailFrom(path: frameURL)
        
        cell.imgFrame.layer.cornerRadius = 3
        cell.imgFrame.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 30, height: collectionView.frame.size.height)
    }
}

extension CameraViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.getPhotosAndVideos()
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}

