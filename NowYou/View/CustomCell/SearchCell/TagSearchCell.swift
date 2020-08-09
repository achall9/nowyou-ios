//
//  TagSearchCell.swift
//  Bucket
//
//  Created by gstream on 7/5/18.
//  Copyright © 2018 Bucket. All rights reserved.
//

import UIKit

class TagSearchCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageBorderView: UIView!
    @IBOutlet weak var tagLbl: UILabel!
    @IBOutlet weak var postsCountLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
