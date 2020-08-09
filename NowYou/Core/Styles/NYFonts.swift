//
//  NYFonts.swift
//  NowYou
//
//  Created by Apple on 12/25/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

public struct NYFonts
{
    public enum Weight: Int
    {
        case light = 0
        case regular
        case medium
        case bold
        case heavy
    }
    
    static func sourceGilroy(size: CGFloat = 12.0, weight: Weight = .regular) -> UIFont
    {
        let name: String
        
        switch(weight)
        {
        case .light:
            name = "Gilroy-Light"
        case .bold:
            name = "Gilroy-Bold"
        case .heavy:
            name = "Gilroy-Heavy"
        case .medium:
            name = "Gilroy-Medium"
        default:
            name = "Gilroy-Regular"
        }
        
        return UIFont(name: name, size: size)!
    }
    
    public static func attributedTextStyle(font: UIFont, color: UIColor = UIColor.black, alignment: NSTextAlignment = .left, lineBreakMode: NSLineBreakMode = .byTruncatingTail, lineSpacing: CGFloat = 1.0) -> [NSAttributedString.Key : Any]
    {
        
        let style:NSMutableParagraphStyle   = NSMutableParagraphStyle()
        style.paragraphSpacing              = 0.0
        style.alignment                     = alignment
        style.lineBreakMode                 = lineBreakMode
        style.lineSpacing                   = lineSpacing
        
        return [NSAttributedString.Key.paragraphStyle: style,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font]
    }
}
