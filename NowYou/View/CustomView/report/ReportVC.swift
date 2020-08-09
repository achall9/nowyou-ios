//
//  ReportVC.swift
//  NowYou
//
//  Created by 111 on 2/27/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ReportVC: UIViewController {

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var txtReport: UITextView!
    
    var postId: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.
    }
    func configureUI(){
        
        buttonUI(btnView: btnSubmit)
        buttonUI(btnView: btnCancel)
    }

    func buttonUI(btnView: UIButton){
        btnView.layer.cornerRadius = 6
        btnView.clipsToBounds = true
//        btnView.layer.borderWidth = 2
//        btnView.layer.borderColor = UIColor(hexValue: 0xFFFFF).cgColor
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func onSubmit(_ sender: Any) {
        if txtReport.text == nil {
            self.present(Alert.alertWithTextInfo(errorText: "Please Check Report Content!"), animated: true, completion: nil)
            return
        }else if txtReport.text == "" {
            self.present(Alert.alertWithTextInfo(errorText: "PPlease Check Report Content!"), animated: true, completion: nil)
            return
        }
        DataBaseManager.shared.reportAPost(content: txtReport.text, postId: postId) {(error) in
            if error != nil {
                print("Report Faild")
            }else{
                NotificationCenter.default.post(name: .reportedPostSuccessfully, object: nil, userInfo: nil)
                print("Succeesfully Reported")
            }
        }
        
       self.dismiss(animated: false, completion: nil)
    }
}
extension ReportVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
           textField.font = UIFont(name: "Gilroy-Bold", size: 21)
       }
       
       func textFieldDidEndEditing(_ textField: UITextField) {
           textField.font = UIFont(name: "Gilroy-Bold", size: 17)
       }
}

extension Notification.Name {
    static let reportedPostSuccessfully
        = Notification.Name("ReportedPostSuccessfully")
}
