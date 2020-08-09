//
//  FeedViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import CRRefresh
import SwiftyJSON

class FeedViewController: EmbeddedViewController {

    @IBOutlet weak var gridLayout: GridLayout!
    @IBOutlet weak var feedIntroIV: UIImageView!
    @IBOutlet weak var clvProfile: UICollectionView!
    @IBOutlet weak var clvPost: UICollectionView!
    @IBOutlet weak var btnCloseTutor: UIButton!
    
    var arrInstaBigCells = [Int]()
    var storys = [Media]()
    var posts = [Media]()
    var sortedPosts = [[Media]]() // sorted by created date
    
    var todayUserPosts = [Media]() // posted in last 24 hours by current user
    
    let interactor = Interactor()
    let transition = CATransition()
    
    var broadcastCount : Int = 0 // for radio broadcasting
    var profileIconFullPath : String = ""
    var radioObjArray = [Int: RadioStation]()
    var profileIconPathArray = [Int: String]()
    
    //-----Added for Tabs
    
    //-------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        broadcastCount = 0
        radioObjArray.removeAll()
        profileIconPathArray.removeAll()
        
        arrInstaBigCells.append(0)
        var tempStorage = false
        for _ in 1...21 {
            if(tempStorage){
                arrInstaBigCells.append(arrInstaBigCells.last! + 3)
            } else {
                arrInstaBigCells.append(arrInstaBigCells.last! + 7)
            }
            tempStorage = !tempStorage
        }
        
        clvPost.backgroundColor = .clear
        clvPost.dataSource = self
        clvPost.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        clvPost.contentOffset = CGPoint(x: -10, y: -10)
        
        gridLayout.delegate = self
        gridLayout.itemSpacing = 2
        gridLayout.fixedDivisionCount = 4
        
//        getFeeds()
        
        clvPost.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
            self.getFeeds()
        }
//        getFollowers()
        clvProfile.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
//            self.getFeeds()
            self.getFilteredStories()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMediaPosted(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.NEW_MEDIA_POSTED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newMediaPosted(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_POSTS_LOADED), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(storyViewUpdated(_:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_STORY_VIEWED_UPDATED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userPhotoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_PHOTO_UPDATED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getRadioStationIdOnBroadCasting(notification:)), name: .radioIsOnBroadcastingToFeedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reportedPost(notification:)),
            name: .reportedPostSuccessfully, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileIconFullPath  = ""
        feedIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
        let feedShown = UserDefaults.standard.bool(forKey: "feedShown")
        if !feedShown {
            feedIntroIV.alpha = 1.0
            btnCloseTutor.alpha = 1.0
            UserDefaults.standard.set(true, forKey: "feedShown")
            btnCloseTutor.isEnabled = true
        }
    }
    @objc func openTutor(notification: Notification){
        feedIntroIV.alpha = 1.0
        btnCloseTutor.alpha = 1.0
        UserDefaults.standard.set(true, forKey: "feedShown")
        btnCloseTutor.isEnabled = true
    }
    @objc func closeTutor(notification: Notification){
        feedIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    @objc func getRadioStationIdOnBroadCasting( notification: Notification){
        let userInfo = notification.userInfo
        broadcastCount = 1
        radioObjArray[broadcastCount] = userInfo!["radioObj"] as? RadioStation
        profileIconPathArray[broadcastCount] = userInfo!["profileIconPath"] as? String
        DispatchQueue.main.async {

            self.clvProfile.reloadData()
        }
    }
    @objc func reportedPost(notification: Notification){
        getFilteredStories()
        getFeeds()
    }
    @objc func newMediaPosted(notification: Notification) {
        getFilteredStories()
        getFeeds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getFilteredStories()
        getFeeds()
    }

    func getFilteredStories(){
        DispatchQueue.main.async {
            if self.posts.count == 0 {
//                Utils.showSpinner()
            }
        }
        
        NetworkManager.shared.getFilteredStories { (response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.clvProfile.cr.endHeaderRefresh()
            })
            DispatchQueue.main.async {
                Utils.hideSpinner()

                switch response {
                                        
                case .error(let error):
                    print(error.localizedDescription)
                    
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let json = jsonRes as? [String: Any]{
                            if let feedItems = json["filtered_feeds"] as? [NSDictionary]{
                                print(feedItems.count)
                                
                                self.storys.removeAll()
                                self.sortedPosts.removeAll()
                                self.todayUserPosts.removeAll()
                                for feed in feedItems {
                                    let post = Media(json: feed as! [String : Any])
                                    var bAdded: Bool = false
                                    for existingPost in self.storys {
                                         if post.id == existingPost.id {
                                             bAdded = true
                                             break
                                         }
                                    }
                                    if !bAdded {
                                        self.storys.append(post)
                                    }
                                                                 
                                }
                                for story in self.storys {
                                    var isAdded: Bool = false
                                    for sortedPostIdx in 0..<self.sortedPosts.count {
                                        if self.sortedPosts[sortedPostIdx].first?.userId == story.userId {
                                            self.sortedPosts[sortedPostIdx].append(story)
                                            isAdded = true
                                            break
                                        }
                                    }
                                    
                                    if !isAdded {
                                        self.sortedPosts.append([story])
                                    }
                                }
                                var userIdx = -1
                                for postIdx in 0..<self.sortedPosts.count {
                                    if self.sortedPosts[postIdx].first?.userId == UserManager.currentUser()?.userID {
                                        userIdx = postIdx
                                        self.todayUserPosts = self.sortedPosts[postIdx]
                                        break
                                    }
                                }
                                if userIdx != -1 {
                                    self.sortedPosts.remove(at: userIdx)
                                }

                                self.clvProfile.reloadData()
//                                self.clvPost.reloadData()
                            }
                        }
                    } catch {
                    }
                }// end --- switch response
            }//end :DispatchQueue.main.async
        }
    }
    func getFeeds() {
        DispatchQueue.main.async {
            if self.posts.count == 0 {
//                Utils.showSpinner()
            }
        }
        NetworkManager.shared.getFeeds { (response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.clvPost.cr.endHeaderRefresh()
            })
            DispatchQueue.main.async {
                Utils.hideSpinner()

                switch response {
                                        
                case .error(let error):
                    print(error.localizedDescription)
                    
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let json = jsonRes as? [String: Any]{
                            if let feedItems = json["popular_feeds"] as? [NSDictionary]{
                                print(feedItems.count)
                                self.posts.removeAll()
                                for feed in feedItems {
                                     let post = Media(json: feed as! [String : Any])
                                     var bAdded: Bool = false
                                     for existingPost in self.posts {
                                         if post.id == existingPost.id {
                                             bAdded = true
                                             break
                                         }
                                     }
                                     if !bAdded {
                                         self.posts.append(post)
                                     }
                                }
                                self.clvPost.reloadData()
                            }
                        }
                    } catch {
                    }
                }// end --- switch response
            }//end :DispatchQueue.main.async
        }
    }
    @objc func userPhotoUpdated(notification: Notification) {
                
        DispatchQueue.main.async {
            self.clvProfile.reloadData()
        }
    }
    @objc func storyViewUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.clvProfile.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
}
extension FeedViewController: UIViewControllerTransitioningDelegate{
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
extension FeedViewController: GridLayoutDelegate{
    // MARK: - PrimeGridDelegate
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if(arrInstaBigCells.contains(indexPath.row)){
            return 2
        } else {
            return 1
        }
    }
    
    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return fixedDimension
    }
}
extension FeedViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.clvProfile {
            return self.sortedPosts.count + 1 + broadcastCount
        }
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.clvPost {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! ProfilePostCell
            
            let post = posts[indexPath.row]
            
            if post.type == 1 {
                cell.imgVideoMark.isHidden = false
                
                cell.imgPost.sd_setImage(with: URL(string: Utils.getFullPath(path: post.thumbnail ?? "")), placeholderImage: PLACEHOLDER_VIDEO, options: .lowPriority, completed: nil)
            } else {
                cell.imgVideoMark.isHidden = true
                
                cell.imgPost.sd_setImage(with: URL(string: Utils.getFullPath(path: post.path!)), placeholderImage: PLACEHOLDER_PHOTO, options: .lowPriority, completed: nil)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! FeedProfileCell
            
            if indexPath.row == 0 { // your story cell
                
                cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: UserManager.currentUser()?.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                
                cell.lblName.text = "Your Story"//UserManager.currentUser()?.username ?? ""
                
                if todayUserPosts.count > 0 {
                    cell.imgPoster.isHidden = true
                    if todayUserPosts.first?.isSeen == false {
                        cell.borderView.setupGradientLayer(borderColors: nil, borderWidth: nil)
                    } else {
                        cell.borderView.setupGradientLayer(borderColors: [UIColor.clear.cgColor], borderWidth: 2)
                    }
                }else{
                    cell.imgPoster.isHidden = false
                    cell.imgPoster.image = UIImage(named: "story_add")

                    cell.borderView.setupGradientLayer(borderColors: [UIColor.clear.cgColor], borderWidth: 2)
                }
            } else if((indexPath.row == 1) && (broadcastCount != 0) ){
                cell.imgProfile.sd_setImage(with: URL(string: profileIconFullPath), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                cell.imgProfile.contentMode = .scaleAspectFill
                cell.lblName.text = "Live Stream"
           } else {
                cell.imgPoster.isHidden = false
                
                let post = sortedPosts[indexPath.row - 1 - broadcastCount].first!
                
                if post.type == 1 {
                    cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: post.thumbnail ?? "")), placeholderImage: PLACEHOLDER_VIDEO, options: .lowPriority, completed: nil)
                } else {
                    cell.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: post.path!)), placeholderImage: PLACEHOLDER_PHOTO, options: .lowPriority, completed: nil)
                }
                
                cell.imgProfile.contentMode = .scaleAspectFill
                
                cell.lblName.text = post.username
                
                if let userPhoto = post.userPhoto {
                    let fullPhotoPath = Utils.getFullPath(path: userPhoto)
                    
                    if let url = URL(string: fullPhotoPath) {
                        cell.imgPoster.sd_setImage(with: url, placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
                    } else {
                        cell.imgPoster.image = PLACEHOLDER_IMG
                    }
                } else {
                    cell.imgPoster.image = PLACEHOLDER_IMG
                }
                
                if sortedPosts[indexPath.row - 1 - broadcastCount].first!.isSeen == false {
                   cell.borderView.setupGradientLayer(borderColors: nil, borderWidth: nil)
                } else {
                    cell.borderView.setupGradientLayer(borderColors: [UIColor.clear.cgColor], borderWidth: 2)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.clvProfile {
            return CGSize(width: 85, height: 100)
        }
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView == self.clvProfile && indexPath.row == 0 {
            if todayUserPosts.count == 0 {
                self.delegate?.onShowContainer(position: .Center, sender: self)
                return
            }
        }
        if collectionView == self.clvProfile && indexPath.row < 2 && broadcastCount != 0{
            let radioDetailVC = UIViewController.viewControllerWith("RadioDetailsVC") as! RadioDetailsViewController
            radioDetailVC.radio = radioObjArray[indexPath.row]
            transition(to: radioDetailVC)
            return
        }
        if collectionView == self.clvPost {
            let playVC = UIViewController.viewControllerWith("playvc") as! PlayViewController
            
            playVC.transitioningDelegate = self
            playVC.interactor = interactor

            playVC.medias = posts
            
            playVC.currentIndex = indexPath.row
            
            playVC.viewFromFeed = true
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": false])
            
            transition(to: playVC)

        } else {
            if indexPath.row == 0 {
                let storyPlayVC = UIViewController.viewControllerWith("StoryPlayVC") as! StoryPlayVC
                storyPlayVC.isFromFeedView = true
                storyPlayVC.rowIndex = -1
                storyPlayVC.medias = todayUserPosts
                storyPlayVC.transitioningDelegate = self
                storyPlayVC.interactor = interactor
                todayUserPosts.first?.isSeen = true
                storyPlayVC.sortedMedias = sortedPosts
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": false])
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_STORY_VIEWED_UPDATED),
                                                object: nil, userInfo: nil)

                transition(to: storyPlayVC)
            } else {
                
                let storyPlayVC = UIViewController.viewControllerWith("StoryPlayVC") as! StoryPlayVC
                if collectionView == self.clvProfile && indexPath.row < 2 && broadcastCount != 0{
                     storyPlayVC.medias = sortedPosts[indexPath.row]
                     storyPlayVC.rowIndex = 0
                }else{
                     storyPlayVC.medias = sortedPosts[indexPath.row - 1]
                     storyPlayVC.rowIndex = indexPath.row - 1
                }
                storyPlayVC.isFromFeedView = true
                storyPlayVC.sortedMedias = sortedPosts
                storyPlayVC.transitioningDelegate = self
                storyPlayVC.interactor = interactor
                
                sortedPosts[indexPath.row - 1].first?.isSeen = true

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil, userInfo: ["visible": false])
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_STORY_VIEWED_UPDATED),
                                                object: nil, userInfo: nil)
                transition(to: storyPlayVC)
            }
        }
    }
}
