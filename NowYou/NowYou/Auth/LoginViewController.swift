//
//  ViewController.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ActiveLabel


class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblSignup: ActiveLabel!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    
    
    
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupSignUpLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){

        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification){

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    @IBAction func onTextFocus(_ sender: UIButton) {
        if sender.tag == 10 {
            txtEmail.becomeFirstResponder()
        } else {
            txtPwd.becomeFirstResponder()
        }
    }
    
    func setupSignUpLabel() {
        lblSignup.customize { (label) in
            label.text = "Don't have an account?   Sign Up"
            
            let signup              = "Sign Up"
            let customTypeSignup    = ActiveType.custom(pattern: "\\s\(signup)\\b")
            label.enabledTypes      = [customTypeSignup]
            
            label.customColor[customTypeSignup] = NYColors.NYGreen()
            
            label.highlightFontName = "Gilroy-Bold" //NYFonts.sourceGilroy(size: 14, weight: .bold)
            label.highlightFontSize = 14.0
            
            label.handleCustomTap(for: customTypeSignup) { (element) in
                self.performSegue(withIdentifier: "toSignup", sender: nil)
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        guard !txtEmail.text!.isEmpty else {
            self.present(Alert.alertWithText(errorText: WRONG_EMAIL), animated: true, completion: nil)
            return
        }
        
        guard !txtPwd.text!.isEmpty else {
            self.present(Alert.alertWithText(errorText: NO_PASSWORD), animated: true, completion: nil)
            return
        }
        
        DispatchQueue.main.async {
            Utils.showSpinner()
            self.view.endEditing(true)
        }
        
        NetworkManager.shared.is_email_phone_duplicate(email: txtEmail.text!, phone: txtEmail.text!) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: "Checking email/phone duplication not recognized"), animated: true, completion: nil)
                        break
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let jsonObject = jsonRes as? [String: Any] {
                                
                                let accounts = jsonObject["accounts"] as? [[String: Any]]
                                
                                if accounts?.count == 1 {
                                    self.doLogin()
                                } else {
                                    for account in accounts! {
                                        let user = User(json: account)
                                        self.users.append(user)
                                    }
                                    
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginMultipleViewController") as! LoginMultipleViewController
                                    vc.users = self.users
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                }
                                
                                
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
    
    func doLogin() {
        
        NetworkManager.shared.login(email: txtEmail.text!, password: txtPwd.text!) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: "Login not recognized"), animated: true, completion: nil)
                        self.txtEmail.text = ""
                        self.txtPwd.text = ""
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
                                    DispatchQueue.main.async {
                                        let app = UIApplication.shared.delegate as! AppDelegate
                                        app.window?.rootViewController = UIViewController.viewControllerWith("homeVC")
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
    
    @IBAction func actionForgotPwd(_ sender: UIButton) {
        print("forgot password")
        
        let alertController = UIAlertController(title: "Forgot Password", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter your email address"
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
        (action : UIAlertAction!) -> Void in })
        
        
        let saveAction = UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let tfEmail = alertController.textFields![0] as UITextField
            let email = tfEmail.text ?? ""
            
            if email == "" {
                self.present(Alert.alertWithText(errorText: "Please input the email address you remember"), animated: true, completion: nil)
                return
            }
            
            
            NetworkManager.shared.passwordReset(email: email) { (response) in
                
                DispatchQueue.main.async {
                    switch response {
                    case .error( _):
                            self.present(Alert.alertWithText(errorText: "Password Reset is not recognized"), animated: true, completion: nil)
                            self.txtEmail.text = ""
                            break
                        case .success(let data):
                            do {
                                let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                
                                if let jsonObject = jsonRes as? [String: AnyObject] {
                                    
                                    if let success = jsonObject["success"] as? String {
                                        self.present(Alert.alertWithTextInfo(errorText: success), animated: true, completion: nil)
                                    } else if let failure = jsonObject["failure"] as? String {
                                        self.present(Alert.alertWithText(errorText: failure), animated: true, completion: nil)
                                    }
                                }
                            } catch {
                                
                            }
                            break
                    }
                }
            }
            
        })
        
       
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    
}
