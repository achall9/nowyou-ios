//
//  ContactViewController.swift
//  NowYou
//
//  Created by Apple on 4/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactViewController: BaseViewController{
    

    @IBOutlet weak var tblContact: UITableView!
    
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    var followers = [User]()
    var contacts = [CNContact]()
    let contactStore = CNContactStore()
    var pageNum: Int = 1
    
    var users = [SearchUser]()
    var followings = [User]()
    
    var phoneNumberStrs = [Int : String]()
    var selectAllState : Bool = false
    func initButtonUI(){
        btnSelect.layer.cornerRadius = 6
        btnSelect.layer.masksToBounds = true
        btnSelect.layer.borderWidth = 1
        btnSelect.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        btnSelect.backgroundColor = UIColor(hexValue: 0x60DF76).withAlphaComponent(0.4)
        btnSelect.setTitleColor(UIColor.black, for: .normal)
        
        btnSend.layer.cornerRadius = 6
        btnSend.layer.masksToBounds = true
        btnSend.layer.borderWidth = 1
        btnSend.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        btnSend.backgroundColor = UIColor(hexValue: 0x60DF76)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblContact.tableFooterView = UIView()
        UserDefaults.standard.set(true, forKey: CONTACT_SCREEN_SHOWN)
        
        tblContact.allowsMultipleSelection = true
        tblContact.allowsSelectionDuringEditing = true
        
        phoneNumberStrs.removeAll()
        users.removeAll()
        selectAllState = false
        
        initButtonUI()
        
        self.getAllUsers()
        
        self.fetchContacts()

        
    }
    func getAllUsers(){
        DispatchQueue.main.async {
//           Utils.showSpinner()
       }
        users.removeAll()
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
                                    let following = user["is_following"] as? Bool ?? false
                                    
                                    self.users.append(SearchUser(searchUser: userObj, following: following, posts: []))
                                }
                            }
                        }
                    } catch {
                        
                    }
                }// End switch response
                self.tblContact.reloadData()
            }// End DispatchQueue.main.async {
        }
    }
    func fetchContacts() {
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        request.sortOrder = CNContactSortOrder.userDefault
        do {
            try self.contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
            }
        }
        catch {
            print("unable to fetch contacts")
        }
    }
    
    @IBAction func onSMSSend(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Come join me on the NowYou app to start making money with your social media! --> https://nowyou.com"
            controller.recipients = Array(phoneNumberStrs.values)
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func onSelectOnDeselect(_ sender: Any) {
        if selectAllState == false {
            for index in 0...contacts.count-1{
                let indexPath = NSIndexPath(row: index, section: 0)
                tblContact.selectRow(at: indexPath as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
                if let cell = tblContact.cellForRow(at: indexPath as IndexPath) {
                    cell.accessoryType = .checkmark
                    if let phoneNumber = (contacts[indexPath.row].phoneNumbers.first)?.value {
                        let phoneNumberStr = phoneNumber.value(forKey: "digits") as? String ?? ""
                        phoneNumberStrs[indexPath.row] = phoneNumberStr
                    }
                }
            }
            btnSelect.setTitle("Deselect All", for: .normal)
            btnSelect.backgroundColor = UIColor(hexValue: 0x60DF76)
            btnSelect.setTitleColor(UIColor.white, for: .normal)
            selectAllState = true
            
        }else{
            btnSelect.setTitle("Select All", for: .normal)
            btnSelect.backgroundColor = UIColor(hexValue: 0x60DF76).withAlphaComponent(0.4)
            btnSelect.setTitleColor(UIColor.black, for: .normal)
            selectAllState = false
            for index in 0...contacts.count-1{
                let indexPath = NSIndexPath(row: index, section: 0)
                tblContact.deselectRow(at: indexPath as IndexPath, animated: true)
                if let cell = tblContact.cellForRow(at: indexPath as IndexPath) {
                    cell.accessoryType = .none
                    phoneNumberStrs.removeValue(forKey: indexPath.row)
                }
            }
        }
    }

    @objc func unfollow(sender: UIButton){
        let index = sender.tag
        let contact = contacts[index] as CNContact
        let phoneNumber = (contact.phoneNumbers.first)?.value
        let phoneNumberStr = phoneNumber!.value(forKey: "digits") as! String
        var followUser: SearchUser!
        for user in self.users {
            if user.user!.phone.contains(phoneNumberStr) {
                followUser = user as SearchUser
                break
            }
        }
        DispatchQueue.main.async {
           Utils.showSpinner()
        }
        NetworkManager.shared.unfollow(userId: followUser.user!.userID) { (response) in
        DispatchQueue.main.async {
             Utils.hideSpinner()
            switch response {
            case .error(let error):
               print (error.localizedDescription)
            case .success(_):
               let user = UserManager.currentUser()
               
               user?.followers_count -= 1
               
               UserManager.updateUser(user: user!)
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil, userInfo: nil)
               self.getAllUsers()
               }
              
           }
        }
    }
    @objc func follow(sender: UIButton) {
        let index = sender.tag
        let contact = contacts[index] as CNContact
        let phoneNumber = (contact.phoneNumbers.first)?.value
        let phoneNumberStr = phoneNumber!.value(forKey: "digits") as! String
        var followUser: SearchUser!
        for user in self.users {
            if user.user!.phone.contains(phoneNumberStr) {
                followUser = user
                break
            }
        }
        DispatchQueue.main.async {
           Utils.showSpinner()
        }
        NetworkManager.shared.follow(userId: (followUser.user?.userID)!) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    let user = UserManager.currentUser()
                    
                    user?.followers_count += 1
                    
                    UserManager.updateUser(user: user!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil, userInfo: nil)
                    self.getAllUsers()
                    }
                
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func checkIfExistUser(phone: String) -> Bool {
        for user in self.users {
            print(user.user!.phone)
            if user.user!.phone.contains(phone) {
                return true
            }
        }
        return false
    }
    
    func checkIfAlreadyFollow(phone: String) -> Bool {
        for user in self.users {
            if user.user!.phone.contains(phone) {
                if user.isFollowing {
                    return true
                }
            }
        }
        return false
    }
}

extension ContactViewController: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            if let phoneNumber = (contacts[indexPath.row].phoneNumbers.first)?.value {
                let phoneNumberStr = phoneNumber.value(forKey: "digits") as? String ?? ""
                phoneNumberStrs[indexPath.row] = phoneNumberStr
            }
        }
//        if let phoneNumber = (contacts[indexPath.row].phoneNumbers.first)?.value {
//                  let phoneNumberStr = phoneNumber.value(forKey: "digits") as? String ?? ""
//            let sms: String = "sms:\(phoneNumberStr)&body=Come join me on the NowYou app to start making money with your social media! --> https://nowyou.com"
//                   let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                   UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
//        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            phoneNumberStrs.removeValue(forKey: indexPath.row)
        }
    }
}
extension ContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ContactCell
        cell.accessoryType = .none
        

        
        let contact = contacts[indexPath.row] as CNContact
        cell.btnFollow.isHidden = true
        
        if let phoneNumber = (contact.phoneNumbers.first)?.value {
            let phoneNumberStr = phoneNumber.value(forKey: "digits") as? String ?? ""
            
            if checkIfExistUser(phone: phoneNumberStr) {
                cell.btnFollow.isHidden = false
                
                if checkIfAlreadyFollow(phone: phoneNumberStr) {
                    cell.btnFollow.setTitle("Unfollow", for: .normal)
                    cell.btnFollow.backgroundColor = UIColor(hexValue: 0x60DF76)
                    cell.btnFollow.setTitleColor(UIColor.white, for: .normal)
                    cell.btnFollow.tag = indexPath.row
                    cell.btnFollow.addTarget(self, action: #selector(unfollow(sender:)), for: .touchUpInside)
                } else {
                    cell.btnFollow.setTitle("Follow", for: .normal)
                    cell.btnFollow.backgroundColor = UIColor(hexValue: 0x60DF76).withAlphaComponent(0.4)
                    cell.btnFollow.setTitleColor(UIColor.black, for: .normal)
                    cell.btnFollow.tag = indexPath.row
                    cell.btnFollow.addTarget(self, action: #selector(follow(sender:)), for: .touchUpInside)
                }
            } else {
                cell.btnFollow.isHidden = true
            }
        }
        cell.contact = contact
        return cell
    }
}

extension ContactViewController : MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}
