//
//  PaymentRegister.swift
//  userId_fle
//
//  Created by os4ed on 3/22/19.
//  Copyright © 2019 os4ed. All rights reserved.
//

import UIKit
//import SVProgressHUD
//import Alamofire

class PaymentRegister: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name1: UITextField!
    
    @IBOutlet weak var name2: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var passCon: UITextField!
    
    @IBOutlet weak var scrl: UIScrollView!
    
    
    @IBOutlet weak var register_click: UIButton!
    
    
    @IBAction func register(_ sender: Any) {
        
        if name1.text == "" {
        }else if name2.text == ""
        {
        }
        else if ( email.text == ""){
//        }else if !validation().isValidEmail(testStr: email.text!){
        }else if pass.text == "" {
        }else if passCon.text == "" {
        }else if passCon.text == pass.text
        {
            submitAction()
            
        }else{

        }
    }
    
    func submitAction(){

        let parameters = ["first_name": name1.text!, "last_name": name2.text!, "email": email.text!, "password": pass.text!,
            "location": "", "latitude": "0.0", "longitude":"0.0"]
        
        print(parameters)

    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        name1.delegate = self
        name2.delegate = self
        location.delegate = self
        email.delegate = self
        pass.delegate = self
        passCon.delegate = self
        register_click.layer.cornerRadius = 6.0
        register_click.clipsToBounds = true
//        name1.underlined()
//        name2.underlined()
//        email.underlined()
//        location.underlined()
//        pass.underlined()
//        passCon.underlined()
        
        scrl.contentSize = CGSize.init(width: 0, height: 650)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
