//
//  SignupViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import DatePickerDialog
import FirebaseAuth

class SignupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var vName: NYView!
    @IBOutlet weak var vLastname: NYView!
    @IBOutlet weak var vPhone: NYView!
    @IBOutlet weak var vPhoneNumber: NYView!
    
    @IBOutlet weak var vYear: NYView!
    @IBOutlet weak var vMonth: NYView!
    @IBOutlet weak var vDay: NYView!
    
    @IBOutlet weak var vMale: NYView!
    @IBOutlet weak var vFemale: NYView!
   
    @IBOutlet weak var vUsername: NYView!
    
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtPhone: UITextField! // email
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtBio: UITextView!
    
    
    
    @IBOutlet weak var btnCreateAccount: UIButton!
    
    
    @IBOutlet weak var switchPrivate: UISwitch!
    @IBOutlet weak var switchTerm: UISwitch!
    var birthday: Date?
    var phoneNumber: String!
    var isMale: Bool = true
    
    @IBOutlet weak var countryCodePicker: UIPickerView!
    var countryCode = "1"
    var countryDictionary = ["USA":"1","AF":"93", "AL":"355", "DZ":"213","AS":"1", "AD":"376", "AO":"244", "AI":"1","AG":"1","AR":"54","AM":"374","AW":"297","AU":"61","AT":"43","AZ":"994","BS":"1","BH":"973","BD":"880","BB":"1","BY":"375","BE":"32","BZ":"501","BJ":"229","BM":"1","BT":"975","BA":"387","BW":"267","BR":"55","IO":"246","BG":"359","BF":"226","BI":"257","KH":"855","CM":"237","CA":"1","CV":"238","KY":"345","CF":"236","TD":"235","CL":"56","CN":"86","CX":"61","CO":"57","KM":"269","CG":"242","CK":"682","CR":"506","HR":"385","CU":"53","CY":"537","CZ":"420","DK":"45","DJ":"253","DM":"1","DO":"1","EC":"593","EG":"20","SV":"503","GQ":"240","ER":"291","EE":"372","ET":"251","FO":"298","FJ":"679","FI":"358","FR":"33","GF":"594","PF":"689","GA":"241","GM":"220","GE":"995","DE":"49","GH":"233","GI":"350","GR":"30","GL":"299","GD":"1","GP":"590","GU":"1","GT":"502","GN":"224","GW":"245","GY":"595","HT":"509","HN":"504","HU":"36","IS":"354","IN":"91","ID":"62","IQ":"964","IE":"353","IL":"972","IT":"39","JM":"1","JP":"81","JO":"962","KZ":"77","KE":"254","KI":"686","KW":"965","KG":"996","LV":"371","LB":"961","LS":"266","LR":"231","LI":"423","LT":"370","LU":"352","MG":"261","MW":"265","MY":"60","MV":"960","ML":"223","MT":"356","MH":"692","MQ":"596","MR":"222","MU":"230","YT":"262","MX":"52","MC":"377","MN":"976","ME":"382","MS":"1","MA":"212","MM":"95","NA":"264","NR":"674","NP":"977","NL":"31","AN":"599","NC":"687","NZ":"64","NI":"505","NE":"227","NG":"234","NU":"683","NF":"672","MP":"1","NO":"47","OM":"968","PK":"92","PW":"680","PA":"507","PG":"675","PY":"595","PE":"51","PH":"63","PL":"48","PT":"351","PR":"1","QA":"974","RO":"40","RW":"250","WS":"685","SM":"378","SA":"966","SN":"221","RS":"381","SC":"248","SL":"232","SG":"65","SK":"421","SI":"386","SB":"677","ZA":"27","GS":"500","ES":"34","LK":"94","SD":"249","SR":"597","SZ":"268","SE":"46","CH":"41","TJ":"992","TH":"66","TG":"228","TK":"690","TO":"676","TT":"1","TN":"216","TR":"90","TM":"993","TC":"1","TV":"688","UG":"256","UA":"380","AE":"971","GB":"44","UY":"598","UZ":"998", "VU":"678", "WF":"681","YE":"967","ZM":"260","ZW":"263","BO":"591","BN":"673","CC":"61","CD":"243","CI":"225","FK":"500","GG":"44","VA":"379","HK":"852","IR":"98","IM":"44","JE":"44","KP":"850","KR":"82","LA":"856","LY":"218","MO":"853","MK":"389","FM":"691","MD":"373","MZ":"258","PS":"970","PN":"872","RE":"262","RU":"7","BL":"590","SH":"290","KN":"1","LC":"1","MF":"590","PM":"508","VC":"1","ST":"239","SO":"252","SJ":"47","SY":"963","TW":"886","TZ":"255","TL":"670","VE":"58","VN":"84","VG":"284","VI":"340"]

    
    let interactor = Interactor()
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.switchTerm.setOn(false, animated: true)
        btnCreateAccount.isEnabled = false
        btnCreateAccount.alpha = 0.5
        
        countryCodePicker.delegate = self
        countryCodePicker.dataSource = self
        countryCodePicker.selectRow(222, inComponent: 0, animated: false)
        
    }
    
    @IBAction func onSwitchTerm(_ sender: Any) {
        if switchTerm.isOn {
            phoneNumber = txtPhoneNumber.text
            guard !txtFirstname.text!.isEmpty else {
                self.present(Alert.alertWithText(errorText: NO_FIRSTNAME), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            
            guard !txtLastname.text!.isEmpty else {
                self.present(Alert.alertWithText(errorText: NO_LASTNAME), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            
            guard Utils.isValidEmail(email: txtPhone.text) else {
                self.present(Alert.alertWithText(errorText: WRONG_EMAIL), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }

            guard let _ = birthday else {
                self.present(Alert.alertWithText(errorText: WRONG_BIRTH), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            
            guard  let _ = txtPhoneNumber.text, phoneNumber.count > 6 else {
                self.present(Alert.alertWithText(errorText: WRONG_PHONE_NUMBER), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            
            guard !txtUsername.text!.isEmpty else {
                self.present(Alert.alertWithText(errorText: WRONG_USERNAME), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            
            guard txtPassword.text == nil || !txtPassword.text!.isEmpty else {
                self.present(Alert.alertWithText(errorText: NO_PASSWORD), animated: true, completion: nil)
                self.switchTerm.setOn(false, animated: true)
                return
            }
            print("On")
            btnCreateAccount.isEnabled = true
            btnCreateAccount.alpha = 1.0
        }else{
            print("Off")
            btnCreateAccount.isEnabled = false
            btnCreateAccount.alpha = 0.5
        }
    }
    
    func initUI() {
        
        self.switchTerm.setOn(false, animated: true)
        self.switchPrivate.setOn(false, animated: true)
        
        setNYViewActive(nyView: vName, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vLastname, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vPhone, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vFemale, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vUsername, active: false, color: UIColor.clear)
        
        setNYViewActive(nyView: vYear, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vMonth, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vDay, active: false, color: UIColor.clear)
        
        setNYViewActive(nyView: vPhoneNumber, active: false, color: UIColor.clear)
        btnCreateAccount.isEnabled = false
        btnCreateAccount.alpha = 0.5
    }
    

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Choose Birthday
    
    @IBAction func onYear(_ sender: Any) {
        showDatePicker()
    }
    
    @IBAction func onMonth(_ sender: Any) {
        showDatePicker()
    }
    
    @IBAction func onDay(_ sender: Any) {
        showDatePicker()
    }
    
    private func showDatePicker() {
        let dialog = DatePickerDialog(textColor: UIColor.black, buttonColor: UIColor.black, font: UIFont.boldSystemFont(ofSize: 15), locale: nil, showCancelButton: true)
        
        dialog.show("Birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.birthday ?? Date(), minimumDate: nil, maximumDate: nil, datePickerMode: .date) { (date) in
            if let dt = date {
                
                self.birthday = dt
                
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: dt)
                let month = calendar.component(.month, from: dt)
                let day = calendar.component(.day, from: dt)
                
                self.lblYear.text   = "Year \n\n \(year)"
                self.lblMonth.text  = "Month \n\n \(month)"
                self.lblDay.text    = "Day \n\n \(day)"
                
                self.lblYear.boldSubstring("\(year)")
                self.lblMonth.boldSubstring("\(month)")
                self.lblDay.boldSubstring("\(day)")
                
                self.setNYViewActive(nyView: self.vYear, active: true, color: UIColor(hexValue: 0xF0CF3F))
                self.setNYViewActive(nyView: self.vMonth, active: true, color: UIColor(hexValue: 0xF0CF3F))
                self.setNYViewActive(nyView: self.vDay, active: true, color: UIColor(hexValue: 0xF0CF3F))
                
            }
        }
    }
    
    // MARK: - Choose Sex
    
    @IBAction func onMale(_ sender: Any) {
        setSex(isMale: true)
        isMale = true
    }
    
    @IBAction func onFemale(_ sender: Any) {
        setSex(isMale: false)
        isMale = false
    }
    
    // MARK: - Private Function
    func transitionNav(to controller: UIViewController) {
            transition.duration = 0.2
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromLeft
            view.window?.layer.add(transition, forKey: kCATransition)
            navigationController?.pushViewController(controller, animated: false)
    }
    func setNYViewActive(nyView: NYView, active: Bool, color: UIColor) {
        
        if active {
            nyView.backgroundColor  = color
            nyView.shadowColor      = color
            
            for subview in nyView.subviews {
                if let label = subview as? UILabel {
                    label.textColor = UIColor.white
                } else if let txt = subview as? UITextField {
                    txt.textColor   = UIColor.white
                }
            }
        } else {
            nyView.backgroundColor  = UIColor.clear
            nyView.shadowColor      = UIColor.clear
            
            for subview in nyView.subviews {
                if let label = subview as? UILabel {
                    label.textColor = UIColor.black
                } else if let txt = subview as? UITextField {
                    txt.textColor   = UIColor.black
                    
                    txt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

                } else if let txt = subview as? UITextView {
                    txt.textColor   = UIColor.black
                    
                }
            }
        }
    }
    
    func setSex(isMale: Bool) {
        if isMale {
            setNYViewActive(nyView: vMale, active: true, color: NYColors.NYBlue())
            setNYViewActive(nyView: vFemale, active: false, color: UIColor.clear)
        } else {
            setNYViewActive(nyView: vMale, active: false, color: UIColor.clear)
            setNYViewActive(nyView: vFemale, active: true, color: NYColors.NYPink())
        }
    }
    
    // MARK: - TextField Event
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            switch textField.tag {
            case 0:
                setNYViewActive(nyView: vName, active: false, color: UIColor.clear)
                break
            case 1:
                setNYViewActive(nyView: vLastname, active: false, color: UIColor.clear)
                break
            case 2:
                setNYViewActive(nyView: vPhone, active: false, color: UIColor.clear)
                break
            case 3:
                setNYViewActive(nyView: vUsername, active: false, color: UIColor.clear)
            case 4:
                setNYViewActive(nyView: vPhoneNumber, active: false, color: UIColor.clear)
            
            default:
                break;
            }
        } else {
            switch textField.tag {
            case 0:
                setNYViewActive(nyView: vName, active: true, color: NYColors.NYGreen())
                break
            case 1:
                setNYViewActive(nyView: vLastname, active: true, color: NYColors.NYOrange())
                break
            case 2:
                setNYViewActive(nyView: vPhone, active: true, color: NYColors.NYBlue())
                break
            case 3:
                setNYViewActive(nyView: vUsername, active: true, color: NYColors.NYPurple())
                break
            case 4:
                setNYViewActive(nyView: vPhoneNumber, active: true, color: NYColors.NYPhoneNumberColor())
             
            default:
                break;
            }
        }
    }
    
    @IBAction func onTextFocus(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            txtFirstname.becomeFirstResponder()
            break
        case 2:
            txtLastname.becomeFirstResponder()
            break
        case 3:
            txtPhone.becomeFirstResponder()
            break
        case 4:
            txtPhoneNumber.becomeFirstResponder()
          
            break
        case 5:
            txtUsername.becomeFirstResponder()
            break
        case 6:
            txtPassword.becomeFirstResponder()
            break
        default:
            break            
        }
    }
    
    @IBAction func onCreate(_ sender: Any) {
        let phoneVerifyVC = UIViewController.viewControllerWith("PhoneVerifyViewController") as! PhoneVerifyViewController
        phoneVerifyVC.phoneNum = "+" + self.countryCode + phoneNumber
        
        phoneVerifyVC.firstName = txtFirstname.text!
        phoneVerifyVC.lastName = txtLastname.text!
        phoneVerifyVC.email = txtPhone.text!
        phoneVerifyVC.password = txtPassword.text!
        phoneVerifyVC.birthday = self.birthday!
        phoneVerifyVC.gender = isMale ? "1" : "2"
        phoneVerifyVC.username = txtUsername.text!
        phoneVerifyVC.bio = txtBio.text ?? ""
        phoneVerifyVC.privateOn = switchPrivate.isOn ? 1 : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.transitionNav(to: phoneVerifyVC)
        }
    }
    
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
       // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.countryDictionary.count
    }
       
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.countryDictionary.sorted { $0.key < $1.key })[row].key
      
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.countryCode = self.countryDictionary[Array(self.countryDictionary.sorted { $0.key < $1.key })[row].key] ?? ""
        
    }
    
    

}


extension SignupViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.layoutIfNeeded()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
    
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhoneNumber {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let finalText = text.replacingCharacters(in: textRange, with: string)
                if finalText.utf8.count > 10 {
                    return false
                }
            }
        }
        return true
    }
}
