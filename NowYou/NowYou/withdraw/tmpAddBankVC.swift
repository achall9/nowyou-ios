////
////  AddBankViewController.swift
////  NowYou
////
////  Created by 111 on 2/29/20.
////  Copyright © 2020 Apple. All rights reserved.
////
//
//import UIKit
//import MaterialComponents
//class AddBankViewController: StripeBaseViewController {
//
//    @IBOutlet weak var mAccountHolderName: MDCTextField!
//    @IBOutlet weak var mBankName: MDCTextField!
//    @IBOutlet weak var mAccountNumber: MDCTextField!
//    @IBOutlet weak var mRoutingNumber: MDCTextField!
//
//    @IBOutlet weak var btnSaveBankInfo: UIButton!
//    
//    
//    private var bankHolderNameController: MDCTextInputControllerOutlined?
//    private var bankNameController: MDCTextInputControllerOutlined?
//    private var accountNumberController: MDCTextInputControllerOutlined?
//    private var routingNumberController: MDCTextInputControllerOutlined?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        // Do any additional setup after loading the view.
//    }
//    
//    @IBAction func onBack(_ sender: Any) {
//        navigationController?.popViewController(animated: false)
//    }
//    
//    func configureUI(){
//        setBtnUI(btn: btnSaveBankInfo, radius: 16)
//
//        bankHolderNameController = MDCTextInputControllerOutlined(textInput: mAccountHolderName)
//        setMDCTextField(txtField: mAccountHolderName, mInoutController: bankHolderNameController!)
//        
//        accountNumberController = MDCTextInputControllerOutlined(textInput: mAccountNumber)
//        setMDCTextField(txtField: mAccountNumber, mInoutController: accountNumberController!)
//        
//        bankNameController = MDCTextInputControllerOutlined(textInput: mBankName)
//        setMDCTextField(txtField: mBankName, mInoutController: bankNameController!)
//        
//        routingNumberController = MDCTextInputControllerOutlined(textInput: mRoutingNumber)
//        setMDCTextField(txtField: mRoutingNumber, mInoutController: routingNumberController!)
//    }
//
//    @IBAction func onSaveBankInfo(_ sender: Any) {
//        
//        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
////        let stripeCustomerId = UserDefaults.standard.object(forKey: "StripeCustomerId") as? String ?? ""
//        if mAccountNumber.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Account Number!"), animated: true, completion: nil)
//          return
//        }else if mAccountNumber.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Account Number"), animated: true, completion: nil)
//          return
//        }
//        if mRoutingNumber.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Routing Number!"), animated: true, completion: nil)
//          return
//        }else if mRoutingNumber.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Routing Number!"), animated: true, completion: nil)
//          return
//        }
//        if mAccountHolderName.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Account Holder Name!"), animated: true, completion: nil)
//          return
//        }else if mAccountHolderName.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Account Holder Name!"), animated: true, completion: nil)
//          return
//        }
//        if mBankName.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Bank Name!"), animated: true, completion: nil)
//          return
//        }else if mBankName.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Bank Name!"), animated: true, completion: nil)
//          return
//        }
//        StripeManager.shared.addBank(customAccountId: stripeCustomAccountId, accountNumber: mAccountNumber.text!, routingNumber: mRoutingNumber.text!, accountHolderName: mAccountHolderName.text!, bankName: mBankName.text!)
//            {(result,error) in
//               if let error = error{
//                   self.showAlertWithError(title: "", message: error.message!)
//               }else{
//                   print(result)
//                   DispatchQueue.main.async {
//                       self.navigationController?.popViewController(animated: false)
//                   }
//               }
//           }
////        StripeManager.shared.addBank(customerId: stripeCustomerId, accountNumber: mAccountNumber.text!, routingNumber: mRoutingNumber.text!, accountHolderName: mAccountHolderName.text!, bankName: mBankName.text!){(result,error) in
////            if let error = error{
////                self.showAlertWithError(title: "", message: error.message!)
////            }else{
////                print(result)
////                DispatchQueue.main.async {
////                    self.navigationController?.popViewController(animated: false)
////                }
////            }
////        }
//    }
//}
