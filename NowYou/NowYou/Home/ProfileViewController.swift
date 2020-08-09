//
//  ProfileViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.

//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import QuartzCore
import SDWebImage
import CRRefresh
import CropViewController

class ProfileViewController: EmbeddedViewController, UIViewControllerTransitioningDelegate {

    let interactor = Interactor()
    let transition = CATransition()
    
    @IBOutlet weak var profileIntroIV: UIImageView!
    @IBOutlet weak var clvPost: UICollectionView!
    @IBOutlet weak var clvTags: UICollectionView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnCloseTutor: UIButton!
    
    
    var selectedIndex: Int = 0
    
    var posts = [Media]()
    var needPhotoUpdate: Bool = false
    var firstAppear: Bool = true
    var todayUserPosts = [Media]()
    var profileImgTap: UITapGestureRecognizer!
    var imagePicker = UIImagePickerController()
    var imgProfile : UIImage!
    var selfPhotoUpdate : Bool!

    var followingTags = [Tag]()
    
    var cropViewController : CropViewController?
    static let shared = ProfileViewController()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
        let profileShown = UserDefaults.standard.bool(forKey: "profileShown")
        if !profileShown {
          profileIntroIV.alpha = 1.0
          btnCloseTutor.alpha = 1.0
          UserDefaults.standard.set(true, forKey: "profileShown")
          btnCloseTutor.isEnabled = true

        }
        //clvTags.isHidden = true
        selfPhotoUpdate = false
        lblUsername.text = UserManager.currentUser()?.username
        
        clvTags?.register(TagHeader.self, forSupplementaryViewOfKind:
            UICollectionView.elementKindSectionHeader, withReuseIdentifier: "tagHeaderId")
        clvTags.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        
        clvPost.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
            if self.selectedIndex == 0 {
                self.loadPosts()
            } else {
                self.loadTaggedPosts()
            }
            
        }
        clvTags.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
            self.getFollowingTags()
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFollowingTags()
        loadPosts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMediaPosted(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.NEW_MEDIA_POSTED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userPhotoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_PHOTO_UPDATED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_POSTS_LOADED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(storyViewUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_STORY_VIEWED_UPDATED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userFollowingUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_FOLLOWING_COUNT_UPDATED), object: nil)
        
        profileImgTap = UITapGestureRecognizer(target: self, action: #selector(profileImgTapped(_:)))
        profileImgTap.numberOfTapsRequired = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
    }
        
    @objc func openTutor(notification: Notification){
        UserDefaults.standard.set(false, forKey: "profileShown")
//        tutorShowProfileDelegate?.showTutorBoard()
    }
    @objc func closeTutor(notification: Notification){
        profileIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    @objc func profileImgTapped(_ gesture: UITapGestureRecognizer) {
        showPickerView()
    }
    
    @IBAction func allPostsTapped(_ sender: UIButton) {
        self.selectedIndex = 0
        self.loadPosts()
    }
    
    @IBAction func taggedPostsTapped(_ sender: UIButton) {
        self.selectedIndex = 1
        self.loadTaggedPosts()
    }
    
    
    
    @objc func storyViewUpdated(notification: Notification) {
        todayUserPosts.first?.isSeen = true
        
        DispatchQueue.main.async {
            self.clvPost.reloadData()
        }
    }
    @objc func userFollowingUpdated(notification: Notification) {
        getUserInfo()
    }
    
    @objc func newMediaPosted(notification: Notification) {
        loadPosts()
    }
    
    @objc func userInfoUpdated(notification: Notification) {
        needPhotoUpdate = false
        
        DispatchQueue.main.async {
            self.lblUsername.text = UserManager.currentUser()?.username

            self.clvPost.reloadData()
        }
    }
    
    @objc func userPhotoUpdated(notification: Notification) {
        if selfPhotoUpdate == false {
            needPhotoUpdate = true
            DispatchQueue.main.async {
               self.lblUsername.text = UserManager.currentUser()?.username
               self.clvPost.reloadData()
            }
        }else{
            self.clvPost.reloadData()
        }
    }
    
    func getFollowingTags(){

        DataBaseManager.shared.getFollowingHashTags(){(result,error) in
            DispatchQueue.main.async {
                self.clvTags.cr.endHeaderRefresh()
                if error == "" {
                    self.followingTags = result
                }else{
                    print(error)
                }
                self.clvTags.reloadData()
            }
        }
    }
    
    func loadPosts() {
        DispatchQueue.main.async {
            
        }
        NetworkManager.shared.getPosts { (response) in
        // Stop refresh when your job finished, it will reset refresh footer if completion is true
        DispatchQueue.main.async {
            Utils.hideSpinner()
            self.clvPost.cr.endHeaderRefresh()
            switch response {
            case .error(let error):
                print (error.localizedDescription)
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any], let postsArr = json["posts"] as? [[String: Any]] {
                        self.posts.removeAll()
                        self.todayUserPosts.removeAll()
                        
                        for feed in postsArr {
                            let post = Media(json: feed)
                            
                            if let _ = post.path {
                                self.posts.append(post)
                            }
                        }
                        
                        let sorted = self.posts.sorted(by: { (media1, media2) -> Bool in
                            return media1.created > media2.created
                        })
                        
                        self.posts = sorted
                        
                        for sortedPost in sorted {
                            if let diff = Calendar.current.dateComponents([.hour], from: sortedPost.created, to: Date()).hour, diff < 24 {
                                
                                self.todayUserPosts.append(sortedPost)
                            }
                        }
                        UserManager.setPosts(userPosts: self.posts)
                        self.clvPost.reloadData()
                    }
                } catch {
                    
                }
            }
            }
        }
    }
    
    func loadTaggedPosts() {
        DispatchQueue.main.async {
            
        }
        NetworkManager.shared.getPosts { (response) in
        // Stop refresh when your job finished, it will reset refresh footer if completion is true
        DispatchQueue.main.async {
            Utils.hideSpinner()
            self.clvPost.cr.endHeaderRefresh()
            switch response {
            case .error(let error):
                print (error.localizedDescription)
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any], let postsArr = json["posts"] as? [[String: Any]] {
                        self.posts.removeAll()
                        self.todayUserPosts.removeAll()
                        
                        for feed in postsArr {
                            let post = Media(json: feed)
                            
                            if let _ = post.path {
                                if post.taggedUserId?.contains("@") ?? false {
                                    self.posts.append(post)
                                }
                            }
                        }
                        
                        let sorted = self.posts.sorted(by: { (media1, media2) -> Bool in
                            return media1.created > media2.created
                        })
                        
                        self.posts = sorted
                        
                        for sortedPost in sorted {
                            if let diff = Calendar.current.dateComponents([.hour], from: sortedPost.created, to: Date()).hour, diff < 24 {
                                
                                self.todayUserPosts.append(sortedPost)
                            }
                        }
                        UserManager.setPosts(userPosts: self.posts)
                        self.clvPost.reloadData()
                    }
                } catch {
                    
                }
            }
            }
        }
    }
    

    @IBAction func onRadio(_ sender: Any) {
        self.delegate?.onShowContainer(position: .Top, sender: self)
    }
    
    @IBAction func onSettings(_ sender: Any) {
        let settingsVC = UIViewController.viewControllerWith("settingsVC") as! SettingsViewController
        
        settingsVC.transitioningDelegate = self
        settingsVC.interactor = interactor
        
        transitionNav(to: settingsVC)
    }
    
    // MARK: - Private
    func transitionNav(to controller: UIViewController) {
            transition.duration = 0.2

            if controller is SettingsViewController {
                transition.type = CATransitionType.fade
                transition.subtype = CATransitionSubtype.fromRight
            } else { // playviewcontroller
                transition.type = CATransitionType.reveal
                transition.subtype = CATransitionSubtype.fromTop
            }

            view.window?.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(controller, animated: false)
        }
    
    // MARK: - Animation
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
            if dismissed is SettingsViewController {
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
    
    @objc func onShowMore(sender: UIButton) {
        let index = sender.tag - 200
        
        let post = posts[index]
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            actionSheetController.modalPresentationStyle = .popover
        }
        
        let reportAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in

            NetworkManager.shared.removePosts(mediaId: post.id!, completion: { (response) in
                switch response {
                case .error(let error):
                    DispatchQueue.main.async {
                        self.navigationController?.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self.navigationController?.present(Alert.alertWithTextInfo(errorText: "Your post has been removed."), animated: true, completion: nil)
                        
                        self.posts.remove(at: index)
                        self.clvPost.reloadData()
                    }
                }
            })
        }
        
        reportAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        // add actions
        actionSheetController.addAction(reportAction)
        actionSheetController.addAction(cancelAction)
        
        if let popoverController = actionSheetController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
// change the profile photo
    func openCamera() {
       if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
           imagePicker.sourceType = UIImagePickerController.SourceType.camera
           self.present(imagePicker, animated: true, completion: nil)
       }
    }
       
    func openGallary() {
       imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
       self.present(imagePicker, animated: true, completion: nil)
    }
    func deleteProfileImg() {
        self.imgProfile = UIImage(named: "NY_default_avatar")
        self.selfPhotoUpdate = true
        updateProfile()
    }
    func showPickerView(){
        // show picker
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default)
           {
               UIAlertAction in
               self.deleteProfileImg()
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        // Add the actions
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
//--- Crop image
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController?.delegate = self
        self.present(cropViewController!, animated: true, completion: nil)
    }
//--- End Crop image
    func updateProfile() {
        // update profile info
        presentCropViewController(imgProfile)
    }
// change the profile photo
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        if collectionView == self.clvTags{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else{
            return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
                
        if collectionView == self.clvPost {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ProfileHeaderView
                   
               header.imgProfile.setCircular()
               
               header.imgProfile.isUserInteractionEnabled = true
               header.imgProfile.addGestureRecognizer(profileImgTap)
               
            
               let user = UserManager.currentUser()!
               if selfPhotoUpdate == false {
                   header.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto)), placeholderImage: PLACEHOLDER_IMG, options: .delayPlaceholder, completed: nil)
               } else {
                   header.imgProfile.image = self.imgProfile
                   
                   self.selfPhotoUpdate = false
               }
               
               header.lblViewCount.text        = "\(user.view_count_total)"
               header.lblFollowerCount.text    = "\(user.followers_count)"
               header.lblFollowingCount.text   = "\(user.followings_count)"
               header.lblName.text = user.fullname
               
                if self.selectedIndex == 0 {
                    header.lineAllPosts.backgroundColor = .systemRed
                    header.lineTaggedPosts.backgroundColor = .darkGray
                } else {
                    header.lineAllPosts.backgroundColor = .darkGray
                    header.lineTaggedPosts.backgroundColor = .systemRed
               }
            
            
               return header
        }else{
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
                "tagHeaderId", for: indexPath) as! TagHeader
            header.alpha = 0.0
            header.isHidden = true
            return header
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height * 0.22)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count:Int!
        if collectionView == self.clvPost{
            count = posts.count
        }else {
            count = followingTags.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.clvPost {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfilePostCell
            let post = posts[indexPath.row]
            if post.type == 0 { // photo
               cell.imgVideoMark.isHidden = true
               cell.imgPost.sd_setImage(with: URL(string: Utils.getFullPath(path: post.path!)), placeholderImage: PLACEHOLDER_PHOTO, options: .lowPriority, completed: nil)
            } else {
               cell.imgVideoMark.isHidden = false
               if let thumbnail = post.thumbnail {
                   cell.imgPost.sd_setImage(with: URL(string: Utils.getFullPath(path: thumbnail)), placeholderImage: PLACEHOLDER_VIDEO, options: .lowPriority, completed: nil)
                   
               } else {
                   cell.imgPost.image = PLACEHOLDER_VIDEO
               }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd"

            cell.lblDate.text = dateFormatter.string(from: post.created ?? Date())

            cell.btnMore.tag = indexPath.row + 200
            cell.btnMore.addTarget(self, action: #selector(onShowMore(sender:)), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileTagCell", for: indexPath) as! ProfileTagCell
            cell.lblTag.text = "#" +  followingTags[indexPath.row].name
            cell.container.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.6).cgColor
            cell.container.layer.borderWidth = 1.0
            cell.container.setRoundCorner(radius: 6    )
            collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .right], animated: true)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.clvPost {
            let width = collectionView.frame.size.width / 3
            return CGSize(width: width, height: width + 22)
        }else{
            let width = collectionView.frame.size.width / 5
            return CGSize(width: width, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if collectionView == self.clvPost {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": false])
            let playVC = UIViewController.viewControllerWith("PostPlayVC") as! PostPlayVC

            playVC.transitioningDelegate = self
            playVC.interactor = interactor

            playVC.medias = posts
            playVC.viewFromFeed = false
            playVC.currentIndex = indexPath.row
            playVC.viewFromProfile =  true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
               self.transitionNav(to: playVC)
            }
        }else{
            
        }
       
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        picker.dismiss(animated: false, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            self.imgProfile = pickedImage
        }
        self.selfPhotoUpdate = true
        updateProfile()
    }
}

//--- Crop image
extension ProfileViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgProfile = image
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let user = UserManager.currentUser()!
        let appColor = user.color
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.updateProfile(email: user.email, firstName: user.firstName, lastName: user.lastName, phone: user.phone, birthDay: user.birthday, photo: imgProfile.pngData()!, color: appColor, username: user.username, gender: user.gender, privateOn: 0, bio: "Senior mobile dev") { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                    break
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let jsonObject = jsonRes as? [String: AnyObject] {
                            if let userJSON = jsonObject["user"] as? [String: Any] {
                                print(userJSON)
                                let user = User(json: userJSON)
                                UserManager.updateUser(user: user)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_PHOTO_UPDATED), object: nil, userInfo: nil)

                            }
                        }
                        break
                    } catch {
                        self.present(Alert.alertWithTextInfo(errorText: "This email already been taken. Please use another email."), animated: true, completion: nil)
                        return
                    }
                }
            }
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
//--- End Crop image

extension ProfileViewController{
    open func getUserInfo(){
        NetworkManager.shared.getUserDetails(userId: (UserManager.currentUser()?.userID)!) { (response) in
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
                        let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
                        UserDefaults.standard.set(encodedUser, forKey: USER_INFO)
                        UserDefaults.standard.synchronize()
                        
                    }
                }
                DispatchQueue.main.async {
                    self.clvPost.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
                        self.loadPosts()
                    }
                    self.clvPost.cr.endHeaderRefresh()
                    self.clvPost.reloadData()
                    
                }
            } catch {
                
            }
        }
    }
    }
}
