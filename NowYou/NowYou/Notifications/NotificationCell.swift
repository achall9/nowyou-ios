//
//  NotificationCell.swift
//  NowYou
//
//  Created by Apple on 3/25/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import ActiveLabel
import LocalizedTimeAgo

class NotificationCell: UITableViewCell {

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblTxt: ActiveLabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var notificatiaon: NotificationObj? {
        didSet {
            if let photo = notificatiaon?.sender_photo {
                self.imgPhoto?.sd_setImage(with: URL(string: photo), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
            }
            
            var notificationBody: String = ""
            switch notificatiaon!.action {
            
            case .Comment:
                notificationBody = "@\(notificatiaon!.sender_name!) commended on your post."
            case .Like:
                notificationBody = "@\(notificatiaon!.sender_name!) liked your post."
            case .Follow:
                notificationBody = "@\(notificatiaon!.sender_name!) started following you."
            }
            
            lblTxt.customize { (label) in
                label.text = notificationBody
                
                let signup              = "@\(notificatiaon!.sender_name!)"
                let customTypeSignup    = ActiveType.custom(pattern: "\\s\(signup)\\b")
                label.enabledTypes      = [customTypeSignup]
                
                label.customColor[customTypeSignup] = UIColor.blue
                
                label.highlightFontName = "Gilroy-Bold" //NYFonts.sourceGilroy(size: 14, weight: .bold)
                label.highlightFontSize = 14.0
                
                label.handleCustomTap(for: customTypeSignup, handler: { (element) in
                    print ("clicked")
                })
            }
            
            lblTime.text = notificatiaon?.time?.shortTimeAgo()
            
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

}
