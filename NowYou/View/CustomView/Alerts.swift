//
//  Alerts.swift
//  NowYou
//
//  Created by Apple on 1/3/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class Alert: NSObject {
    class func alertWithText(errorText: String?,
                             title: String                        = "Error",
                             cancelTitle: String                  = "OK",
                             cancelAction: (() -> Void)?          = nil,
                             otherButtonTitle: String?            = nil,
                             otherButtonStyle: UIAlertAction.Style = .default,
                             otherButtonAction: (() -> Void)?     = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: errorText, preferredStyle: .alert)
        
        let handler = cancelAction == nil ? { () -> Void in } : cancelAction
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (alertAction: UIAlertAction!) in handler!() })
        alertController.addAction(cancelAction)
        
        if otherButtonTitle != nil && !otherButtonTitle!.isEmpty &&
            otherButtonAction != nil {
            let otherAction = UIAlertAction(title: otherButtonTitle!, style: otherButtonStyle, handler: { (alertAction: UIAlertAction!) in otherButtonAction!() })
            alertController.addAction(otherAction)
        }
        
        return alertController
    }
    
    class func alertWithTextInfo(errorText: String?,
                                 title: String                        = "",
                                 cancelTitle: String                  = "OK",
                                 cancelAction: (() -> Void)?          = nil,
                                 otherButtonTitle: String?            = nil,
                                 otherButtonStyle: UIAlertAction.Style = .default,
                                 otherButtonAction: (() -> Void)?     = nil) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: errorText, preferredStyle: .alert)
        
        let handler = cancelAction == nil ? { () -> Void in } : cancelAction
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (alertAction: UIAlertAction!) in handler!() })
        alertController.addAction(cancelAction)
        
        if otherButtonTitle != nil && !otherButtonTitle!.isEmpty &&
            otherButtonAction != nil {
            let otherAction = UIAlertAction(title: otherButtonTitle!, style: otherButtonStyle, handler: { (alertAction: UIAlertAction!) in otherButtonAction!() })
            alertController.addAction(otherAction)
        }
        
        return alertController
    }
}
