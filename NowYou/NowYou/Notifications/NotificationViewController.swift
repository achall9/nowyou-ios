//
//  NotificationViewController.swift
//  NowYou
//
//  Created by Apple on 3/24/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class NotificationViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var tblNotification: UITableView!
    var notifications = [NotificationObj]()
    var interactor = Interactor()
    let transition = CATransition()
    var playVC : PostPlayVC!
    var posts = [Media]()
    var transitionState : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        tblNotification.tableFooterView = UIView()

//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//
//        view.addGestureRecognizer(recognizer)
        
        NetworkManager.shared.getNotifications { (response) in
            switch response {
            case .error(let error):
                print (error.localizedDescription)
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any], let notifArrs = json["notifications"] as? [[String: Any]] {
                        self.notifications.removeAll()
                        
                        for notificationJson in notifArrs {
                            let notification = NotificationObj(json: notificationJson)
                            
                            self.notifications.append(notification)
                        }
                        self.notifications.reverse()
                        
                        DispatchQueue.main.async {
                            self.tblNotification.reloadData()
                        }
                    }
                } catch {
                    
                }
            }
        }
        addRigthSwipe()
        UIApplication.shared.applicationIconBadgeNumber = 0
        NotificationCenter.default.post(name: .photoEditViewEnable, object: self)
    }
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
       if (sender.direction == .right) {
           NotificationCenter.default.post(name: .photoEditViewDisable, object: self)
           transitionDismissal()
           print("Swipe right")
       }
    }

    @IBAction func onBack(_ sender: Any) {
        NotificationCenter.default.post(name: .photoEditViewDisable, object: self)
        transitionDismissal()
        
    }
    func getUserDetails(_ userId: Int){
        NetworkManager.shared.getUserDetails(userId: userId) { (response) in
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

                            var posts = [Media]()
                            if let postsJson = userJson["posts"] as? [[String: Any]] {
                                for post in postsJson {
                                    posts.append(Media(json: post))
                                }
                            }

                            if let searchUser = SearchUser(searchUser: user, following: isFollowing, posts: posts) as? SearchUser{
                                let profile = UIViewController.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
                                profile.user = searchUser
                                profile.blockerTap = false
                                DispatchQueue.main.async {
                                    profile.transitioningDelegate = self
                                    profile.interactor = self.interactor

                                    self.transitionState = self.transition(to: profile)
                                }
                            }else{
                                self.showAlertWithError(title: "", message: "User does not exist")
                            }
                        }
                    }
                } catch {

                }
            }
        }
    }
    func getFeeds(_ notificationFeedId: Int, _ userId: Int) {
        DispatchQueue.main.async {
            if self.posts.count == 0 {
//                Utils.showSpinner()
            }
        }
        NetworkManager.shared.getFeeds { (response) in
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
                                        if post.id == notificationFeedId && post.userId == userId{
                                            self.playVC = Utils.viewControllerWith("PostPlayVC") as? PostPlayVC
                                            self.playVC.medias = [existingPost]
                                            self.playVC.transitioningDelegate = self
                                            self.playVC.interactor = self.interactor
                                            self.playVC.viewFromFeed = true
                                            self.transitionState = self.transition(to: self.playVC)
                                            break
                                        }
                                         if post.id == existingPost.id {
                                             bAdded = true
                                             break
                                         }
                                     }
                                     if !bAdded {
                                         self.posts.append(post)
                                     }
                                }
                                if !self.transitionState {
                                    self.showAlertWithError(title: "", message: "Post does not exist")
                                }else{
                                    self.transitionState = false
                                }
                            }
                        }
                    } catch {
                    }
                }// end --- switch response
            }//end :DispatchQueue.main.async
        }
    }
    // MARK: - Private
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.5
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
    
    func transitionDismissal() {
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    func transition(to controller: UIViewController)-> Bool {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
        return true
    }
    
    // MARK: - Animation
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return DismissAnimator()
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactor.hasStarted
                ? interactor
                : nil
    }
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NotificationCell
        
        cell.notificatiaon = notifications[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notificationFeedId = notifications[indexPath.row].feed_id ?? 0
        let userId = notifications[indexPath.row].sender_id ?? 0
        let action = notifications[indexPath.row].action
        if action == .Comment || action == .Like{
            self.getFeeds(notificationFeedId,userId)
        }
        else if action == .Follow{
            self.getUserDetails(userId)
        }
    }
}
