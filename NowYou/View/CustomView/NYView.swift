//
//  ShadowView.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class NYView: UIView {

    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowY: CGFloat = -3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var shadowBlur: CGFloat = 3 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var spread: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews()
    {
        self.layer.cornerRadius     = cornerRadius
        self.layer.shadowColor      = shadowColor.cgColor
        self.layer.shadowOffset     = CGSize(width: shadowX, height: shadowY)
        self.layer.shadowRadius     = shadowBlur
        self.layer.shadowOpacity    = 1
        self.layer.borderColor      = borderColor.cgColor
        self.layer.borderWidth      = borderWidth
        
        let rect                    = bounds.insetBy(dx: -spread, dy: -spread)
        self.layer.shadowPath       = UIBezierPath(rect: rect).cgPath
    }

}
