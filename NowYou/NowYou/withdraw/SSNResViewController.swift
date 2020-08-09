//
//  SSNResViewController.swift
//  NowYou
//
//  Created by 111 on 4/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class SSNResViewController: StripeBaseViewController {
    
    
    @IBOutlet weak var stripeImg: UIImageView!
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var roundedView: UIView!
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stripeImg.setRoundCorner(radius: 4)
        cardImg.setRoundCorner(radius: 4)
        roundedView.setRoundCorner(radius: 10)
    }
    
    @IBAction func onDone(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
}
