//
//  FollowingsTableViewController.swift
//  NowYou
//
//  Created by 111 on 1/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FollowingsTableViewController: BaseTableViewController, IndicatorInfoProvider {
    var itemInfo = IndicatorInfo(title: "Following")
    var followVC: FollowViewController?
    var followings = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
         tableView.register(UINib(nibName: "FollowCell", bundle: Bundle.main), forCellReuseIdentifier: "FollowCell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        getFollowings()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followings.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
     
        cell.followPerson = followings[indexPath.row]
        
        Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))
        
        return cell
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if followings.count > 6 {
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
        NotificationCenter.default.post(name: .followingProfileViewNotification, object: self, userInfo: ["userID": self.followings[indexPath.row].userID ?? 0])
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -10 {
            scrollView.contentOffset = CGPoint(x: 0, y: -10)
        } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
        }
    }
    func getFollowings() {
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        NetworkManager.shared.getfollowings { (response) in
            
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            switch response {
            case .error(let error):
                print (error.localizedDescription)
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any], let followingsArr = json["followings"] as? [[String: Any]] {
                        
                        self.followings.removeAll()
                        
                        for follower in followingsArr {
                            let user = User(json: follower)
                            
                            self.followings.append(user)
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
