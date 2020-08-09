//
//  AddCardViewController.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MaterialComponents
import DatePickerDialog
class AddCardViewController: StripeBaseViewController {
    @IBOutlet weak var mCardHolderName: MDCTextField!
    @IBOutlet weak var mCardNo: MDCTextField!
    @IBOutlet weak var mExpireDate: MDCTextField!
    @IBOutlet weak var mCVC: MDCTextField!
    @IBOutlet weak var mAddress: MDCTextField!
    @IBOutlet weak var mState: MDCTextField!
    @IBOutlet weak var mZipCode: MDCTextField!
    @IBOutlet weak var mCity: MDCTextField!
    
    @IBOutlet weak var btnSaveCardInfo: MDCButton!
    private var cardNameController: MDCTextInputControllerOutlined?
    private var cardNoController: MDCTextInputControllerOutlined?
    private var expireDateController: MDCTextInputControllerOutlined?
    private var cVCController: MDCTextInputControllerOutlined?
    private var addressController: MDCTextInputControllerOutlined?
    private var stateController: MDCTextInputControllerOutlined?
    private var zipCodeController: MDCTextInputControllerOutlined?
    private var cityController: MDCTextInputControllerOutlined?
    let cvcMax  = 4
    let cardNoMax = 16
    let zipcodeMax = 6
    
    var cardNo : String  = ""
    var cvc: String = ""
    var cardHolderName: String = ""
    var address: String = ""
    var state: String = ""
    var zipCode: String  = ""
    var city: String = ""
    
    var expDate : Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI(){
        mCardNo.delegate = self
        mCVC.delegate = self
        mZipCode.delegate = self
        mExpireDate.delegate = self
        setBtnUI(btn: btnSaveCardInfo, radius: 16)
        
        cardNameController = MDCTextInputControllerOutlined(textInput: mCardHolderName)
        setMDCTextField(txtField: mCardHolderName, mInoutController: cardNameController!)
        
        cardNoController = MDCTextInputControllerOutlined(textInput: mCardNo)
        setMDCTextField(txtField: mCardNo, mInoutController: cardNoController!)
        
        expireDateController = MDCTextInputControllerOutlined(textInput: mExpireDate)
        setMDCTextField(txtField: mExpireDate, mInoutController: expireDateController!)

        cVCController = MDCTextInputControllerOutlined(textInput: mCVC)
        setMDCTextField(txtField: mCVC, mInoutController: cVCController!)

        addressController = MDCTextInputControllerOutlined(textInput: mAddress)
        setMDCTextField(txtField: mAddress, mInoutController: addressController!)

        stateController = MDCTextInputControllerOutlined(textInput: mState)
        setMDCTextField(txtField: mState, mInoutController: stateController!)

        zipCodeController = MDCTextInputControllerOutlined(textInput: mZipCode)
        setMDCTextField(txtField: mZipCode, mInoutController: zipCodeController!)
        
        cityController = MDCTextInputControllerOutlined(textInput: mCity)
        setMDCTextField(txtField: mCity, mInoutController: cityController!)
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onSaveCardInfo(_ sender: Any) {
        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
//        let stripeCustomerId = UserDefaults.standard.object(forKey: "StripeCustomerId") as? String ?? ""
        if mCardNo.text == nil ||  mCardNo.text == ""{
          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Number!"), animated: true, completion: nil)
          return
        }else{
            cardNo = mCardNo.text ?? ""
        }
        if mCVC.text == nil || mCVC.text == "" {
          self.present(Alert.alertWithTextInfo(errorText: "Please Check CVC!"), animated: true, completion: nil)
          return
        }else {
            cvc = mCVC.text ?? ""
        }
        if mCardHolderName.text == nil || mCardHolderName.text == ""{
          self.present(Alert.alertWithTextInfo(errorText: "Please Check Card Holder Name!"), animated: true, completion: nil)
          return
        }else {
            cardHolderName = mCardHolderName.text ?? ""
        }
        if mAddress.text == nil || mAddress.text == "" {
          self.present(Alert.alertWithTextInfo(errorText: "Please Check Addreess line!"), animated: true, completion: nil)
          return
        }else{
            address = mAddress.text ?? ""
        }
        if mState.text == nil || mState.text == ""{
          self.present(Alert.alertWithTextInfo(errorText: "Please Check State!"), animated: true, completion: nil)
          return
        }else{
            state = mState.text ?? ""
        }
        if mZipCode.text == nil || mZipCode.text == ""{
          self.present(Alert.alertWithTextInfo(errorText: "Please Check ZipCode!"), animated: true, completion: nil)
          return
        }else{
            zipCode = mZipCode.text ?? ""
        }
        if mCity.text == nil || mCity.text == "" {
          self.present(Alert.alertWithTextInfo(errorText: "Please Check City!"), animated: true, completion: nil)
          return
        }else{
            city = mCity.text ?? ""
        }
        let cardExpArray:[String] = mExpireDate.text!.components(separatedBy: "/")
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        StripeManager.shared.addCard(
            customAccountId: stripeCustomAccountId,
            number: cardNo,
            exp_month: Int(cardExpArray[0])!,
            exp_year: Int(cardExpArray[1])!,
            cvc: cvc,
            currency: "usd",
            name: cardHolderName,
            address_line1: address,
            address_city: city,
            address_state: state,
            address_country: "US",
            address_zip: zipCode)
        {(result,error) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            if let error = error{
                self.showAlertWithError(title: "", message: error.message  ?? "Your card number is incorrect")
            }else{
                print(result)
                self.navigationController?.popViewController(animated: false)
            }
        }
        }
    }

    @IBAction func setExpDate(_ sender: Any) {
        DatePickerDialog().show("Expiration Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/yyyy"
                self.mExpireDate.text = formatter.string(from: dt)
            }
        }
    }
}

extension AddCardViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mCVC {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let finalText = text.replacingCharacters(in: textRange, with: string)
                if self.cvcMax > 0, self.cvcMax < finalText.utf8.count {
                    return false
                }
            }
        }
        if textField == mCardNo {
           if let text = textField.text, let textRange = Range(range, in: text) {
               let finalText = text.replacingCharacters(in: textRange, with: string)
               if self.cardNoMax > 0, self.cardNoMax < finalText.utf8.count {
                   return false
               }
           }
        }
        if textField == mZipCode {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let finalText = text.replacingCharacters(in: textRange, with: string)
                if self.zipcodeMax > 0, self.zipcodeMax < finalText.utf8.count {
                    return false
                }
            }
        }
        if textField == mExpireDate{
            let num:NSString = mExpireDate.text! as NSString
            if num.length == 1
            {
               mExpireDate.text = NSString(format:"%@%@/",num,string) as String
               return false;
            }
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            return updatedText.count <= 7
        }
    return true
  }
}
