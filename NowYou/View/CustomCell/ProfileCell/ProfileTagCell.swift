//
//  ProfileTagCell.swift
//  NowYou
//
//  Created by 111 on 5/31/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class ProfileTagCell: UICollectionViewCell {
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var container: UIView!
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTag.text = ""
    }
}
