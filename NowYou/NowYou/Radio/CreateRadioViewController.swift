//
//  CreateRadioViewController.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import WSTagsField

class CreateRadioViewController: BaseViewController, StreamCompletionDelegate {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblCategoryName: UILabel!
    
    @IBOutlet weak var imgCategoryLogo: UIImageView!
    
    @IBOutlet weak var txtRadioTitle: UITextField!
    
    var category: RadioCategory!
    var radio : RadioStation!
    
    fileprivate let tagsField = WSTagsField()
    
    @IBOutlet weak var tagsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
     
        initTagsView()
        self.checkMicPermission()
    }
    
    func initTagsView() {
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)
        
        tagsField.cornerRadius = 3.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10
        
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //old padding
        
        tagsField.placeholder = "Enter a tag"
        tagsField.placeholderColor = .red
        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = NYColors.NYOrange()// .lightGray
        tagsField.returnKeyType = .next
        tagsField.delimiter = ""
        tagsField.keyboardAppearance = .dark
        
        tagsField.textDelegate = self
        
        textFieldEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnStart.setCircular()
        imgCategoryLogo.setCircular()
        
        tagsField.frame = tagsView.bounds
    }
    
    func initUI() {
        lblCategoryName.text = category.name
        imgCategoryLogo.sd_setImage(with: category.logo, placeholderImage: UIImage(named: "NY_logo"), options: .highPriority, completed: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? StreamViewController {
            dest.radio = radio
        }
    }

    @IBAction func onAddTitle(_ sender: Any) {
        txtRadioTitle.becomeFirstResponder()
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onStartbroadcast(_ sender: Any) {
        
        let title = txtRadioTitle.text
        
        guard title != nil || !title!.isEmpty else {
            return
        }
        
        let tags = tagsField.tags
        
        guard tags.count > 0 else {
            self.present(Alert.alertWithTextInfo(errorText: "Please add at least 1 hash tag"), animated: true, completion: nil)
            return
        }
        
        if self.checkMicPermission() == false {
            return
        }
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
                
        NetworkManager.shared.createNewRadioStation(category_id: category.id!, name: txtRadioTitle.text!, hash_tag: tags) { (response) in
            
            DispatchQueue.main.async {
                Utils.hideSpinner()
            }
            
            switch response {
            case .error(let error):
                DispatchQueue.main.async {
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                }
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    if let json = jsonRes as? [String: Any] {
                        if let radioId = json["radio_station_id"] as? Int {
                            // ask mic permission
                            if self.checkMicPermission() {
                                // go to broadcast screen

                                DispatchQueue.main.async {
                                    if Utils.checkMicPermission() {
                                        self.getRadioStationInfo(radioId)
                                    }
                                }                                
                            }                            
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
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
                        self.performSegue(withIdentifier: "toStream", sender: radioStationId)
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
    
    // MARK: - StreamCompletionDelegate
    
    func streamCompleted() {
        navigationController?.popViewController(animated: false)
    }
    
    fileprivate func textFieldEvents() {
        tagsField.onDidAddTag = { _, _ in
            print("onDidAddTag")
        }
        
        tagsField.onDidRemoveTag = { _, _ in
            print("onDidRemoveTag")
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
    }
}

extension CreateRadioViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagsField {
            
        }
        return true
    }
    
}
