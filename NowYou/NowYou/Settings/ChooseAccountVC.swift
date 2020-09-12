//
//  ChooseAccountVC.swift
//  NowYou
//
//  Created by mobiledev coach on 9/4/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ChooseAccountVC: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initTableView()
        self.getAdditionalAccounts()
    }
    
    func initView() {
        self.lblName.text = "Hi, " + UserManager.currentUser()!.username
    }
    
    func initTableView() {
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
    }
    
    func getAdditionalAccounts() {
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        
        var main_user_id = UserManager.currentUser()?.userID
        if UserManager.currentUser()?.main_user_id != nil &&
            UserManager.currentUser()?.main_user_id != 0 {
            main_user_id = UserManager.currentUser()?.main_user_id
        }
        
        let main_userId = "\(main_user_id ?? 0)"
        
        NetworkManager.shared.getAdditionalAccounts(main_user_id: main_userId) { (response) in
                
            DispatchQueue.main.async {
                switch response {
                    case .error(let error):
                        print (error.localizedDescription)
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                            print (jsonRes)
                            if let json = jsonRes as? [String: Any]  /*, let usersData = json["data"] as? [[String: Any]]*/ {
                                if let usersJson = json["additional_accounts"] as? [[String: Any]] {
                                    for userJson in usersJson {
                                        let users = User(json: userJson)
                                        self.users.append(users)
                                    }
                                }
                            }
                        } catch {
                            
                        }
                }  // End switch response
                
                // Sort the users that current user to be on top of list.
                var tmpUsers = [User]()
                for user in self.users {
                    if user.userID != UserManager.currentUser()?.userID {
                        tmpUsers.append(user)
                    }
                }
                self.users.removeAll()
                self.users.append(UserManager.currentUser()!)
                self.users.append(contentsOf: tmpUsers)
                // End Sort
                
                DispatchQueue.main.async {
                    Utils.hideSpinner()
                    self.tableView.reloadData()
                }
            }  // End DispatchQueue.main.async {
        }
        
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        print("editAction")
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ChooseAccountVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users.count > 4 {
            return self.users.count
        } else {
            return self.users.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.users.count > indexPath.row {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAccountCell") as? ChooseAccountCell
            
            let user = self.users[indexPath.row]
            
            cell?.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
            cell?.imgProfile.setCircular()
            cell?.lblName.text = user.username
            
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell!
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAdditionalAccountCell") as? AddAdditionalAccountCell
            
            cell?.selectionStyle = .none
            cell?.backgroundColor = .clear
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.users.count {
            print("AddAdditionalAccountCell")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAdditionalAccountVC") as? AddAdditionalAccountVC
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let user = self.users[indexPath.row]
            
            TokenManager.saveToken(token: user.token)
            UserManager.updateUser(user: user)
            
            self.navigationController?.popViewController(animated: true)
             
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

class ChooseAccountCell: UITableViewCell {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
}

class AddAdditionalAccountCell: UITableViewCell {
    
}
