//
//  BlockedUsersViewController.swift
//  NowYou
//
//  Created by 111 on 5/20/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class BlockedUsersViewController: BaseViewController, UIViewControllerTransitioningDelegate{

    @IBOutlet weak var tblBlockedUsers: UITableView!
    var blockedUsers = [SearchUser]()
    let interactor = Interactor()
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblBlockedUsers.allowsSelectionDuringEditing = true
        tblBlockedUsers.register(UINib(nibName: "FollowCell", bundle: Bundle.main), forCellReuseIdentifier: "FollowCell")
       
    }
    override func viewWillAppear(_ animated: Bool) {
         getBlockers()
    }
    func getBlockers(){
        DataBaseManager.shared.getBlockerList(){(result, error) in
            if error == "" {
                self.blockedUsers = result
                self.tblBlockedUsers.reloadData()
            }else{
                print(error)
            }
        }
    }

    @IBAction func onBack(_ sender: Any) {
//         navigationController?.popViewController(animated: true)
        transitionDismissal()
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
}

extension BlockedUsersViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         if let cell = tableView.cellForRow(at: indexPath) {
           let otherProfileVC = Utils.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController

           otherProfileVC.transitioningDelegate = self
           otherProfileVC.interactor = interactor ?? Interactor()
           otherProfileVC.user = blockedUsers[indexPath.row]
           otherProfileVC.blockerTap = true
           if !transition(to: otherProfileVC){
               print("Fail to go to blocker profile")
           }
           
       }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if blockedUsers.count > 6 {
            return tableView.frame.height / 6
        }
        
        if Utils.isIPhoneX() {
            return 812 * 0.0839 + 16
        } else {
            return 667 * 0.0839 + 16
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if blockedUsers.count != 0{
            if scrollView.contentOffset.y < -10 {
                scrollView.contentOffset = CGPoint(x: 0, y: -10)
            } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
                scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
            }
        }
    }
}
extension BlockedUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
        cell.followPerson = blockedUsers[indexPath.row].user
        Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))
        cell.accessoryType = .none

        return cell
    }
}

