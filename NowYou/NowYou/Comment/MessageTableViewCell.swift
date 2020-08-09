//
//  MessageTableViewCell.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderLbl: UILabel!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var containerVIew: UIView!
    
    
    @IBOutlet weak var imgLike: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        msgLbl.numberOfLines = 0
        msgLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        msgLbl.sizeToFit()
        avatarImg.setCornerRadius()
        containerVIew.setRoundCorner(radius: 10.0)
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



//class MessageTableViewCell: UITableViewCell {
//
//    @IBOutlet weak var msgLbl: UILabel!
//    @IBOutlet weak var quoteLbl: UILabel!
//    @IBOutlet weak var avatarImg: UIImageView!
//    @IBOutlet weak var timeLbl: UILabel!
//
//    @IBOutlet weak var likeBtn: UIButton!
//    @IBOutlet weak var commentBtn: UIButton!
//    @IBOutlet weak var deleteBtn: UIButton!
//
//    @IBOutlet weak var receiverNameLbl: UILabel!
//
//    @IBOutlet weak var imgLike: UIImageView!
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        quoteLbl.numberOfLines = 0
//        quoteLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
//        quoteLbl.sizeToFit()
//
//        msgLbl.numberOfLines = 0
//        msgLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
//        msgLbl.sizeToFit()
//        avatarImg.setCornerRadius()
//        quoteLbl.superview?.setRoundCorner(radius: 6)
////        quoteLbl.font =  quoteLbl.font.italic
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//}
