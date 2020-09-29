//
//  LoginMultipleViewController.swift
//  NowYou
//
//  Created by mobiledev coach on 9/18/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class LoginMultipleViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var users: [User]!
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
    }
    
    func doLogin(_ user: User) {
        DispatchQueue.main.async {
            Utils.showSpinner()
            self.view.endEditing(true)
        }
        NetworkManager.shared.login(user_name: user.username, password: self.password) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: "Login not recognized"), animated: true, completion: nil)
                        
                        break
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let jsonObject = jsonRes as? [String: AnyObject] {
                                
                                if let token = jsonObject["token"] as? String {
                                    TokenManager.saveToken(token: token)
                                }
                                
                                if let userJSON = jsonObject["user"] as? [String: Any] {
                                    print (userJSON)
                                    let user = User(json: userJSON)
                                    let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
                                    UserDefaults.standard.set(encodedUser, forKey: USER_INFO)
                                    
                                    NotificationManager.shared.storeToken()
                                    UserManager.updateUser(user: user)
                                    
                                    DispatchQueue.main.async {
                                        UIManager.showMain()
                                    }
                                    
                                } else {
                                    self.present(Alert.alertWithText(errorText: "Invalid Credentials."), animated: true, completion: nil)
                                }
                            }
                        } catch {
                            
                        }
                    break
                }
            }
        }
    }
    
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension LoginMultipleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAccountCell") as? ChooseAccountCell
        
        let user = self.users[indexPath.row]
        
        cell?.imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto ?? "")), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
        cell?.imgProfile.setCircular()
        cell?.lblName.text = user.username
        
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let user = self.users[indexPath.row]
        
        self.doLogin(user)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
