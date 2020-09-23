//
//  HomeViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    // Mark: - Properties
    /*
     * The whole magic to this implementation:
     * manipulation of the x & y constraints of the center container view wrt the BaseViewController's
     *
     * The other (top, bottom, left, right) simply constrain themselves wrt to the center container
     */
    @IBOutlet weak var btnCloseTutor: UIButton!
    // pan gesture recognizer related
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar when navigating away from this view controller.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension Notification.Name {
    static let gotoPlayViewController = Notification.Name("GoToPlayVCFromCameraVC")
}

