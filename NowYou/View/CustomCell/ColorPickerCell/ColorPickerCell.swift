//
//  ColorPickerCell.swift
//  NowYou
//
//  Created by Apple on 4/21/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ColorPickerCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorView.setCircular()
    }
}
