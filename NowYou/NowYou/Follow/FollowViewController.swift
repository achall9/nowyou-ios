//
//  FollowViewController.swift
//  NowYou
//
//  Created by 111 on 1/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class FollowViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var vLogo: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    var followContainerVC: FollowContatinerViewController?
    
    let interactor = Interactor()
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        vLogo.layer.borderColor = UIColor(hexValue: 0xBABABA).cgColor
//        vLogo.layer.borderWidth = 5.5
        NotificationCenter.default.addObserver(self, selector: #selector(FollowViewController.seeFollowsProfile),
                name: .followerProfileViewNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FollowViewController.seeFollowsProfile),
        name: .followingProfileViewNotification, object: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFollowContainer" {
            if let vc = segue.destination as? FollowContatinerViewController {
                vc.followVC = self
                self.followContainerVC = vc
            }
        }
    }
        // MARK: - Animation
        
        func animationController(
            forDismissed dismissed: UIViewController)
            -> UIViewControllerAnimatedTransitioning? {
                return DismissAnimator()
        }
        
        func transitionPush(to controller: UIViewController) {
            transition.duration = 0.3
            transition.type = CATransitionType.fade
            
            transition.subtype = CATransitionSubtype.fromRight
            
            view.window?.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(controller, animated: false)
        }
        
        func transition(to controller: UIViewController) {
            transition.duration = 0.3
            transition.type = CATransitionType.fade
            
            transition.subtype = CATransitionSubtype.fromRight
            
            view.window?.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(controller, animated: false)
//            present(controller, animated: false)
        }

        func setNYViewActive(nyView: NYView, color: UIColor) {
            
            nyView.backgroundColor  = color
            nyView.shadowColor      = color
        }
    
    @objc private func seeFollowsProfile(_ notification: Notification) {
        let userId = notification.userInfo!["userID"]
       DispatchQueue.main.async {
           Utils.showSpinner()
       }
        NetworkManager.shared.getUserDetails(userId: userId as! Int) { (response) in
           DispatchQueue.main.async {
               Utils.hideSpinner()

               switch response {
               case .error(let error):
                       print(error.localizedDescription)
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
                               let profile = UIViewController.viewControllerWith("OtherProfileViewController")as! OtherProfileViewController

                               profile.blockerTap = false
                               profile.user = searchUser
                               self.transition(to: profile)
                           }
                       }//End--- if let json = jsonRes
                   } catch {
                       return
                   }
               }//--- End switch response
           }
       }//--- End  NetworkManager.shared.getUserDetails
    }
}
extension Notification.Name {
    static let followerProfileViewNotification = Notification.Name("FollowerProfileViewNotification")
    static let followingProfileViewNotification = Notification.Name("FollowingProfileViewNotification")
    
}
