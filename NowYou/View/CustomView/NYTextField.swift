//
//  NowYouTextField.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class NYTextField: UITextField {

    let padding     = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    convenience init()
    {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup()
    {
        self.textAlignment          = .left
        self.autocapitalizationType = .none
        self.autocorrectionType     = .no
        self.returnKeyType          = .go
        
        self.layer.cornerRadius     = 4
        self.layer.borderWidth      = 1
        self.layer.borderColor      = NYColors.NYBorderColor().cgColor
        self.clipsToBounds          = true
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect
    {
        return bounds.inset(by: padding)
    }

}
