//
//  UILabel+Extension.swift
//  NowYou
//
//  Created by Apple on 1/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension UILabel {
    
    func boldRange(_ range: Range<String.Index>) {
        if let text = self.attributedText {
            let attr = NSMutableAttributedString(attributedString: text)
            let start = text.string.distance(from: text.string.startIndex, to: range.lowerBound)
            let length = text.string.distance(from: range.lowerBound, to: range.upperBound)
            attr.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: NSMakeRange(start, length))
            self.attributedText = attr
        }
    }
    
    func boldSubstring(_ substr: String) {
        if let text = self.attributedText {
            var range = text.string.range(of: substr)
            let attr = NSMutableAttributedString(attributedString: text)
            while range != nil {
                let start = text.string.distance(from: text.string.startIndex, to: range!.lowerBound)
                let length = text.string.distance(from: range!.lowerBound, to: range!.upperBound)
                var nsRange = NSMakeRange(start, length)
                let font = attr.attribute(NSAttributedString.Key.font, at: start, effectiveRange: &nsRange) as! UIFont
                if !font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    break
                }
                range = text.string.range(of: substr, options: NSString.CompareOptions.literal, range: range!.upperBound..<text.string.endIndex, locale: nil)
            }
            if let r = range {
                boldRange(r)
            }
        }
    }
}
