//
//  CreateNewCategoryViewController.swift
//  NowYou
//
//  Created by Apple on 1/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol NewCategoryDelegate1 {
    func createdCategoy(category: RadioCategory)
}

class CreateNewCategoryViewController: BaseViewController {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var vName: NYView!
    @IBOutlet weak var vCreate: NYView!

    @IBOutlet weak var txtName: UITextField!
    var imagePicker = UIImagePickerController()

    var delegate: NewCategoryDelegate1?

    var interactor = Interactor()
    var transition = CATransition()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//
//        view.addGestureRecognizer(recognizer)

        initUI()
        addRigthSwipe()
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
    func initUI() {
        setNYViewActive(nyView: vName, active: false, color: UIColor.clear)
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

            interactor.hasStarted = true
            dismiss(animated: true)

        case .changed:

            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)

        case .cancelled:

            interactor.hasStarted = false
            interactor.cancel()

        case .ended:

            interactor.hasStarted = false

            if interactor.shouldFinish {
                interactor.finish()
            } else {
                interactor.cancel()
            }

        default:
            break
        }
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

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            setNYViewActive(nyView: vName, active: false, color: UIColor.clear)
        } else {
            setNYViewActive(nyView: vName, active: true, color: NYColors.NYGreen())
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

    @IBAction func onChooseLogo(_ sender: Any) {
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

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onCreate(_ sender: Any) {
        if txtName.text == nil {
            self.present(Alert.alertWithTextInfo(errorText: "Please Check Category Name!"), animated: true, completion: nil)
            return
        }else if txtName.text == "" {
            self.present(Alert.alertWithTextInfo(errorText: "Please Check Category Name!"), animated: true, completion: nil)
            return
        }
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.createCategory(name: txtName.text!, logo: (imgLogo.image?.pngData())!) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            switch response {
            case .error(let error):
                print("5555",error.localizedDescription)
                self.present(Alert.alertWithText(errorText: error.localizedDescription + "Try again"), animated: true, completion: nil)
                break
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let json = jsonRes as? [String: Any], let categoryStr = json["category"] as? [String: Any] {
                        let category = RadioCategory(json: categoryStr)
                        self.delegate?.createdCategoy(category: category)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED) , object: category)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED2) , object: category, userInfo: ["created" : category.name])
                        
                        self.sendBroadcastForCategory(category)
                    }
                } catch {
                    self.present(Alert.alertWithText(errorText: "Failed, Try again"), animated: true, completion: nil)
                }
                }
            }
        }
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func sendBroadcastForCategory(_ category:RadioCategory){
        NotificationManager.shared.getTokens { (tokens) in
            for token in tokens {
                NotificationManager.shared.sendPush(token: token, title: "Category", message: "Created \(category.name)", action_event: [:], userId: "\(UserManager.currentUser()?.userID ?? -1)", success: {
                    print("Successfully sent")
                }) { (error) in
                    print(error)
                }
            }
        }
    }
}

extension CreateNewCategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Bold", size: 16)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Medium", size: 14)
    }
}

extension CreateNewCategoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: false, completion: nil)

        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgLogo.image = pickedImage.fixedOrientation()?.resized(toWidth: 300)
        }
    }
}

