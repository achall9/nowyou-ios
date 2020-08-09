//
//  PeopleSearchCell.swift
//  Bucket
//
//  Created by gstream on 7/5/18.
//  Copyright © 2018 Bucket. All rights reserved.
//

import UIKit

class PeopleSearchCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
