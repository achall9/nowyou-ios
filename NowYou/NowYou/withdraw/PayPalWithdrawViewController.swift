//
//  PayPalWithdrawViewController.swift
//  NowYou
//
//  Created by 111 on 2020/9/18.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class PayPalWithdrawViewController: UIViewController {

    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        PayPalAPIManager.shared.getToken{token,error in
            if (error == nil){
                
            }
        }
        
    }

    @IBAction func onDraw(_ sender: Any) {
        guard let email = txtEmail.text else {
            showAlertWithError(title: "", message: "Please input Email")
            return
        }
        guard email.isValidEmail() else{
            showAlertWithError(title: "", message: "Email is not valid")
            return
        }
        let cashInfo = UserManager.myCashInfo()!

        var cashAmount = cashInfo.total_cash
        if (Environment.current == .development && cashAmount == 0){
            cashAmount = 3.0
        }
        if cashAmount == 0{
            showAlertWithError(title: "", message: "There is no cash in your account")
            return
        }
        btnWithdraw.isEnabled = false
        PayPalAPIManager.shared.createPayout(email: email, amount: cashAmount){[weak self]success,error in
            if (success){
                print("SUCCESS!!!")
                self?.showAlertWithError(title: "", message: "PayPal Payout succeded!")
                self?.navigationController?.popViewController(animated: true)
            }else{
                guard let err = error?.error else {
                    return
                }
                self?.btnWithdraw.isEnabled = true
                self?.showAlert(with: err)
            }
            
        }
        
    }
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
}
