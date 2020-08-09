//
//  Utilities.swift
//  NowYou
//
//  Created by 111 on 2/14/20.
//  Copyright © 2020 Apple. All rights reserved.
//


import Foundation
import UIKit

class Utilities {
    static func styleTextField(_ textfield : UITextField){
        let bottomLine = CALayer()
        // Create the bottom line
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        //Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
    }
    
    static func styleLabel(_ label : UILabel){
        let bottomLine = CALayer()
        // Create the bottom line
        bottomLine.frame = CGRect(x: 0, y: label.frame.height - 2, width: label.frame.width, height: 2)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        // Add the line to the text field
        label.layer.addSublayer(bottomLine)
    }
    
    static func styleLabelLeft(_ label : UILabel){
        let leftLiine = CALayer()
        leftLiine.frame = CGRect(x: 0, y: 0, width: 4, height: label.frame.height)
        leftLiine.backgroundColor = UIColor(hexValue: 0x0B691C).cgColor
        label.layer.addSublayer(leftLiine)
    }
    static func styleLabelRight(_ label : UILabel){
        let rightLine = CALayer()
        rightLine.frame = CGRect(x: label.frame.width - 4, y: 0, width: 4, height: label.frame.height)
        rightLine.backgroundColor = UIColor(hexValue: 0x0B691C).cgColor

        label.layer.addSublayer(rightLine)
    }
}
