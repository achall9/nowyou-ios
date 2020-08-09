//
//  FollowCell.swift
//  NowYou
//
//  Created by Apple on 1/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {

    @IBOutlet weak var vDetails: NYView!
    @IBOutlet weak var imgLogo: UIImageView!
   
    @IBOutlet weak var lblFollowName: UILabel!
    
    var followPerson: User? {
        didSet {
            imgLogo.sd_setImage(with: URL(string: Utils.getFullPath(path: followPerson!.userPhoto)), placeholderImage: PLACEHOLDER_IMG, options: .delayPlaceholder, completed: nil)
            lblFollowName.text = followPerson?.username
            
            imgLogo.contentMode = .scaleAspectFill
            imgLogo.layer.cornerRadius = imgLogo.frame.height / 2
            imgLogo.layer.borderWidth = 1
            imgLogo.layer.borderColor = UIColor(hexValue: 0xAAAAAA).withAlphaComponent(0.5).cgColor
            imgLogo.layer.backgroundColor = UIColor(hexValue: 0xFFFFFF).cgColor
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgLogo.image = nil
        lblFollowName.text = ""
    }
}


