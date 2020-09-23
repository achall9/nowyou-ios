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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
    }
    
    func initTableView() {
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
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
        
        TokenManager.saveToken(token: user.token)
        UserManager.updateUser(user: user)
        
        DispatchQueue.main.async {
            UIManager.showMain()
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}
