//
//  OtherProfileViewController.swift
//  NowYou
//
//  Created by Apple on 2/22/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class OtherProfileViewController: UIViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var clv: UICollectionView!
    
    @IBOutlet weak var lblUsername: UILabel!
    
    
    var interactor = Interactor()
    var transition = CATransition()
    
    var user: SearchUser?
    var blockerTap: Bool!
    var isSelf: Bool = false
    var todayUserPosts = [Media]()
    var userPosts = [Media]()
    var profileImgTap: UITapGestureRecognizer!
    
    @IBOutlet weak var profileBorderView: AngleGradientBorderView!
    override func viewDidLoad() {
        super.viewDidLoad()

        lblUsername.text = user?.user?.username
        
        if let color = user?.user?.color {
            self.view.backgroundColor = UIColor(hexString: color)
        }
        
//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//        recognizer.delegate = self
//        view.addGestureRecognizer(recognizer)
        
        profileImgTap = UITapGestureRecognizer(target: self, action: #selector(profileImgTapped(_:)))
        profileImgTap.numberOfTapsRequired = 1
        
        let sorted = user!.posts.sorted(by: { (media1, media2) -> Bool in
            return media1.created > media2.created
        })
        
        if(!self.blockerTap) {
            self.userPosts = sorted
            
            for sortedPost in sorted {
                if let diff = Calendar.current.dateComponents([.hour], from: sortedPost.created, to: Date()).hour, diff < 24 {
                    
                    self.todayUserPosts.append(sortedPost)
                }
            }
        }
        
        
        DispatchQueue.main.async {
            self.clv.reloadData()
        }
        addRigthSwipe()
    }
     func addRigthSwipe(){
          let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
          rightSwipe.direction = .right
          view.addGestureRecognizer(rightSwipe)
      }
      @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
         if (sender.direction == .right) {
              navigationController?.popViewController(animated: true)
              print("Swipe right")
         }
      }
    @objc func profileImgTapped(_ gesture: UITapGestureRecognizer) {
        guard todayUserPosts.count > 0 else {
            return
        }
        
        let storyPlayVC = UIViewController.viewControllerWith("StoryPlayVC") as! StoryPlayVC
        storyPlayVC.isFromFeedView = false
        storyPlayVC.transitioningDelegate = self
        storyPlayVC.interactor = interactor
        
        todayUserPosts.first?.isSeen = true
        storyPlayVC.medias = todayUserPosts
        
        transition(to: storyPlayVC)
        
        DispatchQueue.main.async {
            self.clv.reloadData()
        }
    }
    
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.15
        let translation = sender.translation(in: view)
        let fingerMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor.hasStarted = true
            dismiss(animated: true)
            
        case .changed:
            
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
            
        case .cancelled:
            
            interactor.hasStarted = false
            interactor.cancel()
            
        case .ended:
            
            interactor.hasStarted = false
            
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if clv.contentOffset.y < 5 {
            return true
        }
        
        return false
    }
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.push
        
        transition.subtype = CATransitionSubtype.fromTop
        
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: nil)
        
        if let homeVc = presentingViewController {
            homeVc.view.alpha = 1.0
        }
        navigationController?.popViewController(animated: false)
//        dismiss(animated: false, completion: nil)
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
    
    @IBAction func onBack(_ sender: Any) {
        transitionDismissal()
    }
}

extension OtherProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ProfileHeaderViewDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! ProfileHeaderView
       
        if self.isSelf {
            header.blockBtn.alpha = 0.0
            header.followBtn.alpha = 0.0
            header.blockBtn.isEnabled = false
            header.followBtn.isEnabled = false
        }else{
           header.blockBtn.alpha = 1.0
           header.blockBtn.isEnabled = true
           if self.blockerTap != nil && self.blockerTap {
               header.followBtn.alpha = 0.5
               header.followBtn.isEnabled = false
               header.blockBtn.setTitle("Unblock", for: .normal)
           }else{
                header.blockBtn.setTitle("Block", for: .normal)
               header.followBtn.alpha = 1.0
               header.followBtn.isEnabled = true
           }
        }
        header.imgProfile.setCircular()
        
        if todayUserPosts.count > 0 {
            if todayUserPosts.first?.isSeen == false {
                header.imgBorderView.setupGradientLayer(borderColors: nil, borderWidth: nil)
            } else {
                header.imgBorderView.setupGradientLayer(borderColors: [UIColor.clear], borderWidth: 3)
            }
        } else {
            header.imgBorderView.setupGradientLayer(borderColors: [UIColor.clear], borderWidth: 3)
        }
        
        
        header.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user?.user?.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
        
        header.lblViewCount.text        = "\(user?.user?.view_count_total ?? 0)"
        header.lblFollowerCount.text    = "\(user?.user?.followers_count ?? 0)"
        header.lblFollowingCount.text   = "\(user?.user?.followings_count ?? 0)"
        header.lblName.text             = user?.user?.fullname ?? ""
        header.lblBio.text              = user?.user?.bio ?? ""
        
        header.imgProfile.isUserInteractionEnabled = true
        header.addGestureRecognizer(profileImgTap)
        
        header.delegate                 = self
        
        if user!.isFollowing {
            header.followBtn.setTitle("Unfollow", for: .normal)
        } else {
            header.followBtn.setTitle("Follow", for: .normal)
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: view.frame.height * 0.43)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count // user?.posts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfilePostCell
        
        let post = userPosts[indexPath.row]
        
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 3
        
        return CGSize(width: width, height: width + 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if !blockerTap{
            let playVC = UIViewController.viewControllerWith("PostPlayVC") as! PostPlayVC
              
            playVC.transitioningDelegate = self
            playVC.interactor = interactor

            playVC.medias = userPosts
            playVC.viewFromFeed = false
            playVC.currentIndex = indexPath.row
            playVC.viewFromProfile =  true

            transition(to: playVC)
        }
      
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -10 {
            scrollView.contentOffset = CGPoint(x: 0, y: -10)
        }
    }
    
    func followBtnPressed() {
        if user!.isFollowing {
            NetworkManager.shared.unfollow(userId: (user!.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    self.user!.isFollowing = false
                    
                    DispatchQueue.main.async {
                        self.user?.user?.followers_count-=1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_FOLLOWING_COUNT_UPDATED),object: nil, userInfo: nil)
                        self.clv.reloadData()
                    }
                }
            }
        } else {
            NetworkManager.shared.follow(userId: (user!.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    self.user!.isFollowing = true
                    
                    DispatchQueue.main.async {
                        self.user?.user?.followers_count+=1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_FOLLOWING_COUNT_UPDATED),object: nil, userInfo: nil)
                        self.clv.reloadData()
                    }
                }
            }
        }
    }
    
    func blockBtnPressed() {
        if user == nil {
            return
        }else if !blockerTap {
            DataBaseManager.shared.blockUsers(blockerId: (user!.user?.userID)!){(result, error) in
                if error == ""{
                    self.userPosts.removeAll()
                    self.blockerTap = true
                    self.clv.reloadData()
                }else{
                    print("error")
                    self.showAlertWithError(title: "Error", message: "Failed to block user")
                }
            }
        }else{
            DataBaseManager.shared.unblockUsers(blockerId: (user!.user?.userID)!){(result, error) in
                if error == ""{
                    self.blockerTap = false
                    let sorted = self.user!.posts.sorted(by: { (media1, media2) -> Bool in
                        return media1.created > media2.created
                    })
                    self.userPosts = sorted
                    self.clv.reloadData()
                }else{
                    print("error")
                    self.showAlertWithError(title: "Error", message: "Failed to block user")
                }
            }
        }
    }
}
