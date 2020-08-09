//
//  BankTableViewCell.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class BankTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBank: UIImageView!
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var lblBankAccountNo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    var stripeBank: StripeBank? {
        didSet {
            lblBankName.text = stripeBank?.bank_name
            lblBankAccountNo.text = stripeBank?.last4
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.setRoundCorner(radius: 5)
        btnDelete.alpha = 0
        btnDelete.setRoundCorner(radius: 3)
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
