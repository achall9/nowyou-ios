//
//  ProfilePostCell.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ProfilePostCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var imgVideoMark: UIImageView!
    
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgPost.translatesAutoresizingMaskIntoConstraints = false
        imgPost.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgPost.image = nil
        imgPost.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgPost.contentMode = .scaleAspectFill
    }
}
