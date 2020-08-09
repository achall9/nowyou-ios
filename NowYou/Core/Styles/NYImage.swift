//
//  SafanisIcon.swift
//  safanis2
//
//  Created by mobiledev coach on 7/11/20.
//  Copyright © 2020 ahl. All rights reserved.
//

import UIKit

class NYImage: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.white
        
    }
}
