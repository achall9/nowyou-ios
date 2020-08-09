//
//  VideoFrameCell.swift
//  NowYou
//
//  Created by Apple on 1/30/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class VideoFrameCell: UICollectionViewCell {

    var isCurrentFrame: Bool = false {
        didSet {
            if isCurrentFrame {
                imgFrame.layer.borderColor = UIColor.white.cgColor
                imgFrame.layer.borderWidth = 2.0
            } else {
                imgFrame.layer.borderWidth = 0.0
            }
        }
    }
    
    @IBOutlet weak var imgFrame: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
