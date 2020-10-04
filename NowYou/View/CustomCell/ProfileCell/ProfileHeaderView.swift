//
//  ProfileHeaderView.swift
//  NowYou
//
//  Created by Apple on 1/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate {
    func followBtnPressed()
    func blockBtnPressed()
}

class ProfileHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblFollowerCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    
    @IBOutlet weak var lblViewCount: UILabel!
    
    @IBOutlet weak var btnFollow: NYView!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var btnBlock: NYView!
    @IBOutlet weak var blockBtn: UIButton!
    
    @IBOutlet weak var lineAllPosts: UIView!
    @IBOutlet weak var lineTaggedPosts: UIView!
    

    var delegate: ProfileHeaderViewDelegate?
    
    @IBOutlet weak var imgBorderView: AngleGradientBorderView!
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
        
        imgProfile.setCircular()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        imgProfile.image = nil
    }
    
    @IBAction func onFollowBtnPressed(_ sender: Any) {
        delegate?.followBtnPressed()
    }
    
    @IBAction func onBackBtnPressed(_ sender: Any) {
        delegate?.blockBtnPressed()
    }
    
}
