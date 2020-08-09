////
////  AddCardViewController.swift
////  NowYou
////
////  Created by 111 on 2/29/20.
////  Copyright © 2020 Apple. All rights reserved.
////
//
//import UIKit
//import MaterialComponents
//import Stripe
//class AddCardViewController: StripeBaseViewController {
//    @IBOutlet weak var mCardHolderName: MDCTextField!
//    @IBOutlet weak var mCardNo: MDCTextField!
//    @IBOutlet weak var mExpireDate: MDCTextField!
//    @IBOutlet weak var mCVC: MDCTextField!
//    @IBOutlet weak var mAddress: MDCTextField!
//    @IBOutlet weak var mState: MDCTextField!
//    @IBOutlet weak var mZipCode: MDCTextField!
//    @IBOutlet weak var mCity: MDCTextField!
//
//    @IBOutlet weak var btnSaveCardInfo: MDCButton!
//    private var cardNameController: MDCTextInputControllerOutlined?
//    private var cardNoController: MDCTextInputControllerOutlined?
//    private var expireDateController: MDCTextInputControllerOutlined?
//    private var cVCController: MDCTextInputControllerOutlined?
//    private var addressController: MDCTextInputControllerOutlined?
//    private var stateController: MDCTextInputControllerOutlined?
//    private var zipCodeController: MDCTextInputControllerOutlined?
//    private var cityController: MDCTextInputControllerOutlined?
//
//    var cardToken : STPToken?
//    var stripeCustomAccountId: String = ""
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//    }
//
//    func configureUI(){
//        setBtnUI(btn: btnSaveCardInfo, radius: 16)
//
//        cardNameController = MDCTextInputControllerOutlined(textInput: mCardHolderName)
//        setMDCTextField(txtField: mCardHolderName, mInoutController: cardNameController!)
//
//        cardNoController = MDCTextInputControllerOutlined(textInput: mCardNo)
//        setMDCTextField(txtField: mCardNo, mInoutController: cardNoController!)
//
//        expireDateController = MDCTextInputControllerOutlined(textInput: mExpireDate)
//        setMDCTextField(txtField: mExpireDate, mInoutController: expireDateController!)
//
//        cVCController = MDCTextInputControllerOutlined(textInput: mCVC)
//        setMDCTextField(txtField: mCVC, mInoutController: cVCController!)
//
//        addressController = MDCTextInputControllerOutlined(textInput: mAddress)
//        setMDCTextField(txtField: mAddress, mInoutController: addressController!)
//
//        stateController = MDCTextInputControllerOutlined(textInput: mState)
//        setMDCTextField(txtField: mState, mInoutController: stateController!)
//
//        zipCodeController = MDCTextInputControllerOutlined(textInput: mZipCode)
//        setMDCTextField(txtField: mZipCode, mInoutController: zipCodeController!)
//
//        cityController = MDCTextInputControllerOutlined(textInput: mCity)
//        setMDCTextField(txtField: mCity, mInoutController: cityController!)
//    }
//
//    @IBAction func onBack(_ sender: Any) {
//        navigationController?.popViewController(animated: false)
//    }
//
//    @IBAction func onSaveCardInfo(_ sender: Any) {
//        stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
//        if mCardNo.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Number!"), animated: true, completion: nil)
//          return
//        }else if mCardNo.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Number"), animated: true, completion: nil)
//          return
//        }
//        if mCVC.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check CVC!"), animated: true, completion: nil)
//          return
//        }else if mCVC.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check CVC!"), animated: true, completion: nil)
//          return
//        }
//        if mCardHolderName.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Holder Name!"), animated: true, completion: nil)
//          return
//        }else if mCardHolderName.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Holder Name!"), animated: true, completion: nil)
//          return
//        }
//        if mAddress.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Addreess line!"), animated: true, completion: nil)
//          return
//        }else if mAddress.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check Addreess line!"), animated: true, completion: nil)
//          return
//        }
//        if mState.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check State!"), animated: true, completion: nil)
//          return
//        }else if mState.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check State!"), animated: true, completion: nil)
//          return
//        }
//        if mZipCode.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check ZipCode!"), animated: true, completion: nil)
//          return
//        }else if mZipCode.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check ZipCode"), animated: true, completion: nil)
//          return
//        }
//        if mCity.text == nil {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check City!"), animated: true, completion: nil)
//          return
//        }else if mCity.text == "" {
//          self.present(Alert.alertWithTextInfo(errorText: "Please Check City!"), animated: true, completion: nil)
//          return
//        }
//        let cardExpArray:[String] = mExpireDate.text!.components(separatedBy: "/")
//        StripeManager.shared.addCard(
//            customAccountId: stripeCustomAccountId,
//            number: mCardNo.text!,
//            exp_month: Int(cardExpArray[0])!,
//            exp_year: Int(cardExpArray[1])!,
//            cvc: mCVC.text!,
//            currency: "usd",
//            name: mCardHolderName.text!,
//            address_line1: mAddress.text!,
//            address_city: mCity.text!,
//            address_state: mState.text!,
//            address_country: "US",
//            address_zip: mZipCode.text!)
//        {(result,error) in
//            if let error = error{
//                self.showAlertWithError(title: "", message: error.message!)
//            }else{
//                print(result)
//                DispatchQueue.main.async {
//                    self.navigationController?.popViewController(animated: false)
//                }
//            }
//        }
//
//    }
//}
