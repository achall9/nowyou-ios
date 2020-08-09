//
//  CameraRollCell.swift
//  NowYou
//
//  Created by Apple on 1/25/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class CameraRollCell: UICollectionViewCell {
    
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblLength: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imgThumbnail.image = nil
    }
}
