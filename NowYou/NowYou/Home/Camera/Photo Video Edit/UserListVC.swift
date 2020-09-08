//
//  UserListVC.swift
//  NowYou
//
//  Created by mobiledev coach on 9/3/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class UserListVC: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    var pageNum: Int = 1
    var selected_user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTableView()
        self.getAllUsers()
    }
    
    
    func initTableView() {
        self.tableView.tableFooterView = UIView()
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
                    self.tableView.reloadData()
                }
            }// End DispatchQueue.main.async {
        }
        
    }
    
    
    //MARK: Actions
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: .taggedUserNotification, object: nil, userInfo: ["selected_user" : self.selected_user])
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension UserListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell") as? UserListCell
        
        cell?.updateCell(users[indexPath.row])
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let user = self.users[row]
        self.selected_user = user
    }
    
    
}


class UserListCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    
    func updateCell(_ user: User) {
        self.lblName.text = user.username
    }
}
