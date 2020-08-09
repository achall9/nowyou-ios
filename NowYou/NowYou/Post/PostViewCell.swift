//
//  PostViewCell.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ActiveLabel

class PostViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    
    @IBOutlet weak var lblLink: ActiveLabel!
    
    @IBOutlet weak var imgBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnMute: UIButton!
    
    @IBOutlet weak var lblViewsCount: UILabel!
    @IBOutlet weak var linkLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeBtnTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressContainer: UIStackView!
    @IBOutlet weak var progressTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black
//        imageView.contentMode = .scaleToFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
