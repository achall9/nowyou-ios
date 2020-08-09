//
//  RadioCategoryCell.swift
//  NowYou
//
//  Created by Apple on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class RadioCategoryCell: UITableViewCell {

    @IBOutlet weak var vDetails: NYView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    
    var category: RadioCategory? {
        didSet {
            imgLogo.sd_setImage(with: category?.logo, placeholderImage: UIImage(named: "NY_logo"), options: .highPriority,
                                     completed: nil)
            imgLogo.contentMode = .scaleAspectFill
            imgLogo.layer.cornerRadius = imgLogo.frame.height / 2
            imgLogo.layer.borderWidth = 1
            imgLogo.layer.borderColor = UIColor(hexValue: 0xAAAAAA).withAlphaComponent(0.5).cgColor
            imgLogo.layer.backgroundColor = UIColor(hexValue: 0xFFFFFF).cgColor
            
            lblCategory.text = category?.name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgLogo.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgLogo.image = nil
        lblCategory.text = ""
    }
}
