//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import ActiveLabel
import ColorSlider
import CropViewController
public var switchCam = Bool()

public protocol PhotoEditorDelegate {
    func imageEdited(image: UIImage, hashtag: String?, link: String?, linkRect: CGRect, angle: Float, taggedUserId: [String], sender: PhotoEditorViewController)
    func videoEdited(videoUrls: [URL], hashtag: String?, link: [String], linkRect: [CGRect], angle: [Float], taggedUserId: [String], sender: PhotoEditorViewController)
    func editorCanceled()
}

public final class PhotoEditorViewController: UIViewController {
    
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var videoViewContainer: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var framesView: UICollectionView!
 
    @IBOutlet weak var btnBrushEraser: UIButton!
    @IBOutlet weak var btnBrushPen: UIButton!
    
    //To hold the drawings and stickers
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    
    @IBOutlet weak var widthSlider: SwiftlySlider!
    @IBOutlet weak var horizontalColorPicker: UIView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblPenWidthFloat: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var btnTag: UIButton!
    
    public var videoURL = URL(string: "")
    public var player: AVPlayer?
    public var playerController : AVPlayerViewController?
    public var output = AVPlayerItemVideoOutput()
    public var checkVideoOrIamge = Bool()
    public var photo: UIImage?
    public var stickers : [UIImage] = []
    public var photoEditorDelegate: PhotoEditorDelegate?
    
    var bottomSheetVC: BottomSheetViewController!
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

    var frames = [URL]()
    var finalFrames = [URL]()
    var tempImageViews = [UIImageView]()
    var selectedFrame: NSInteger = 0
    var bottomSheetIsVisible = false
    var drawColor: UIColor = UIColor.red
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var isErasing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var opacity: CGFloat = 1.0
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var activeTextField: UITextField?
    var lastHashTagTextFieldY: CGFloat = 100
    var imageRotated: Bool = false
    var imageViewToPan: UIImageView?
    var hashtag: String?
    var taggedUserId: String = "0"
    var linkTextField: UITextField?
    var drawingIndex = [Int]()
    var attachedLinks = [String]()
    var attachedLinkPos = [CGRect]()
    var attachedLinkPosAngle = [Float]()
    var penWidth: Int = 5
    var colorSlider: ColorSlider!
    var exportSession:AVAssetExportSession!
    var isPen: Bool = true
    
    
    
    var users = [User]()
    var pageNum: Int = 1
    var selected_user: User!
    
    
    
    
    //Register Custom font before we load XIB
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if frames.count == 0 {
            attachedLinks.append("")
            attachedLinkPos.append(CGRect.zero)
            attachedLinkPosAngle.append(0)
        } else {
            for _ in 0..<frames.count {
                attachedLinks.append("")
                attachedLinkPos.append(CGRect.zero)
                attachedLinkPosAngle.append(0)
            }
        }
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.ambient, options: .mixWithOthers)
        try? audioSession.setActive(true)
        
        widthSlider.minValue = 1
        widthSlider.maxValue = 20
        widthSlider.currentValue = 5
        widthSlider.delegate = self
        widthSlider.direction = SwiftlySlider.PickerDirection.vertical
        widthSlider.useNormalIndicator = false
        
        horizontalColorPicker.backgroundColor = UIColor.clear
        
        colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
        colorSlider.addTarget(self, action: #selector(changedColor(slider:)), for: .valueChanged)
        horizontalColorPicker.addSubview(colorSlider)
        
        setupConstraints()
        
        framesView.register(UINib(nibName: "VideoFrameCell", bundle: Bundle.main), forCellWithReuseIdentifier: "VideoFrameCell")

        topGradient.isHidden = true
        bottomGradient.isHidden = true

        if checkVideoOrIamge {
            videoViewContainer.isHidden = true
            imageView.contentMode = UIView.ContentMode.scaleAspectFill
           canvasView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
           tempImageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
            
            imageView.isHidden = false
            imageView.image = photo
        } else {
            tempImageViews.append(tempImageView)
            
            if frames.count > 1 {
                for _ in 0...frames.count - 2 {
                    let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
                    canvasView.insertSubview(imgView, at: 0)
                    imgView.isHidden = true
                    addGestures(view: imgView)
                    tempImageViews.append(imgView)
                }
            }
            playVideo()
        }
       
        addGestures(view: self.tempImageView)
        deleteView.layer.cornerRadius = deleteView.bounds.height / 2
        deleteView.layer.borderWidth = 2.0
        deleteView.layer.borderColor = UIColor.white.cgColor
        deleteView.clipsToBounds = true
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(taggedUserNotification(notification:)),
                                               name: .taggedUserNotification, object: nil)
            
        configureCollectionView()
        bottomSheetVC = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: Bundle(for: BottomSheetViewController.self))
        getAllUsers()
    }
    
    
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.post(name: .photoEditViewEnable, object: self)
        continueBtn.isEnabled = true
    }
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .photoEditViewDisable, object: self)
    }
    // Set up view constraints for color slider.
    func setupConstraints() {
        let colorSliderHeight = CGFloat(15)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSlider.centerXAnchor.constraint(equalTo: self.horizontalColorPicker.centerXAnchor),
            colorSlider.bottomAnchor.constraint(equalTo: self.horizontalColorPicker.centerYAnchor),
            colorSlider.widthAnchor.constraint(equalToConstant: horizontalColorPicker.frame.width),
            colorSlider.heightAnchor.constraint(equalToConstant: colorSliderHeight),
            ])
    }
    
    func playVideo() {
        if frames.count < 2 {
            framesView.isHidden = true
        }
        
        videoURL = frames[selectedFrame]
        
        videoViewContainer.isHidden = true
        imageView.isHidden = true
        
        if player != nil {
            player?.pause()
            player = nil
        }
        
        if playerController == nil {
            playerController = AVPlayerViewController()
        }
        
        player = AVPlayer(url: videoURL!)
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        playerController?.videoGravity = .resizeAspectFill
        
        playerController!.player = player!
        self.addChild(playerController!)
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        } else {
            tempImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        }
        
        for index in 0...tempImageViews.count - 1 {
            let imgView = tempImageViews[index]
            if selectedFrame == index {
                imgView.isHidden = false
            } else {
                imgView.isHidden = true
            }
        }
        
        playerController!.view.frame = view.frame
        
        view.insertSubview(playerController!.view, belowSubview: canvasView)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(true)
        
        if checkVideoOrIamge {
            
        } else {
             player?.play()
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLink" {
            if let vc = segue.destination as? LinkAttachViewController {
                
                vc.prevLink = attachedLinks[selectedFrame]
                vc.delegate = self
                vc.selectedFrame = selectedFrame
            }
        }
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
    }
    
    func configureCollectionView() {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        colorsCollectionViewDelegate.chosenColor = textColor
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
        
    }
    
   
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        colorPickerView.isHidden = true
        horizontalColorPicker.isHidden = false

        doneButton.isHidden = false
        hideToolbar(hide: true)
        btnBrushEraser.isHidden = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
//        doneButton.isHidden = true
        btnBrushEraser.isHidden = true
//        hideToolbar(hide: false)
        
        widthSlider.isHidden = true
        horizontalColorPicker.isHidden = true
        colorPickerView.isHidden = true
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                if let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue{
                    
                    let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    
                    if (endFrame.origin.y) >= UIScreen.main.bounds.size.height {
                        if UIDevice().userInterfaceIdiom == .phone {
                            switch UIScreen.main.nativeBounds.height {
                            case 1136:
                                print("iPhone 5 or 5S or 5C")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            case 1334:
                                print("iPhone 6/6S/7/8")
                                self.colorPickerViewBottomConstraint?.constant = 0.0 + 15
                            case 1920, 2208:
                                print("iPhone 6+/6S+/7+/8+")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            case 2436:
                                print("iPhone X")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            default:
                                print("unknown")
                                self.colorPickerViewBottomConstraint?.constant = 0.0
                            }
                        }
                     
                    } else {
                    
                        switch UIScreen.main.nativeBounds.height {
                        case 1136:
                            print("iPhone 5 or 5S or 5C")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height
                        case 1334:
                            print("iPhone 6/6S/7/8")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height + 15
                        case 1920, 2208:
                            print("iPhone 6+/6S+/7+/8+")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height + 15
                        case 2436:
                            print("iPhone X")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height - 20
                        default:
                            print("unknown")
                            self.colorPickerViewBottomConstraint?.constant = endFrame.size.height
                        }
                    }
                    
                    UIView.animate(withDuration: duration,
                                   delay: TimeInterval(0),
                                   options: animationCurve,
                                   animations: { self.view.layoutIfNeeded() },
                                   completion: nil)
                }
            }
        }
    }
    
    
    @objc func image(_ image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Image Saved", message: "Image successfully saved to Photos library", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @objc func taggedUserNotification( notification: Notification){
        let userInfo = notification.userInfo
        let selected_user = userInfo!["selected_user"] as? User
        self.taggedUserId = "\(selected_user?.userID ?? 0)"
        
        if self.btnTag.titleColor(for: .normal) == .white {
            self.btnTag.setTitleColor(.red, for: .normal)
        }
        
    }
    
    @IBAction func tagTapped(_ sender: UIButton) {
        
        let  dropDown = DropDown(frame: CGRect(x: 20, y: 50, width: UIScreen.main.bounds.width - 40, height: 200)) // set frame
        dropDown.textColor = textColor
        dropDown.arrowColor = .clear
        
        
        // The list of array to display. Can be changed dynamically
        dropDown.optionArray = self.users.map { "@" + $0.username }
        
        dropDown.textAlignment = .center
        dropDown.font = UIFont(name: "Courier", size: 20)
        dropDown.text = "Type/Select the name"
        dropDown.becomeFirstResponder()
        
        // The the Closure returns Selected Index and String
        dropDown.didSelect{(selectedText , index ,id) in
            //self.valueLabel.text = "Selected String: \(selectedText) \n index: \(index)"
            dropDown.text = selectedText
            self.selected_user = self.users.filter{ "@" + $0.username == selectedText }.first
            print("selected_user")
        }
        addGestures(view: dropDown)
        addPanGuesture(view: dropDown)
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.addSubview(dropDown)
        } else {
            self.tempImageView.addSubview(dropDown)
        }
        framesView.isHidden = true
    }
    
    
    func getAllUsers() {
        users.removeAll()
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        NetworkManager.shared.getAllUsers(pageNum: pageNum) { (response) in
                
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                        print (jsonRes)
                        if let json = jsonRes as? [[String: Any]]/*, let usersData = json["data"] as? [[String: Any]]*/ {
                            for user in json {
                                if let userData = user["user"] as? [String: Any] {
                                    let userObj = User(json: userData)
                                    
                                    self.users.append(userObj)
                                }
                            }
                        }
                    } catch {
                        
                    }
                }// End switch response
                DispatchQueue.main.async {
                    Utils.hideSpinner()
                }
            }// End DispatchQueue.main.async {
        }
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
       
       if checkVideoOrIamge {
           UIImageWriteToSavedPhotosAlbum(canvasView.toImage(),self, #selector(PhotoEditorViewController.image(_:withPotentialError:contextInfo:)), nil)
           
       } else {
           // Call function to convert and save video
           let CIfilterName = "CIPhotoEffectInstant"
           convertVideoToMP4(videoURL!, filterName: CIfilterName)
           print("FILTER FOR VIDEO: \(CIfilterName)")
           
           convertVideoAndSaveTophotoLibrary(videoURL: frames[selectedFrame])
       }
    }

    @IBAction func clearButtonTapped(_ sender: AnyObject) {
       //clear drawing
       //clear stickers and textviews
       if frames.count > 1 {
           let imageView = tempImageViews[selectedFrame]
           imageView.image = nil
           
           if imageView.subviews.count > 0 {
               let lastSubView = imageView.subviews.last
               lastSubView?.removeFromSuperview()
           }
       } else {
           tempImageView.image = nil
           
           if tempImageView.subviews.count > 0 {
               let lastSubView = tempImageView.subviews.last
               lastSubView?.removeFromSuperview()
           }
       }
    }

    @IBAction func doneButtonTapped(_ sender: Any?) {
       view.endEditing(true)
       doneButton.isHidden = true
       btnBrushEraser.isHidden = true
       btnBrushPen.isHidden = true
       colorPickerView.isHidden = true
       horizontalColorPicker.isHidden = true
       widthSlider.isHidden = true
       tempImageView.isUserInteractionEnabled = true
       isPen = true
       if tempImageViews.count > 0 {
           tempImageViews[selectedFrame].isUserInteractionEnabled = true
       }
       
       hideToolbar(hide: false)
       
       isDrawing = false
       isErasing = false
       
       framesView.isHidden = false
       if #available(iOS 13.0, *) {
           isModalInPresentation = false
       } else {
           // Fallback on earlier versions
       }
        
        if selected_user != nil {
            
            self.taggedUserId = "\(selected_user?.userID ?? 0)"
            
            if self.btnTag.titleColor(for: .normal) == .white {
                self.btnTag.setTitleColor(.red, for: .normal)
            }
            
            clearButtonTapped(UIButton())
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        photoEditorDelegate?.editorCanceled()
        player?.pause()
        NotificationCenter.default.post(name: .photoEditViewDisable, object: self)
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addBottomSheetView()
    }
    
    @IBAction func hashtagButtonTapped(_ sender: Any) {

        let hashTagTextField = UITextField(frame: CGRect(x: 0, y: tempImageView.center.y,
                                                     width: UIScreen.main.bounds.width, height: 50))
        lastHashTagTextFieldY = tempImageView.center.y
        //Text Attributes
        hashTagTextField.textAlignment = .center
        hashTagTextField.font = UIFont(name: "Helvetica", size: 35)
        hashTagTextField.placeholder = "#"
        hashTagTextField.textColor = drawColor
        hashTagTextField.layer.shadowColor = UIColor.black.cgColor
        hashTagTextField.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        hashTagTextField.layer.shadowOpacity = 0.2
        hashTagTextField.layer.shadowRadius = 1.0
        hashTagTextField.layer.backgroundColor = UIColor.clear.cgColor
        hashTagTextField.delegate = self
        hashTagTextField.autocorrectionType = .no
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.addSubview(hashTagTextField)
        } else {
            self.tempImageView.addSubview(hashTagTextField)
        }
        addGestures(view: hashTagTextField)
        addPanGuesture(view: hashTagTextField)
        hashTagTextField.becomeFirstResponder()
        
        framesView.isHidden = true
    }
    
    @IBAction func textButtonTapped(_ sender: Any?) {
        
        let textView = UITextView(frame: CGRect(x: 0, y: tempImageView.center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        //Text Attributes
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 40)
        textView.textColor = textColor
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        //textView.translatesAutoresizingMaskIntoConstraints = true
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.addSubview(textView)
        } else {
            self.tempImageView.addSubview(textView)
        }
        
        addGestures(view: textView)
        addPanGuesture(view: textView)
        textView.becomeFirstResponder()
        
        framesView.isHidden = true
    }
    
    @IBAction func eraserButtonTapped(_ sender: Any) {
        isDrawing = false
        isErasing = true
        isPen = false
        tempImageView.isUserInteractionEnabled = false
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = false
        }
        doneButton.isHidden = false
        colorPickerView.isHidden = true
        horizontalColorPicker.isHidden = true
        widthSlider.isHidden = false
        hideToolbar(hide: true)
    }
    
    @IBAction func brushPencilTapped(_ sender: Any) {
        
        isDrawing = true
        isErasing = false
        tempImageView.isUserInteractionEnabled = false
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = false
        }
        doneButton.isHidden = false
        colorPickerView.isHidden = true
        horizontalColorPicker.isHidden = false
        widthSlider.isHidden = false
        framesView.isHidden = true
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func pencilButtonTapped(_ sender: Any) {

        isDrawing = true
        isErasing = false
        tempImageView.isUserInteractionEnabled = true
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = false
        }
        isPen = true
        doneButton.isHidden = false
        btnBrushEraser.isHidden = false
        btnBrushPen.isHidden = false
        colorPickerView.isHidden = true
        horizontalColorPicker.isHidden = false
        widthSlider.isHidden = false
        hideToolbar(hide: true)
        
        framesView.isHidden = true

        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func continueButtonPressed(_ sender: Any) {
        continueBtn.isEnabled = false
       if checkVideoOrIamge {
           self.saveImage()
       }else {
           selectedFrame = 0
           saveVideo(videoURLs: frames)
       }
       
    }
//    imageView
//--- Crop Image
    @IBAction func cropButtonPressed(_ sender: Any) {
        guard let image = self.imageView.image else{return}
        presentCropViewController(image)
    }
    
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        let  cropViewController = CropViewController(croppingStyle: .default, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
//-- End Crop Image
    func addBottomSheetView() {
        bottomSheetIsVisible = true
        hideToolbar(hide: true)
        self.tempImageView.isUserInteractionEnabled = false
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = false
        }
        bottomSheetVC.stickerDelegate = self
        
        for image in self.stickers {
            bottomSheetVC.stickers.append(image)
        }
        
       
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeBottomSheetView() {
        bottomSheetIsVisible = false
        self.tempImageView.isUserInteractionEnabled = true
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = true
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.bottomSheetVC.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.bottomSheetVC.view.frame = frame
                        
        }, completion: { (finished) -> Void in
            self.bottomSheetVC.view.removeFromSuperview()
            self.bottomSheetVC.removeFromParent()
            self.hideToolbar(hide: false)
        })
    }
    
    func hideToolbar(hide: Bool) {
        topToolbar.isHidden = hide
        bottomToolbar.isHidden = hide
     
    }
    
    func addWatermark(outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let mixComposition = AVMutableComposition()
        print("hi")
        let asset = AVAsset(url: outputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        
        var img: UIImageView
        if frames.count > 1 {
            img = tempImageViews[selectedFrame]
        } else {
            img = self.tempImageView
        }
        
        let watermarkImage = CIImage(image:img.toImage())
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage.clampedToExtent()
            watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
            let transform = CGAffineTransform(translationX: filteringRequest.sourceImage.extent.width - (watermarkImage?.extent.width)! - 2, y: 0)
            watermarkFilter.setValue(watermarkImage?.transformed(by: transform), forKey: "inputImage")
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
            if exportSession.status == .completed {
                let outputURL: URL? = exportSession.outputURL
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { saved, error in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            DispatchQueue.main.async(execute: {
                                print(newObj.url.absoluteString)
                            })
                        })
                        print (fetchResult!)
                    }
                }
            }
        }
    }
        
    private func getImageLayer(height: CGFloat) -> CALayer {
        let imglogo = UIImage(named: "bird_1.png")
        
        let imglayer = CALayer()
        imglayer.contents = imglogo?.cgImage
        imglayer.frame = CGRect(
            x: 0, y: height - imglogo!.size.height/4,
            width: imglogo!.size.width/4, height: imglogo!.size.height/4)
        imglayer.opacity = 0.6
        
        return imglayer
    }
    
    

    
    func convertVideoToMP4(_ vURL:URL, filterName:String)  {
        let videoAsset = AVURLAsset(url: videoURL!)
        // Apply Filter to Video
        var videoComposition = AVMutableVideoComposition()
        if filterName != "None" {
            let filter = CIFilter(name: filterName)!
            videoComposition = AVMutableVideoComposition(asset: videoAsset) { (request) in
                let source = request.sourceImage.clampedToExtent()
                filter.setValue(source, forKey: kCIInputImageKey)
                _ = CMTimeGetSeconds(request.compositionTime)
                let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
                request.finish(with: output, context: nil)
                print("OUTPUT CIIMAGE FILTERED: \(output.description)")
            }
        }
        
        exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
        deleteFile(filePath: filePath as NSURL)
        // Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }
        exportSession!.outputURL = filePath
        
        if filterName != "None" { exportSession.videoComposition = videoComposition }
        
        exportSession!.outputFileType = .mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: videoAsset.duration)
        exportSession?.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch self.exportSession!.status {
            case .failed:
                print("ERROR ON CONVERSION TO MP4: \(self.exportSession!.error!.localizedDescription)")
            case .cancelled:
                print("Export canceled")
            case .completed:
                
                DispatchQueue.main.async {
                    if self.exportSession.status == .completed {
                        let outputURL: URL? = self.exportSession.outputURL
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                        }) { saved, error in
                            if saved {
                                let fetchOptions = PHFetchOptions()
                                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                                PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                                    let newObj = avurlAsset as! AVURLAsset
                                    print(newObj.url)
                                    DispatchQueue.main.async(execute: {
                                        print(newObj.url.absoluteString)
                                    })
                                })
                                print (fetchResult!)
                            }
                        }
                    }
                }
                
            default: break
            }
        })
    }
    
//    // Mark :- save a video photoLibrary
    func convertVideoAndSaveTophotoLibrary(videoURL: URL) {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory2.appendingPathComponent("video.mp4")
        deleteFile(filePath: filePath as NSURL)

        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }

        // File to composit
        let asset = AVURLAsset(url: videoURL as URL)
        let composition = AVMutableComposition()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]

        // Rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)

        let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform

        //fix orientation
        
        var isVideoAssetPortrait_  = false
        
        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
            // false
        }
        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
            // false
        }
        
   
        transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
        transformer.setOpacity(0.0, at: asset.duration)
        
        //adjust the render size if neccessary
        var naturalSize: CGSize
        if(isVideoAssetPortrait_){
            naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
        } else {
            naturalSize = clipVideoTrack.naturalSize;
        }
        
        var renderWidth: CGFloat!
        var renderHeight: CGFloat!

        renderWidth = naturalSize.width
        renderHeight = naturalSize.height

        let parentlayer = CALayer()
        let videoLayer = CALayer()
        let watermarkLayer = CALayer()


        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
        
        var img: UIImageView
        img = tempImageViews[selectedFrame]
        
//        if frames.count > 1 {
//            img = tempImageViews[selectedFrame]
//        } else {
//            img = self.tempImageView
//        }
        
        watermarkLayer.contents = img.asImage().cgImage

       
        parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        videoLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)

        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)

        // Add watermark to video
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))


        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]

//        // audio
//        guard let firstAudioTrack = composition.addMutableTrack(withMediaType: .audio,
//                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
//
//        do {
//            try firstAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration),
//                                                of: asset.tracks(withMediaType: .audio)[0],
//                                                at: CMTime.zero)
//        } catch {
//            print("Failed to load first track")
//            return
//        }
        
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = AVFileType.mov
        exporter?.outputURL = filePath
        exporter?.videoComposition = videoComposition
        exporter?.shouldOptimizeForNetworkUse = true
        
        exporter!.exportAsynchronously(completionHandler: {() -> Void in
            if exporter?.status == .completed {
                let outputURL: URL? = exporter?.outputURL
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
                }) { saved, error in
                    if saved {
                        let fetchOptions = PHFetchOptions()
                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                        PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                            let newObj = avurlAsset as! AVURLAsset
                            print(newObj.url)
                            DispatchQueue.main.async(execute: {
                                print(newObj.url.absoluteString)
                            })
                        })
                        print (fetchResult!)
                    }
                }
            } else if exporter?.status == .failed {
                print (exporter?.error?.localizedDescription)
            }
        })
    }
    // delete the previous file
    func deleteFile(filePath:NSURL) {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        do { try FileManager.default.removeItem(atPath: filePath.path!)
        } catch { fatalError("Unable to delete file: \(error)") }
    }
   
    func saveImage() {
  
        print ("continue")
        player?.pause()
        let image = canvasView!.asImage()//.resized(withPercentage: 0.5)!
        photoEditorDelegate?.imageEdited(image: image, hashtag: self.hashtag, link: attachedLinks[0], linkRect: attachedLinkPos[0], angle: attachedLinkPosAngle[0], taggedUserId: [self.taggedUserId], sender: self)
    }
    
    func saveVideo(videoURLs: [URL]) {
        print ("continue selectedFrame = \(selectedFrame)")
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp\(finalFrames.count).mp4").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)

        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL

        let filePath = documentsDirectory2.appendingPathComponent("video\(finalFrames.count).mp4")
        deleteFile(filePath: filePath as NSURL)
        print(filePath)
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do { try FileManager.default.removeItem(atPath: myDocumentPath)
            } catch let error { print(error) }
        }

        // File to composit
        let asset = AVURLAsset(url: videoURLs.first!)
        let composition = AVMutableComposition.init()
        composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let clipVideoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        // Rotate to potrait
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let videoTransform:CGAffineTransform = clipVideoTrack.preferredTransform
        //fix orientation
        var videoAssetOrientation_  = UIImage.Orientation.up
        
        var isVideoAssetPortrait_  = false
        
        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ = UIImage.Orientation.right
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
            videoAssetOrientation_ =  UIImage.Orientation.left
            isVideoAssetPortrait_ = true
        }
        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
            videoAssetOrientation_ =  UIImage.Orientation.up
        }
        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
            videoAssetOrientation_ = UIImage.Orientation.down;
        }
        
        transformer.setTransform(clipVideoTrack.preferredTransform, at: CMTime.zero)
        transformer.setOpacity(0.0, at: asset.duration)

        //adjust the render size if neccessary
        var naturalSize: CGSize
        if(isVideoAssetPortrait_){
            naturalSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
        } else {
            naturalSize = clipVideoTrack.naturalSize;
        }
        
        var renderWidth: CGFloat!
        var renderHeight: CGFloat!
        
        renderWidth = naturalSize.width
        renderHeight = naturalSize.height
        
        let parentlayer = CALayer()
        let videoLayer = CALayer()
        let watermarkLayer = CALayer()
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: renderWidth, height: renderHeight)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderScale = 1.0
 
        for index in 0...tempImageViews.count - 1 {
            let imgView = tempImageViews[index]
            if selectedFrame == index {
                imgView.isHidden = false
            } else {
                imgView.isHidden = true
            }
        }
        var img: UIImageView
        img = tempImageViews[selectedFrame]
        let wimg = img.asImage().cgImage
        
        watermarkLayer.contents = img.asImage().cgImage
        parentlayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        videoLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        watermarkLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: naturalSize)
        
        parentlayer.addSublayer(videoLayer)
        parentlayer.addSublayer(watermarkLayer)
        // Add watermark to video
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentlayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMakeWithSeconds(60, preferredTimescale: 30))
        
        
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
  
   //--------------Video converter from .MOV to .MP4]
        let startDate = Date()
        let videoAsset = AVURLAsset(url: videoURL!)

        // Apply Filter to Video
        let CIfilterName1 = "CIPhotoEffectInstant"
        var videoComposition1 = AVMutableVideoComposition()

        let filter = CIFilter(name: CIfilterName1)!
        videoComposition1 = AVMutableVideoComposition(asset: videoAsset) { (request) in
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            _ = CMTimeGetSeconds(request.compositionTime)
            let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
            request.finish(with: output, context: nil)
            print("OUTPUT CIIMAGE FILTERED: \(output.description)")
        }

         guard let exporter  = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)else {
             print("can't")
             return
         }
        exporter.outputURL = filePath
        exporter.videoComposition = videoComposition
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: videoAsset.duration)
        exporter.timeRange = range
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        exporter.exportAsynchronously(completionHandler: {() -> Void in
            switch exporter.status {
            case .failed:
                print(exporter.error ?? "NO ERROR")
                return
            case .cancelled:
                print("Export canceled")
                return
            case .completed:
                //Video conversion finished
               let endDate = Date()
               let time = endDate.timeIntervalSince(startDate)
               let outputURL: URL = exporter.outputURL!
               if self.frames.count > 0 {
                    self.frames.remove(at: 0)
               }
               
               self.finalFrames.append(outputURL)
               
               if self.frames.count > self.selectedFrame + 1 {
                   DispatchQueue.main.async {
                       self.selectedFrame += 1
                       self.saveVideo(videoURLs: self.frames)
                   }
               }
               self.player?.pause()
//               if self.player != nil {
//                  self.player?.pause()
                  self.player = nil
//               }
               default: break
            }
        })
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(self.frames.count * 20)){
            self.photoEditorDelegate?.videoEdited(videoUrls: self.finalFrames, hashtag: self.hashtag , link: self.attachedLinks, linkRect: self.attachedLinkPos, angle: self.attachedLinkPosAngle, taggedUserId: [self.taggedUserId], sender: self)
            
            Utils.hideSpinner()
//            photoEditorDelegate?.imageEdited(image: canvasView!.asImage(), hashtag: self.hashtag, link: attachedLinks[0], linkRect: attachedLinkPos[0], angle: attachedLinkPosAngle[0], sender: self)
        }
            
        }
}

extension PhotoEditorViewController: ColorDelegate {
    func chosedColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        } else {
            if activeTextField != nil {
                activeTextField?.textColor = color
                textColor = color
            }
        }
    }
}

extension PhotoEditorViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let rotation = atan2(textView.transform.b, textView.transform.a)
        if rotation == 0 {
            print("text view did change")
            let oldFrame = textView.frame
            let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
            textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
        }
    }
    public func textViewDidBeginEditing(_ textView: UITextView) {
        lastTextViewTransform =  textView.transform
        lastTextViewTransCenter = textView.center
        lastTextViewFont = textView.font!
        activeTextView = textView
        
        textView.superview?.bringSubviewToFront(textView)
        textView.font = UIFont(name: "Helvetica", size: 40)
        
        
        let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                     height:CGFloat.greatestFiniteMagnitude))
        textView.bounds.size = CGSize(width: UIScreen.main.bounds.size.width,
                                      height: sizeToFit.height)
        textView.setNeedsDisplay()
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 5)
        }, completion: nil)
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        textView.font = self.lastTextViewFont!
        
        let oldFrame = textView.frame
        let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: textView.intrinsicContentSize.width, height: sizeToFit.height)
        
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }
    
}

extension PhotoEditorViewController: StickerDelegate {
    
    func viewTapped(view: UIView) {
        self.removeBottomSheetView()
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            view.center = imgView.center
            
            imgView.addSubview(view)
        } else {
            view.center = tempImageView.center
            
            self.tempImageView.addSubview(view)
        }
        
        //Gestures
        addGestures(view: view)
        addPanGuesture(view: view)
    }
    
    func imageTapped(image: UIImage) {
        self.removeBottomSheetView()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = tempImageView.center
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.addSubview(imageView)
        } else {
            self.tempImageView.addSubview(imageView)
        }
        
        //Gestures
        addGestures(view: imageView)
        addPanGuesture(view: imageView)
    }
    
    func bottomSheetDidDisappear() {
        bottomSheetIsVisible = false
        hideToolbar(hide: false)
    }
    
    func addPanGuesture(view: UIView){
        view.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorViewController.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
//        let panGesture = UIPanGestureRecognizer(target: self,
//                                                action: #selector(PhotoEditorViewController.panGesture))
//        panGesture.minimumNumberOfTouches = 1
//        panGesture.maximumNumberOfTouches = 1
//        panGesture.delegate = self
//        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(PhotoEditorViewController.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(PhotoEditorViewController.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
}

extension PhotoEditorViewController {
    
    //Resources don't load in main bundle we have to register the font
    func registerFont(){
        let bundle = Bundle(for: PhotoEditorViewController.self)
        let url =  bundle.url(forResource: "Eventtus-Icons", withExtension: "ttf")
        
        guard let fontDataProvider = CGDataProvider(url: url! as CFURL) else {
            return
        }
        let font = CGFont(fontDataProvider)
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font!, &error) else {
            return
        }
    }
}


extension PhotoEditorViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField != linkTextField {
            if textField.text == "" {
                textField.text = "#"
                
                lastHashTagTextFieldY = textField.center.y
            }
            
            UIView.animate(withDuration: 0.3,
                           animations: {
                            textField.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
            }, completion: nil)
        }
        
        activeTextField = textField
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField != linkTextField {
            let str : String = (activeTextField?.text)!
            self.hashtag = str.deletingPrefix("#")
        }
        activeTextField = nil
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textField.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        }, completion: nil)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.text == "#" && string == "" {
            return false
        }
        
        return true
    }
}

extension PhotoEditorViewController: LinkAttachDelegate {
    func selectedLink(string: String?, selectedFrame: Int) {
        doneButton.isHidden = true
        colorPickerView.isHidden = true
        horizontalColorPicker.isHidden = true
        widthSlider.isHidden = true
        tempImageView.isUserInteractionEnabled = true
        if tempImageViews.count > 0 {
            tempImageViews[selectedFrame].isUserInteractionEnabled = true
        }
        hideToolbar(hide: false)
        
        guard let link = string else {return}
        attachedLinks[selectedFrame] = link
        
        let linkLabel = ActiveLabel(frame: CGRect(x: 0, y: doneButton.center.y + 20, width: view.frame.size.width, height: 40))
        
        if frames.count > 1 {
            let imgView = tempImageViews[selectedFrame]
            imgView.addSubview(linkLabel)
        } else {
            self.tempImageView.addSubview(linkLabel)
        }
        
        addGestures(view: linkLabel)
        addPanGuesture(view: linkLabel)
        
        linkLabel.customize { (label) in
            label.text = link
            
//            label.sizeToFit()

            self.attachedLinkPos[selectedFrame] = linkLabel.frame

            label.textColor = UIColor.white
            label.URLColor = UIColor.white
            label.URLSelectedColor = UIColor.white
            
            label.enabledTypes = [.url]
            
            label.handleURLTap({ (url) in
                if !url.absoluteString.hasPrefix("http") {
                    let urlString = "https://\(url.absoluteString)"
                    Utils.openURL(urlString)
                } else {
                    Utils.openURL(url.absoluteString)
                }
                
            })
            
            label.textAlignment = .center
            
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
    }
}

extension PhotoEditorViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return frames.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoFrameCell", for: indexPath) as! VideoFrameCell
        
        let frameURL = frames[indexPath.row]
        
        cell.imgFrame.image = Utils.getThumbnailFrom(path: frameURL)
        
        cell.imgFrame.layer.cornerRadius = 3
        cell.imgFrame.clipsToBounds = true
        
        if indexPath.row == selectedFrame {
            cell.isCurrentFrame = true
        } else {
            cell.isCurrentFrame = false
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 30, height: collectionView.frame.size.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if selectedFrame == indexPath.row {
            return
        }
        
        selectedFrame = indexPath.row
        framesView.reloadData()
        
        playVideo()
        
        player?.play()
    }
    
    // Observe ColorSlider .valueChanged events.
    @objc func changedColor(slider: ColorSlider) {
        if isDrawing {
            self.drawColor = slider.color
        } else if activeTextView != nil {
            activeTextView?.textColor = slider.color
            textColor = slider.color
        } else {
            if activeTextField != nil {
                activeTextField?.textColor = slider.color
                textColor = slider.color
            }
        }
        
        self.colorsCollectionViewDelegate.chosenColor = slider.color
        self.colorsCollectionView.reloadData()
    }
}

extension PhotoEditorViewController: SwiftlySliderDelegate {
    public func swiftlySliderValueChanged(_ value: Int) {
        penWidth = value
    }
    
    public func dragBegan() {
        lblPenWidthFloat.text = "\(penWidth)"
        lblPenWidthFloat.isHidden = false
    }
    
    public func dragEnd() {
        lblPenWidthFloat.text = "\(penWidth)"
        lblPenWidthFloat.isHidden = true
    }
    
    public func dragMove() {
        lblPenWidthFloat.text = "\(penWidth)"
        lblPenWidthFloat.isHidden = false
    }
}
extension Notification.Name {
    static let photoEditViewEnable
        = Notification.Name("PhotoEditViewEnable")
    static let photoEditViewDisable = Notification.Name("PhotoEditViewDisable")
}

extension PhotoEditorViewController :  CropViewControllerDelegate {
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

