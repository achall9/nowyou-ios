//
//  LinkAttachViewController.swift
//  NowYou
//
//  Created by Apple on 1/30/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import WebKit

protocol LinkAttachDelegate {
    func selectedLink(string: String?, selectedFrame: Int)
}

class LinkAttachViewController: UIViewController {

    @IBOutlet weak var txtLink: UITextField!
    @IBOutlet weak var btnAttach: UIButton!
    @IBOutlet weak var wkWebView: WKWebView!
    
    @IBOutlet weak var attachBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachBtnWidthConstraint: NSLayoutConstraint!
    
    var delegate: LinkAttachDelegate?
    
    var prevLink: String?
    
    var isEditingLink: Bool = true
    
    var selectedFrame: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtLink.becomeFirstResponder()
        
        wkWebView.layer.cornerRadius = 6
        wkWebView.clipsToBounds = true
        
        attachBtnHeightConstraint.constant = 32
        attachBtnWidthConstraint.constant = 32
        btnAttach.setImage(UIImage(named: "NY_post_link"), for: .normal)
        
        if let link = prevLink {
            if let url = URL(string: link) {
                txtLink.text = link
                wkWebView.load(url)
                wkWebView.isHidden = false
            }            
        } else {
            wkWebView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        wkWebView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnAttach.layer.borderColor = UIColor.white.cgColor
        btnAttach.layer.borderWidth = 1.0
        btnAttach.setCircular()
    }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//        if textField.text?.isEmpty ?? true {
//            attachBtnHeightConstraint.constant = 16
//            attachBtnWidthConstraint.constant = 16
//            btnAttach.setImage(UIImage(named: "NY_close"), for: .normal)
//        } else {
//            attachBtnHeightConstraint.constant = 32
//            attachBtnWidthConstraint.constant = 32
//            btnAttach.setImage(UIImage(named: "NY_post_link"), for: .normal)
//        }
//    }
    
    @IBAction func onAttach(_ sender: Any) {
        view.endEditing(true)
        
        if let text = txtLink.text {
            if text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("www.") || text.lowercased().hasPrefix("https://"){
                delegate?.selectedLink(string: text, selectedFrame: selectedFrame)
            } else {
                let fixedText = "https://" + text
                delegate?.selectedLink(string: fixedText, selectedFrame: selectedFrame)
            }
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: "Please enter valid URL", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        if let text = txtLink.text {
            if text.hasPrefix("http://") || text.hasPrefix("www.") || text.hasPrefix("https://"){
                delegate?.selectedLink(string: text, selectedFrame: selectedFrame)
            }else {
                let fixedText = "https://" + text
                delegate?.selectedLink(string: fixedText, selectedFrame: selectedFrame)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension LinkAttachViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditingLink = true
        
//        attachBtnHeightConstraint.constant = 16
//        attachBtnWidthConstraint.constant = 16
//        btnAttach.setImage(UIImage(named: "NY_close"), for: .normal)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditingLink = false
        
    }
    
    func textFieldShouldReturn(_ textField:
        UITextField) -> Bool {
        
        view.endEditing(true)
        
        if txtLink.text?.isEmpty ?? true {
            return true
        }
        if let url = URL(string: txtLink.text ?? "") {
            wkWebView.load(url)
            wkWebView.isHidden = false
        } else {
            let alert = UIAlertController(title: nil, message: "Please enter a valid URL", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        return false
    }
}

extension WKWebView {
    func load(_ url: URL) {
        let request = URLRequest(url: url)
        load(request)
    }
}

