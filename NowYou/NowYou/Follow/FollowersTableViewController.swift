//
//  FollowersTableViewController.swift
//  NowYou
//
//  Created by 111 on 1/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
//protocol FollowersTVCDelegate {
//    func seeFollowsProfile_t(userId : Int)
//}
class FollowersTableViewController: BaseTableViewController, IndicatorInfoProvider {
    
//    var followersTVCDelegate : FollowersTVCDelegate?
    
    var itemInfo = IndicatorInfo(title: "Followers")
    var followers = [User]()
    var followVC: FollowViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "FollowCell", bundle: Bundle.main), forCellReuseIdentifier: "FollowCell")
        getFollowers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
     
        cell.followPerson = followers[indexPath.row]
        Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))
        
        return cell
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if followers.count > 6 {
            return tableView.frame.height / 6
        }
        if Utils.isIPhoneX() {
            return 812 * 0.0839 + 16
        } else {
            return 667 * 0.0839 + 16
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        followersTVCDelegate?.seeFollowsProfile_t(userId : self.followers[indexPath.row].userID)
        NotificationCenter.default.post(name: .followerProfileViewNotification, object: self, userInfo: ["userID": self.followers[indexPath.row].userID])
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -10 {
            scrollView.contentOffset = CGPoint(x: 0, y: -10)
        } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
        }
    }
    
    func getFollowers() {
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.getfollowers { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            switch response {
            case .error(let error):
                print (error.localizedDescription)
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any], let followingsArr = json["followers"] as? [[String: Any]] {
                        
                        self.followers.removeAll()
                        
                        for follower in followingsArr {
                            let user = User(json: follower)
                            
                            self.followers.append(user)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
