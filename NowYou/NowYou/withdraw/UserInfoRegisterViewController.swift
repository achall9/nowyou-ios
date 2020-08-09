//
//  UserInfoRegisterViewController.swift
//  NowYou
//
//  Created by 111 on 3/11/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MaterialComponents
class UserInfoRegisterViewController: StripeBaseViewController,UIViewControllerTransitioningDelegate  {

    @IBOutlet weak var txtAddressLine: MDCTextField!
    @IBOutlet weak var txtCity: MDCTextField!
    @IBOutlet weak var txtState: MDCTextField!
    @IBOutlet weak var txtZip: MDCTextField!
    @IBOutlet weak var txtSSN: MDCTextField!
    @IBOutlet weak var btnRegister: MDCButton!
    
    private var addressLineController: MDCTextInputControllerOutlined?
    private var cityController: MDCTextInputControllerOutlined?
    private var stateController: MDCTextInputControllerOutlined?
    private var zipController: MDCTextInputControllerOutlined?
    private var ssnController: MDCTextInputControllerOutlined?
    
    
    var addressLine: String!
    var city: String!
    var state: String!
    var zip: String!
    var ssn: String!
    let ssnMax = 9
    let zipMax = 6
    var ssnResView: Bool = true
    
    let interactor = Interactor()
    let transition = CATransition()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        ssnResView = true
    }
    func configureUI(){
        txtSSN.delegate = self
        txtZip.delegate = self
        
        setBtnUI(btn: btnRegister, radius: 16)
        
        addressLineController = MDCTextInputControllerOutlined(textInput: txtAddressLine)
        setMDCTextField(txtField: txtAddressLine, mInoutController: addressLineController!)
        
        cityController = MDCTextInputControllerOutlined(textInput: txtCity)
        setMDCTextField(txtField: txtCity, mInoutController: cityController!)
        
        stateController = MDCTextInputControllerOutlined(textInput: txtState)
        setMDCTextField(txtField: txtState, mInoutController: stateController!)
        
        zipController = MDCTextInputControllerOutlined(textInput: txtZip)
        setMDCTextField(txtField: txtZip, mInoutController: zipController!)
        
        ssnController = MDCTextInputControllerOutlined(textInput: txtSSN)
        setMDCTextField(txtField: txtSSN, mInoutController: ssnController!)
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onRegister(_ sender: Any) {
    //--- Check Info field
        if txtAddressLine.text == nil || txtAddressLine.text == ""{
            self.present(Alert.alertWithTextInfo(errorText: "Please Check AddressLine!"), animated: true, completion: nil)
            return
        }else{
            addressLine = txtAddressLine.text
        }
        if txtCity.text == nil || txtCity.text == ""{
            self.present(Alert.alertWithTextInfo(errorText: "Please Check City!"), animated: true, completion: nil)
            return
        }else{
            city = txtCity.text
        }
        if txtState.text == nil || txtState.text == ""{
            self.present(Alert.alertWithTextInfo(errorText: "Please Check State!"), animated: true, completion: nil)
            return
        }else{
            state = txtState.text
        }
        if txtZip.text == nil || txtZip.text == ""{
         self.present(Alert.alertWithTextInfo(errorText: "Please Check Zip!"), animated: true, completion: nil)
         return
        }else{
            zip = txtZip.text
        }
        if txtSSN.text == nil || txtSSN.text == ""{
         self.present(Alert.alertWithTextInfo(errorText: "Please Check SSN!"), animated: true, completion: nil)
         return
        }else{
            ssn = txtSSN.text
        }
        
//        addressLine = "401 S Rosalind Ave #100"
//        city = "Orlando"
//        state = "Florida"
//        zip = "32801"
//        ssn = "8888"
        
        guard let _ = UserManager.currentUser()?.email else{return}
    createStripeCustomAccount(UserManager.currentUser()!.email,addressLine,city,state,zip,ssn)
        
    }
}
//    createStripeCustomAccount(email: UserManager.currentUser()!.email)
extension UserInfoRegisterViewController {
    //-- external account
    func createStripeCustomAccount(_ email: String,
                                   _ addressLine: String,
                                   _ city: String,
                                   _ state: String,
                                   _ zip: String,
                                   _ ssn: String){
//        "business_profile[mcc]"=5734
//        "business_profile[url]" =
       StripeManager.createConnectAccountToken(ssn: ssn, line1: addressLine, city: city, state: state, zipcode: zip) { token, error in
            if let error = error {
               print(error.localizedDescription)
                 self.showAlertWithError(title: "", message: "Invalid User Information")
            } else if let token = token {
               StripeManager.shared.createStripeCustomAccount(email: email, country: "US", connectAccountToken: token){(result,error) in
                    if let error = error{
                        self.showAlertWithError(title: "", message: error.message ?? "Invalid User Information")
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
                print("Can not register stripe custom account id", error.message ?? "")
             }else{
                 DispatchQueue.main.async {
                    UserDefaults.standard.set(customAccountId, forKey: "StripeCustomAccountId")
                    print("go to payment gateway")
                        let storyboard = UIStoryboard(name: "withdraw", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "WithdrawViewController") as! WithdrawViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    print("Register stripe custom account id successfully")
                 }
             }
         }
    }
    //---Customer
    func createStripeCustomer(email: String, name: String){
        StripeManager.shared.createStripeCustomer(email, name){(result,error) in
            if let error = error{
                self.showAlertWithError(title: "Stripe Customer", message: error.message ?? "")
            }else{
                guard let stripeCustomerId = result["stripeCustomerId"] else { return }
                self.uploadStripeCustomerId(customerId: stripeCustomerId)
            }
        }
    }
    func uploadStripeCustomerId(customerId: String){
        DataBaseManager.shared.updateUserPaymentEmail(paymentEmail: customerId) {(error) in
            if let error = error {
                print("Can not register stripe customer id", error.message ?? "")
            }else{
                DispatchQueue.main.async {
                    UserDefaults.standard.set(customerId, forKey: "StripeCustomerId")
                    print("Register stripe customer successfully")
                }
            }
        }
    }
    func transitionNav(to controller: UIViewController) {
        transition.duration = 0.1

        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom

        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
}

extension UserInfoRegisterViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.layoutIfNeeded()
        if textField == txtSSN{
            if ssnResView == true {
                ssnResView = false
                let storyboard = UIStoryboard(name: "withdraw", bundle: nil)
                let ssnResVC = storyboard.instantiateViewController(withIdentifier: "SSNResViewController") as! SSNResViewController
                ssnResVC.transitioningDelegate = self
                ssnResVC.interactor = interactor
                
                transitionNav(to: ssnResVC)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range,  in: text){
            let finaltext = text.replacingCharacters(in: textRange, with: string)
            if textField == txtZip{
                if zipMax > 0, zipMax < finaltext.utf8.count{
                    return false
                }
            }
            if textField == txtSSN{
                if ssnMax > 0, ssnMax < finaltext.utf8.count{
                    return false
                }
            }
        }
        return true
    }
}

