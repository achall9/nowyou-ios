//
//  AddAdditionalAccountVC.swift
//  NowYou
//
//  Created by mobiledev coach on 9/6/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CropViewController

class AddAdditionalAccountVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtBio: UITextView!
    
    var imagePicker = UIImagePickerController()
    var photoUpdated: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        self.imgProfile.setCircular()
    }
    
    
    
    //MARK: Add additional account
    @IBAction func addAction(_ sender: UIButton) {
        let alert = self.verifyFields()
        if alert == "Success" {
            // Do network manager
            DispatchQueue.main.async {
                Utils.showSpinner()
            }
            
            let main_user_id = "\(UserManager.currentUser()!.userID!)"
            let first_name = self.txtFirstName.text!
            let last_name = self.txtLastName.text!
            let user_name = self.txtUsername.text!
            let password = self.txtPassword.text!
            let bio = self.txtBio.text!
            let photo = self.imgProfile.image!.pngData()!
            
            NetworkManager.shared.createAdditionalAccount(main_user_id: main_user_id, first_name: first_name, last_name: last_name, user_name: user_name, password: password, bio: bio, photo: photo) { (response) in
                
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
                                if let token = jsonObject["token"] as? String {
                                    TokenManager.saveToken(token: token)
                                }
                                if let userJSON = jsonObject["user"] as? [String: Any] {
                                    let user = User(json: userJSON)
                                    
                                    let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
                                    UserDefaults.standard.set(encodedUser, forKey: USER_INFO)

                                    NotificationManager.shared.storeToken()
                                    NetworkManager.shared.follow(userId: 41, completion: { (response) in
                                        DispatchQueue.main.async {
                                            let app = UIApplication.shared.delegate as! AppDelegate
                                            app.window?.rootViewController = UIViewController.viewControllerWith("homeVC")

                                        }
                                    })
                                    
                                } else {
                                    self.present(Alert.alertWithText(errorText: "An account already exists with this email or phone number."), animated: true, completion: nil)
                                    self.navigationController?.popViewController(animated: false)
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
            
        } else {
            self.present(Alert.alertWithTextInfo(errorText: alert), animated: true, completion: nil)
        }
    }
    
    func verifyFields() -> String {
        if self.txtFirstName.text == "" {
            return "Please input the first name"
        } else if self.txtLastName.text == "" {
            return "Please input the last name"
        } else if self.txtUsername.text == "" {
            return "Please input the username"
        } else if self.txtPassword.text == "" {
            return "Please input the password"
        } else {
            return "Success"
        }
    }
    
    
    //MARK: Photo
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
    
    
    
    @IBAction func changePhotoAction(_ sender: UIButton) {
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
    
    //MARK: BACK
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}




extension AddAdditionalAccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
extension AddAdditionalAccountVC: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.imgProfile.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}
//--- End Crop image
