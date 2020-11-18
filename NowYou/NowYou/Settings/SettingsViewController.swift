//
//  SettingsViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import DatePickerDialog
import CropViewController
class SettingsViewController: BaseViewController {
    
    @IBOutlet weak var vName: NYView!
    @IBOutlet weak var vLastname: NYView!
    @IBOutlet weak var vPhone: NYView!
    
    @IBOutlet weak var vYear: NYView!
    @IBOutlet weak var vMonth: NYView!
    @IBOutlet weak var vDay: NYView!
    
    @IBOutlet weak var vMale: NYView!
    @IBOutlet weak var vFemale: NYView!
    @IBOutlet weak var vOther: NYView!
    
    
    @IBOutlet weak var vUsername: NYView!
    
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblOther: UILabel!
    
    
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtBio: UITextView!
    
        
    @IBOutlet weak var switchPrivate: UISwitch!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnColor: UIButton!
    @IBOutlet weak var btnShowTutor: UIButton!
    
    var imagePicker = UIImagePickerController()
    var birthday: Date?
    
    var isMale: Int = 1
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    var photoUpdated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnColor.layer.shadowColor = UIColor.black.cgColor
        btnColor.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btnColor.layer.shadowOpacity = 0.5
        btnColor.layer.shadowRadius = 6
        btnColor.layer.borderWidth = 1
        btnColor.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        btnColor.layer.masksToBounds = false
        addRigthSwipe()
        
        btnShowTutor.layer.cornerRadius = 6
        btnShowTutor.layer.masksToBounds = true
        btnShowTutor.layer.borderWidth = 1
        btnShowTutor.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        btnShowTutor.backgroundColor = UIColor(hexValue: 0x60DF76)
        btnShowTutor.setTitleColor(UIColor.white, for: .normal)
        
        loadUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Do any additional setup after loading the view.
        initUI()
        //loadUserInfo()
        if let color = UserManager.currentUser()?.color {
            btnColor.backgroundColor = UIColor(hexString: color)
        } else {
            btnColor.backgroundColor = UIColor.white
        }
    }
    
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
       if (sender.direction == .right) {
            transitionDismissal()
            print("Swipe right")
       }
    }
    
    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func dismiss(_ sender: Any){
    }
    
    @IBAction func onShowTutor(_ sender: Any) {
        tutorOpenPostNotification()
        transitionDismissal()
    }
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.5
        let translation = sender.translation(in: view)
        let fingerMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor?.hasStarted = true
            dismiss(animated: true)
            
        case .changed:
            
            interactor?.shouldFinish = progress > percentThreshold
            interactor?.update(progress)
            
        case .cancelled:
            
            interactor?.hasStarted = false
            interactor?.cancel()
            
        case .ended:
            
            guard let interactor = interactor else { return }
            interactor.hasStarted = false
            
            if interactor.shouldFinish {
                interactor.finish()
                updateProfile()
            } else {
                interactor.cancel()
            }
//            interactor.shouldFinish
//                ? interactor.finish()
//                : interactor.cancel()
            
        default:
            break
        }
    }
    
    func updateProfile() {
        // update profile info
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let appColor = UserManager.currentUser()?.color ?? "FFFFFF"
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.updateProfile(email: txtEmail.text!, firstName: txtFirstname.text!, lastName: txtLastname.text!, phone: UserManager.currentUser()?.phone ?? "", birthDay: (birthday != nil) ? dateFormatter.string(from: birthday!): "", photo: (imgProfile.image?.pngData())!, color: appColor, username: txtUsername.text!, gender: isMale, privateOn: switchPrivate.isOn ? 1 : 0, bio: txtBio.text) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                    break
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let jsonObject = jsonRes as? [String: AnyObject] {
                            if let userJSON = jsonObject["user"] as? [String: Any] {
                                print(userJSON)
                                let user = User(json: userJSON)
                                UserManager.updateUser(user: user)
                                
                                if self.photoUpdated {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_PHOTO_UPDATED), object: nil, userInfo: nil)
                                } else {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil, userInfo: nil)
                                }
                            }
                        }
                        break
                    } catch {
                        self.present(Alert.alertWithTextInfo(errorText: "This email already been taken. Please use another email."), animated: true, completion: nil)
                        return
                    }
                }
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func initUI() {
        setNYViewActive(nyView: vName, active: true, color: NYColors.NYGreen())
        setNYViewActive(nyView: vLastname, active: true, color: NYColors.NYOrange())
        setNYViewActive(nyView: vPhone, active: true, color: NYColors.NYBlue())
        setSex(sexType: 1)
        setNYViewActive(nyView: vUsername, active: true, color: NYColors.NYPurple())
        
        setNYViewActive(nyView: vYear, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vMonth, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vDay, active: false, color: UIColor.clear)
    }
    
    func loadUserInfo() {
        let user = UserManager.currentUser()!
        
        imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto)), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
        txtFirstname.text = user.firstName
        txtLastname.text = user.lastName
        txtUsername.text = user.username
        txtEmail.text = user.email
        txtBio.text = user.bio
        
        if user.privateOn == 1 {
            self.switchPrivate.setOn(true, animated: false)
        } else {
            self.switchPrivate.setOn(false, animated: false)
        }
        
        
        let birthdayStr = user.birthday
        let gender = user.gender
        
        if let birth = birthdayStr, !birth.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            birthday = dateFormatter.date(from: birth)!
            
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: birthday!)
            let month = calendar.component(.month, from: birthday!)
            let day = calendar.component(.day, from: birthday!)
            
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
        
        if gender == 1 { // male
            setSex(sexType: 1)
            isMale = 1
        } else if gender == 2 { // femail
            setSex(sexType: 2)
            isMale = 2
        } else { // other
            setSex(sexType: 3)
            isMale = 3
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        imgProfile.isHidden = false
    }
    
    @IBAction func onBack(_ sender: Any) {
        updateProfile()
        transitionDismissal()
    }
    
    // MARK: - Choose Birthday
    
    private func showDatePicker() {
        let dialog = DatePickerDialog(textColor: UIColor.black, buttonColor: UIColor.black, font: UIFont.boldSystemFont(ofSize: 15), locale: nil, showCancelButton: true)
        
        dialog.show("Birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", defaultDate: self.birthday ?? Date(), minimumDate: nil, maximumDate: nil, datePickerMode: .date) { (date) in
            if let dt = date {
                
                self.birthday = dt
                
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: dt)
                let month = calendar.component(.month, from: dt)
                let day = calendar.component(.day, from: dt)
                
                self.lblYear.text   = "Year \n \(year)"
                self.lblMonth.text  = "Month \n \(month)"
                self.lblDay.text    = "Day \n \(day)"
                
                self.lblYear.boldSubstring("\(year)")
                self.lblMonth.boldSubstring("\(month)")
                self.lblDay.boldSubstring("\(day)")
                
                self.setNYViewActive(nyView: self.vYear, active: true, color: UIColor(hexValue: 0xF0CF3F))
                self.setNYViewActive(nyView: self.vMonth, active: true, color: UIColor(hexValue: 0xF0CF3F))
                self.setNYViewActive(nyView: self.vDay, active: true, color: UIColor(hexValue: 0xF0CF3F))
                
            }
        }
    }
    
    @IBAction func onYear(_ sender: Any) {
        showDatePicker()
    }
    
    @IBAction func onMonth(_ sender: Any) {
        showDatePicker()
    }
    
    @IBAction func onDay(_ sender: Any) {
        showDatePicker()
    }
    
    // MARK: - Choose Sex
    
    @IBAction func onMale(_ sender: Any) {
        setSex(sexType: 1)
        isMale = 1
    }
    
    @IBAction func onFemale(_ sender: Any) {
        setSex(sexType: 2)
        isMale = 2
    }
    
    @IBAction func onOther(_ sender: UIButton) {
        setSex(sexType: 3)
        isMale = 3
    }
    
    
    // MARK: - Private Function
    
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
                    
                }
            }
        }
    }
    
    func setSex(sexType: Int) {
        initSexViews()
        if sexType == 1 {
            setNYViewActive(nyView: vMale, active: true, color: NYColors.NYBlue())
            setNYViewActive(nyView: vFemale, active: false, color: UIColor.clear)
            setNYViewActive(nyView: vOther, active: false, color: UIColor.clear)
        } else if sexType == 2 {
            setNYViewActive(nyView: vMale, active: false, color: UIColor.clear)
            setNYViewActive(nyView: vFemale, active: true, color: NYColors.NYPink())
            setNYViewActive(nyView: vOther, active: false, color: UIColor.clear)
        } else if sexType == 3 {
            setNYViewActive(nyView: vMale, active: false, color: UIColor.clear)
            setNYViewActive(nyView: vFemale, active: false, color: UIColor.clear)
            setNYViewActive(nyView: vOther, active: true, color: NYColors.NYGreen())
        }
    }
    
    func initSexViews() {
        setNYViewActive(nyView: vMale, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vFemale, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vOther, active: false, color: UIColor.clear)
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
                break
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
            default:
                break;
            }
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onChangeBgColor(_ sender: Any) {
        let colorVC = UIViewController.viewControllerWith("ColorPickerViewController") as! ColorPickerViewController
        
        self.present(colorVC, animated: true, completion: nil)
    }
    
    @IBAction func onChooseAccount(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChooseAccountVC") as! ChooseAccountVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func onChangePhoto(_ sender: Any) {
        // show picker
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        {
            UIAlertAction in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: .default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onNameChange(_ sender: Any) {
        txtFirstname.becomeFirstResponder()
    }
    
    @IBAction func onLastNameChanged(_ sender: Any) {
        txtLastname.becomeFirstResponder()
    }
    
    @IBAction func onEmailChange(_ sender: Any) {
        txtEmail.becomeFirstResponder()
    }
    
    @IBAction func onChangeUsername(_ sender: Any) {
        txtUsername.becomeFirstResponder()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TokenManager.deleteToken()
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeNav = mainStoryboard.instantiateViewController(withIdentifier: "authNav") as! UINavigationController
        
        DispatchQueue.main.async {
            appdelegate.window?.rootViewController = homeNav
        }
    }
    
    @IBAction func onDeleteAccount(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? You cannot undo this.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .default) { _ in
            
            self.deleteAccount()
        })
        alertController.addAction(UIAlertAction(title:"Cancel",style:.cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        })
               
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func deleteAccount(){
        
        // ----------------Delete acccount Spec-----------------------//
        DataBaseManager.shared.deleteUser(){ (result, error) in
            DispatchQueue.main.async {
                if error == ""{
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let homeNav = mainStoryboard.instantiateViewController(withIdentifier: "authNav") as! UINavigationController
                          
                        TokenManager.deleteToken()
                        appdelegate.window?.rootViewController = homeNav
                           
                } else{
                    print("error")
                    self.showAlertWithError(title: "Error", message: "Fail to delete account")
                }
            }
        }
    }

}


extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Bold", size: 21)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Bold", size: 17)
    }
}


extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//--- Crop image
    func presentCropViewController(_ profileImg : UIImage) {
        let image: UIImage = profileImg
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
//--- End Crop image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        picker.dismiss(animated: false, completion: nil)
        
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgProfile.image = pickedImage.fixedOrientation()?.resized(toWidth: 300)
        }
        
        presentCropViewController(self.imgProfile.image!)
        photoUpdated = true
    }
    
    
}

//--- Crop image
extension SettingsViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgProfile.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
//--- End Crop image
