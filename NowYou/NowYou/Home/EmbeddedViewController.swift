//
//  EmbeddedViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

// add more cases if needed
enum Position {
    case Center
    case Top
    case Bottom
    case Left
    case Right
}

protocol EmbeddedViewControllerDelegate: class {
    
    // delegate to provide information about other containers
    func isContainerActive(position: Position) -> Bool
    
    // delegate to handle containers events
    func onProfile(sender: AnyObject)
    func onDone(sender: AnyObject)
    func onShowContainer(position: Position, sender: AnyObject)
}

class EmbeddedViewController: BaseViewController {
    
    weak var delegate: EmbeddedViewControllerDelegate?
}
