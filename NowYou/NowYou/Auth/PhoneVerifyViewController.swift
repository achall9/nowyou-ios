//
//  PhoneVerifyViewController.swift
//  NowYou
//
//  Created by 111 on 2/13/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging

class PhoneVerifyViewController: UIViewController {

    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var txtVerifyCode: UITextField!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    var phoneNum: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var password: String!
    var birthday: Date!
    var gender: Int!
    var username: String!
    var bio: String!
    var privateOn: Int!
    
    var userRegisterState : Bool!
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
        userRegisterState = false
        sendVerificationCode(phoneNumber: phoneNum)
    }
    
    @IBAction func onClose(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onVerify(_ sender: Any) {
        signUserWithVerificaionCode()
    }
    
    @IBAction func onResend(_ sender: Any) {
        sendVerificationCode(phoneNumber: phoneNum)
    }

// private make
    func initUI(){
        // init Button UI
        btnVerify.layer.cornerRadius = 6
        btnVerify.layer.masksToBounds = true
        btnVerify.layer.borderWidth = 1
        btnVerify.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        btnVerify.backgroundColor = UIColor(hexValue: 0x60DF76)
        btnVerify.setTitleColor(UIColor.white, for: .normal)
        
        //init phone number label

        lblPhoneNumber.text = phoneNum
        Utilities.styleTextField(txtVerifyCode)
    }
    static func styleTextField(_ textfield : UITextField){
        let bottomLine = CALayer()
        // Create the bottom line
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        //Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    func sendVerificationCode(phoneNumber: String){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
           if let error = error {
                self.present(Alert.alertWithText(errorText: "Please send again."), animated: true, completion: nil)
                print(error.localizedDescription)
                return
           }else{
            // Sign in using the verificationID and the code sent to the user
          // ..
            print("verificationId = ",verificationId ?? "")
            guard let verificationID = verificationId else {return}
            self.userDefault.set(verificationID, forKey: "authVerificationID")
            self.userDefault.synchronize()
          }
        }
    }
    
    func signUserWithVerificaionCode(){
        guard  let verifyCode = txtVerifyCode.text, verifyCode.count == 6 else {
            self.present(Alert.alertWithText(errorText: WRONG_PHONE_VERIFY_CODE), animated: true, completion: nil)
            return
        }
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!,verificationCode: verifyCode)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            self.present(Alert.alertWithText(errorText: "Failed. Please send again."), animated: true, completion: nil)
                print(error.localizedDescription)
                return
          }
          // User is signed in
        self.createNewAccount()
        }
    }
    
     func createNewAccount(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"

        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.register(first_name: firstName, last_name: lastName, email: email, password: password, phone: phoneNum, device_token: "", birthday: dateFormatter.string(from: self.birthday!), gender: gender, username: username, privateOn: self.privateOn, bio: self.bio) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    self.present(Alert.alertWithText(errorText: "Resiger not recognized"), animated: true, completion: nil)
                    break
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                        if let jsonObject = jsonRes as? [String: AnyObject] {
                            if let token = jsonObject["token"] as? String {
                                TokenManager.saveToken(token: token)
                            }
                            if let userJSON = jsonObject["user"] as? [String: Any] {
                                let user = User(json: userJSON)
                                
                                let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
                                UserDefaults.standard.set(encodedUser, forKey: USER_INFO)

                                NotificationManager.shared.storeToken()
                                NetworkManager.shared.follow(userId: 41, completion: { (response) in
                                    DispatchQueue.main.async {
//                                    self.createStripeCustomer(email: self.email, name: self.username)
//                                    self.createStripeCustomAccount(email: self.email)
                                       UIManager.showMain()

                                    }
                                })
                                
                            } else {
                                self.present(Alert.alertWithText(errorText: "An account already exists with this email or phone number."), animated: true, completion: nil)
                                self.navigationController?.popViewController(animated: false)
                            }
                        }
                    } catch {

                    }
                    break
                }
            }
        }
    }
}

extension PhoneVerifyViewController{
    //-- external account
    func createStripeCustomAccount(email: String){
        StripeManager.createConnectAccountToken(ssn: "", line1: "", city: "", state: "", zipcode: "") { token, error in
              if let error = error {
                 print(error.localizedDescription)
              } else if let token = token {
                 StripeManager.shared.createStripeCustomAccount(email: email, country: "US", connectAccountToken: token){(result,error) in
                      if let error = error{
//                          self.showAlertWithError(title: "Stripe Custom Account", message: error.message!)
                       }else{
                           guard let stripeCustomAccount = result["stripeCustomAccountId"] else { return }
                          self.uploadStripeCustomAccountId(customAccountId: stripeCustomAccount)
                       }
                   }
              }
          }
     }
    func uploadStripeCustomAccountId(customAccountId: String){
        DataBaseManager.shared.updateUserPaymentEmail(paymentEmail: customAccountId) {(error) in
             if let error = error {
                print("Can not register stripe custom account id", error.message!)
             }else{
                 DispatchQueue.main.async {
                    UserDefaults.standard.set(customAccountId, forKey: "StripeCustomAccountId")
                    print("Register stripe custom account id successfully")
                 }
             }
         }
    }
    
    //--- customer
    func createStripeCustomer(email: String, name: String){
        StripeManager.shared.createStripeCustomer(email, name){(result,error) in
            if let error = error{
//                self.showAlertWithError(title: "Stripe Customer", message: error.message!)
            }else{
                 guard let stripeCustomerId = result["stripeCustomerId"] else { return }
                self.uploadStripeCustomerId(customerId: stripeCustomerId)
            }
        }
    }
    func uploadStripeCustomerId(customerId: String){
        DataBaseManager.shared.updateUserPaymentEmail(paymentEmail: customerId) {(error) in
            if let error = error {
                print("Can not register stripe custom account id", error.message!)
            }else{
                DispatchQueue.main.async {
                    UserDefaults.standard.set(customerId, forKey: "StripeCustomerId")
                    UIManager.showMain()
                    print("Register stripe custom account id successfully")
                }
            }
        }
    }
}


