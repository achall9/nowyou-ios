//
//  FollowContatinerViewController.swift
//  NowYou
//
//  Created by 111 on 1/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//protocol FollowContainerVCDelegate {
//    func seeFollowsProfile(userId : Int)
//}
class FollowContatinerViewController: BasePagerVC {
//    var followContainerVCDelegate : FollowContainerVCDelegate?
    var isFollowers = false
    var followVC : FollowViewController?
    var followerTVC : FollowersTableViewController?
    var followingTVC : FollowingsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonBarView.selectedBar.backgroundColor = UIColor(hexValue: 0x60DF76)
        buttonBarView.backgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 13)
        settings.style.buttonBarItemTitleColor = UIColor.black
        // Do any additional setup after loading the view.
        
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        followerTVC = FollowersTableViewController(style: .plain)
        followerTVC?.followVC = followVC
        
        followingTVC = FollowingsTableViewController(style: .plain)
        followingTVC?.followVC = followVC
        
//        followerTVC?.followersTVCDelegate = self
        
        guard isFollowers else {
            return [followerTVC!, followingTVC!]
        }

        var childControllers = [followerTVC!, followingTVC!]
        
        for index in childControllers.indices {
            let nElements = childControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            
            if n != index {
                childControllers.swapAt(index, n)
            }
        }
        
        let nItems = 1 + (arc4random() % 4)
        return Array(childControllers.prefix(upTo: Int(nItems)))
        
    }
    
    override func reloadPagerTabStripView() {
          isFollowers = true
          if arc4random() % 2 == 0 {
              pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0)
          } else {
              pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
          }
          super.reloadPagerTabStripView()
      }
}

//extension FollowContatinerViewController : FollowersTVCDelegate{
//    func seeFollowsProfile_t(userId: Int) {
//        followContainerVCDelegate?.seeFollowsProfile(userId: userId)
//    }
//}
