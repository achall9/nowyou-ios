//
//  FeedProfileCell.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class FeedProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var borderView: AngleGradientBorderView!

    var isSeen: Bool = false {
        didSet {

        }
    }
    
    override var bounds: CGRect {
        didSet {
            imgProfile.contentMode = .scaleAspectFill
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgProfile.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgProfile.layer.cornerRadius = imgProfile.frame.height / 2
        imgProfile.layer.borderWidth = 1
        imgProfile.layer.borderColor = UIColor(hexValue: 0xAAAAAA).withAlphaComponent(0.5).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgProfile.image = nil
        imgPoster.image = nil
        lblName.text = ""
        
    }
}
