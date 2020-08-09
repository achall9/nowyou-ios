//
//  StripeBaseViewController.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MaterialComponents
class StripeBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addRigthSwipe()
        // Do any additional setup after loading the view.
    }
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
       if (sender.direction == .right) {
           navigationController?.popViewController(animated: true)
           print("Swipe right")
       }
    }

    func setBtnUI(btn: UIButton, radius: CGFloat){
        btn.layer.cornerRadius = radius
        btn.clipsToBounds = true
    }

    func setMDCTextField(txtField: MDCTextField, mInoutController :MDCTextInputControllerOutlined){
        txtField.textColor = UIColor.black
        txtField.backgroundColor = UIColor.clear
        txtField.clearButtonMode = .never
//        txtField.delegate = self
        mInoutController.borderFillColor = UIColor.white
        mInoutController.normalColor = UIColor.gray
        mInoutController.activeColor = UIColor.gray
        mInoutController.inlinePlaceholderColor = UIColor.black
        mInoutController.floatingPlaceholderActiveColor = UIColor.black
    }
}

