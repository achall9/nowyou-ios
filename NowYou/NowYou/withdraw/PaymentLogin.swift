//
//  PaymentLogin.swift
//  userId_fle
//
//  Created by os4ed on 3/20/19.
//  Copyright © 2019 os4ed. All rights reserved.
//

import UIKit
//import SVProgressHUD
//import Alamofire
class PaymentLogin: UIViewController, UITextFieldDelegate {
    
  
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var user: UITextField!
    
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var login_click: UIButton!
    
    @IBOutlet weak var forgot_click: UIButton!
    
    @IBOutlet weak var reg_click: UIButton!
    @IBAction func login(_ sender: Any) {
    
        if  ((user.text?.isEmpty)! || (pass.text?.isEmpty)!)
        {

        }else
        {
//            SVProgressHUD.show(withStatus: "Signing In...")
            submitAction()
        }
    
    }
    @IBAction func forgot(_ sender: Any) {
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "PaymentForgotPasswordVC") as! PaymentForgotPasswordVC
        self.navigationController?.pushViewController(nav, animated: true)
    }
    
    @IBAction func reg(_ sender: Any) {
        
        let nav = self.storyboard?.instantiateViewController(withIdentifier: "PaymentRegister") as! PaymentRegister
//        nav.str_name = "Success user ID"
        self.navigationController?.pushViewController(nav, animated: true)
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
 
    var user_id:String!
    var index:Int!
    var data:NSArray = []

    override func viewDidLoad() {
       
        super.viewDidLoad()
        user.text = ""
        pass.text = ""

        user.delegate = self
        pass.delegate = self
        
//        user.underlined()
//        pass.underlined()
        login_click.layer.cornerRadius = 6.0
        login_click.clipsToBounds = true
        reg_click.layer.cornerRadius = 6.0
        reg_click.clipsToBounds = true

        //str_email = dict!["email"]
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCustomer(){
    }
    
    func submitAction(){
    }

}

