//
//  PaymentForgotPassword.swift
//  NowYou
//
//  Created by 111 on 2/21/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

import UIKit
//import SVProgressHUD
//import Alamofire

class PaymentForgotPassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email_id: UITextField!
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var otp: UIButton!
    @IBAction func otp_click(_ sender: Any) {
        if email_id.text == ""
        {
//        }else if !validation().isValidEmail(testStr: email_id.text!)
//        {
        }else {
    //      SVProgressHUD.show()
            submitAction()
        
        }
    }
    
    func submitAction(){
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        email_id.delegate = self
//        email_id.underlined()
        otp.layer.cornerRadius = 6.0
        otp.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  Created by os4ed on 5/2/19.
//  Copyright © 2019 os4ed. All rights reserved.
//

import UIKit
//import SVProgressHUD
//import Alamofire

class PaymentForgotPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email_id: UITextField!
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var otp: UIButton!
    @IBAction func otp_click(_ sender: Any) {
        if email_id.text == ""
        {
//        }else if !validation().isValidEmail(testStr: email_id.text!)
//        {
        }else {
    //      SVProgressHUD.show()
            submitAction()
        
        }
    }
    
    func submitAction(){
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        email_id.delegate = self
//        email_id.underlined()
        otp.layer.cornerRadius = 6.0
        otp.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
