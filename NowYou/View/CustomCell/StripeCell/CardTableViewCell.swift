//
//  CardTableViewCell.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblExpDate: UILabel!
    
    @IBOutlet weak var btnDelete: UIButton!
    var stripeCard: StripeCard? {
        didSet {
            lblCardNo.text = stripeCard?.last4
            lblExpDate.text = String(stripeCard?.exp_month as! Int) + "/" + String(stripeCard?.exp_year as! Int)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.setRoundCorner(radius: 5)
        btnDelete.alpha = 0.0
        btnDelete.setRoundCorner(radius: 3)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
