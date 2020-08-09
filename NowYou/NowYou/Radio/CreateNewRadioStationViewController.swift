//
//  CreateNewRadioStationViewController.swift
//  NowYou
//
//  Created by 111 on 1/9/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import McPicker
import CRRefresh
import WSTagsField

protocol NewCategoryDelegate2 {
    func createdCategoy(category: RadioCategory)
}
class CreateNewRadioStationViewController: BaseViewController {

    @IBOutlet weak var vStart: NYView!
    @IBOutlet weak var vTag: UIView!
    @IBOutlet weak var vCategory: NYView!
    @IBOutlet weak var vTitle: NYView!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var txtTitle: UITextField!
    
    fileprivate let tagsField = WSTagsField()
    
    var radio : RadioStation!
    var interactor = Interactor()
    var transition = CATransition()
    var delegate: NewCategoryDelegate2?

    var categories = [RadioCategory]()
    var categorieNames: [[String]] = [[""]]
    var tempcategorieNames : [String] = [""]
    
    var category: RadioCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//        view.addGestureRecognizer(recognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioRecordingFinished(notification:)), name: NSNotification.Name(rawValue: NEW_AUDIO_ADDED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED2), object: nil)

        getCategory()
        setUpTag()
        initUI()
        initTagField()
        addRigthSwipe()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//         NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED2), object: nil)
//
//    }
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
    @objc func audioRecordingFinished(notification: Notification){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_RADIO_STATION_ADDED) , object: nil)
        onBack(self)
        navigationController?.popToRootViewController(animated: true)
    }
    @objc
    func refresh(notification: Notification) {
        getCategory()
        if let data = notification.userInfo as? [String:String]
        {
            let categoryName = data["created"]
            self.btnCategory.setTitle(categoryName, for: .normal)
            setNYViewActive(nyView: self.vCategory, active: true, color: NYColors.NYGreen())
            self.vTag.isHidden = false
        }
    }
    func getCategory(){
        self.categorieNames.removeAll()
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
       NetworkManager.shared.getCategories { (response) in
          DispatchQueue.main.async {
               Utils.hideSpinner()
           }
           switch response {
           case .error(let error):
            print ("Error:", error.localizedDescription)
//            self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
            break
           case .success(let data):
               do {
                   let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                   if let json = jsonRes as? [String: Any], let categories = json["categories"] as? [[String: Any]] {
                       self.categories.removeAll()
                       for category in categories {
                           let category = RadioCategory(json: category)
                           self.categories.append(category)
                        self.tempcategorieNames.insert(category.name, at: 0)
                       }
                    
                    }
               } catch {
                   print("Exception : JSON structure error")
               }
               self.tempcategorieNames.insert("Add New", at: 0)
               self.categorieNames.insert(self.tempcategorieNames, at: 0)
               
            }//------switch response end
        }//---NetworkManager.shared.getCategories
    }
    func setUpTag(){
       vTag.isHidden = true
       tagsField.frame = vTag.bounds
       vTag.layer.cornerRadius = 6.0
       vTag.clipsToBounds = true

       vTag.addSubview(tagsField)

       //tagsField.translatesAutoresizingMaskIntoConstraints = false
       //tagsField.heightAnchor.constraint(equalToConstant: 150).isActive = true

       tagsField.cornerRadius = 3.0
       tagsField.spaceBetweenLines = 10
       tagsField.spaceBetweenTags = 10

       tagsField.numberOfLines = 3
//       tagsField.maxHeight = 100.0

       tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
       tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //old padding

       tagsField.placeholder = "Enter a tag"
       tagsField.placeholderColor = .blue
       tagsField.placeholderAlwaysVisible = true
       tagsField.backgroundColor = NYColors.NYGreen()
       tagsField.returnKeyType = .continue
       tagsField.delimiter = ""

       tagsField.textDelegate = self

       textFieldEvents()
    }

    func initUI() {
        
        setNYViewActive(nyView: vTitle, active: false, color: UIColor.clear)
//        setNYViewActive(nyView: vTag, active: false, color: UIColor.clear)
        setNYViewActive(nyView: vCategory, active: false, color: UIColor.clear)
        vCategory.isHidden = true
    }
    func initTagField(){
        weak var mcTextField: McTextField?
        
        let mcInputView = McPicker(data: self.categorieNames)
        mcInputView.backgroundColor = .gray
        mcInputView.backgroundColorAlpha = 0.25
        
        mcTextField?.inputViewMcPicker = mcInputView
        mcTextField?.doneHandler = { [weak mcTextField] (selections) in
            mcTextField?.text = selections[0]!
            self.btnCategory.titleLabel!.text = mcTextField?.text
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tagsField.frame = vTag.bounds
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
                } else if let btn = subview as? UIButton{
                    btn.tintColor   = UIColor.white
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
                else if let btn = subview as? UIButton{
                    btn.tintColor   = UIColor.black
                }
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            setNYViewActive(nyView: vTitle, active: false, color: UIColor.clear)
            vCategory.isHidden = true
        } else {
            setNYViewActive(nyView: vTitle, active: true, color: NYColors.NYGreen())
            vCategory.isHidden = false
        }
    }
    func getCategoryId(categories : [RadioCategory], category_name : String) -> Int{
        for category in categories {
            if category.name == category_name{
                return category.id!
            }
        }
        return  -1
    }
    @IBAction func onStart(_ sender: Any) {
        let title = txtTitle.text
        
        if title == nil {
            self.present(Alert.alertWithTextInfo(errorText: "Please Title Name!"), animated: true, completion: nil)
            return
        }else if title == "" {
            self.present(Alert.alertWithTextInfo(errorText: "Please Title Name!"), animated: true, completion: nil)
            return
        }
        
        let tags = tagsField.tags
        
        guard tags.count > 0 else {
            self.present(Alert.alertWithTextInfo(errorText: "Please add at least 1 hash tag"), animated: true, completion: nil)
            return
        }
        
        if self.checkMicPermission() == false {
            self.present(Alert.alertWithTextInfo(errorText: "Please check microphone"), animated: true, completion: nil)
            return
        }
        let categoryId = getCategoryId(categories: categories, category_name: btnCategory.titleLabel!.text!)

        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.createNewRadioStation(category_id: categoryId, name: title!, hash_tag: tags) {(response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                    break
//                    self.dismiss(animated: true, completion: nil)
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let json = jsonRes as? [String: Any] {
                           if let radioStationId = json["radio_station_id"] as? Int {
                            self.sendBroadcastForRadioStation(title ?? "", radioStationId)
                               // ask mic permission
                            if Utils.checkMicPermission() {
                                   // go to broadcast screen
                                self.getCategory()
                                self.getRadioStationInfo(radioStationId)
                               
                                }
                            }
                        }
                    }catch {
                        self.present(Alert.alertWithText(errorText: "Faild, Try again"), animated: true, completion: nil)
                    } // end try-catch
                }//-end switch response
            }// end :  DispatchQueue.main.async {
        }//-end  NetworkManager.shared.
    }// end @IBAction func onStart(_ sender: Any)
    
    private func getRadioStationInfo(_ radioStationId:Int){
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.getRadioStation(radio_station_id: radioStationId) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            
          switch response {
          case .error( let error):
            print (error.localizedDescription)
            break
          case .success(let data):
              do {
                  let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                  if let json = jsonRes as? [String: Any], let radioJson = json["radio_station"] as? [String: Any] {

                    let radioObj = RadioStation(json: radioJson)
                      DispatchQueue.main.async {
                        self.radio = radioObj
                        let vc = UIViewController.viewControllerWith("StreamViewController") as! StreamViewController
                        vc.radio = self.radio
                        self.navigationController?.pushViewController(vc, animated: false)
                      }
                  }
              } catch {

              }
          }
        }
    }
    // check microphone permission
    func checkMicPermission() -> Bool {
        var permissionCheck: Bool = false
        
        switch AVAudioSession.sharedInstance().recordPermission {
            
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                permissionCheck = granted
            }
        case .denied:
            permissionCheck = false
        case .granted:
            permissionCheck = true
        }
        
        return permissionCheck
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        if let dest = segue.destination as? StreamViewController {
////            dest.radio = self.radio
////        }
//
////        let vc = self.storyboard!.instantiateViewController(withIdentifier: "StreamViewController") as! StreamViewController
////        vc.radio = self.radio
////        self.navigationController?.pushViewController(vc, animated: false)
//    }
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClkCategory(_ sender: Any) {
        self.view.endEditing(true)
        vCategory.isHidden = true
        
        McPicker.show(data: categorieNames, doneHandler: { [weak self] (selections: [Int:String]) in
            if let name = selections[0] {
                if name == "Add New"{
                    let vc = self?.storyboard!.instantiateViewController(withIdentifier: "CreateNewCategoryViewController") as! CreateNewCategoryViewController
                    self?.navigationController?.pushViewController(vc, animated: false)
                    self!.vCategory.isHidden = false
                }else{
                    self?.btnCategory.setTitle(name,for: .normal)
                    self!.vCategory.isHidden = false
                    self!.setNYViewActive(nyView: self!.vCategory, active: true, color: NYColors.NYGreen())
                    if self?.btnCategory.titleLabel?.text == nil{
                        return
                    }else if self?.btnCategory.titleLabel?.text == ""{
                        return
                    }else{
                        self!.vTag.isHidden = false
//                         self!.setNYViewActive(nyView: self!.vTag, active: true, color: NYColors.NYGreen())
                    }
                }
            }
        }, cancelHandler: {
            print("Canceled Default Picker")
            self.vCategory.isHidden = false
        }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) in
            let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
            print("Component \(componentThatChanged) changed value to \(newSelection)")
            self.vCategory.isHidden = false
        })
    }
    
    private func sendBroadcastForRadioStation(_ radioStationName: String, _ stationID:Int){
        let user = UserManager.currentUser()!
        NotificationManager.shared.getTokens { (tokens) in
            for token in tokens {
                NotificationManager.shared.sendPush(token: token, title: "Audio BroadCast", message: "\(user.username ?? "") is now live on \(radioStationName)", action_event: ["radioStationId":"\(stationID)","profileIconPath" : "\( Utils.getFullPath(path: user.userPhoto))"], userId: "\(user.userID ?? -1)", success: {
                    print("Successfully sent")
                }) { (error) in
                    print(error)
                }
            }
        }
    }
}

extension CreateNewRadioStationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Bold", size: 18)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.font = UIFont(name: "Gilroy-Medium", size: 16)
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // Get your textFields text
//        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        if str.last! == " "{
//            print("SPACE!")
//        }
//        else{
//            print(str.last!)
//        }
//
//        return true
//    }
}

extension CreateNewRadioStationViewController {

    fileprivate func textFieldEvents() {
        tagsField.onDidAddTag = { field, tag in
            print("onDidAddTag", tag.text)
        }

        tagsField.onDidRemoveTag = { field, tag in
            print("onDidRemoveTag", tag.text)
        }

        tagsField.onDidChangeText = { _, text in
            print("onDidChangeText")
        }

        tagsField.onDidChangeHeightTo = { _, height in
            print("HeightTo \(height)")
        }

        tagsField.onDidSelectTagView = { _, tagView in
            print("Select \(tagView)")
        }

        tagsField.onDidUnselectTagView = { _, tagView in
            print("Unselect \(tagView)")
        }

        tagsField.onShouldAcceptTag = { field in
            return field.text != "OMG"
        }
    }

}

