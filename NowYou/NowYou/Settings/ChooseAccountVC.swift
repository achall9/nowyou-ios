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
        
        let name = UserManager.getUserType()
        
        NetworkManager.shared.is_email_phone_duplicate(email: name, phone: name, user_name: name) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                        break
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let jsonObject = jsonRes as? [String: Any] {
                                
                                let accounts = jsonObject["accounts"] as? [[String: Any]]
                                
                                self.users.removeAll()
                                
                                for account in accounts! {
                                    let user = User(json: account)
                                    self.users.append(user)
                                }
                                
                                self.tableView.reloadData()
                                
                                
                            } else {
                               self.present(Alert.alertWithText(errorText: "Invalid Credentials."), animated: true, completion: nil)
                           }
                        } catch {
                            
                        }
                    break
                }
            }
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
