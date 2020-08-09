//
//  ContactCell.swift
//  NowYou
//
//  Created by Apple on 4/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    var contact: CNContact! {
        didSet {
            lblName.text = contact.givenName + " " + contact.familyName
            
            if let phoneNumber = (contact.phoneNumbers.first)?.value {
                lblPhoneNumber.text = phoneNumber.value(forKey: "digits") as? String ?? ""
            }

//            for phone in contact.phoneNumbers {
//                lblPhoneNumber.text = phone.value(forKey: "digits") as? String ?? ""
//            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        btnFollow.layer.cornerRadius = 6
        btnFollow.layer.masksToBounds = true
        btnFollow.layer.borderWidth = 1
        btnFollow.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        
    }
}
