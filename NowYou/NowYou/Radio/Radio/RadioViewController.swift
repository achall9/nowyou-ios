//
//  RadioViewController.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class RadioViewController: BaseViewController, RadioSearchDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    


    @IBOutlet weak var btnCloseTutor: UIButton!
    @IBOutlet weak var btnCreateNew: UIButton!
    @IBOutlet weak var vLogo: UIView!
    @IBOutlet weak var btnViewAll: UIButton!
    //    var cateOrRadiStation : Bool = true
    var radioContainer: RadioContainerViewController?
    
    let interactor = Interactor()
    let transition = CATransition()
    
    @IBOutlet weak var radioIntroIV: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        radioIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
        let radioShown = UserDefaults.standard.bool(forKey: "radioShown")
        if !radioShown {
            radioIntroIV.alpha = 1.0
            btnCloseTutor.alpha = 1.0
            UserDefaults.standard.set(true, forKey: "radioShown")
            btnCloseTutor.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vLogo.layer.borderColor = UIColor(hexValue: 0xBABABA).cgColor
        vLogo.layer.borderWidth = 0
        initButtonUI()
         self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
               
        NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
    }
               
    @objc func openTutor(notification: Notification){
       radioIntroIV.alpha = 1.0
       btnCloseTutor.alpha = 1.0
       UserDefaults.standard.set(true, forKey: "radioShown")
       btnCloseTutor.isEnabled = true
    }
    @objc func closeTutor(notification: Notification){
        radioIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
    }
    
    @IBAction func onClickViewAll(_ sender: Any) {
        NotificationCenter.default.post(name: .viewAllListOfCaterotyOrRadioStation, object: self)
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
       tutorClosePostNotification()
     }
    func initButtonUI(){
        btnViewAll.layer.cornerRadius = 6
        btnViewAll.layer.masksToBounds = true
        btnViewAll.layer.borderWidth = 1
        btnViewAll.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.4).cgColor
        btnViewAll.setTitleColor(UIColor.white, for: .normal)
        btnViewAll.backgroundColor = UIColor(hexValue: 0x60DF76)
    }


    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func onSearch(_ sender: Any) {
        
        let radioSearch = Utils.viewControllerWith("RadioSearchViewController") as! RadioSearchViewController
        radioSearch.categories = radioContainer?.childCategories?.categories ?? [RadioCategory]()
        radioSearch.searchDelegate = self
        
        radioSearch.transitioningDelegate = self
        radioSearch.interactor = interactor
        
        transition(to: radioSearch)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContainer" {
            if let vc = segue.destination as? RadioContainerViewController {
                vc.radioVc = self
                self.radioContainer = vc
            }
        } else if segue.identifier == "toRadios" {
            let vc = segue.destination as! SubRadioViewController
            vc.category = sender as? RadioCategory
            vc.categories = radioContainer?.childCategories?.categories ?? [RadioCategory]()
            vc.transitioningDelegate = self
            vc.interactor = interactor
        } else if segue.identifier == "toRadioDetail" {
            let vc = segue.destination as! RadioDetailsViewController
            //vc.radio = sender as? Radio
            vc.radio = sender as? RadioStation
            vc.transitioningDelegate = self
            vc.interactor = interactor
        }
    }
    
    // MARK: - Animation
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return DismissAnimator()
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactor.hasStarted
                ? interactor
                : nil
    }
    
    func transitionPush(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        
        transition.subtype = CATransitionSubtype.fromRight
        
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        
        transition.subtype = CATransitionSubtype.fromRight
        
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }

    func setNYViewActive(nyView: NYView, color: UIColor) {
        
        nyView.backgroundColor  = color
        nyView.shadowColor      = color
    }
    
    // MARK: RadioSearch Delegate
    func categorySelected(_ category: RadioCategory, sender: RadioSearchViewController?) {
        sender?.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "toRadios", sender: category)
        })
    }
    
    func radioSelected(_ radio: RadioStation, sender: RadioSearchViewController?) {
        sender?.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "toRadioDetail", sender: radio)
        })
    }
 
    @IBAction func createCategoryOrRadio(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateNewRadioStationViewController") as! CreateNewRadioStationViewController
            navigationController?.pushViewController(vc, animated: false)
    }
    
}

extension RadioViewController: NewCategoryDelegate1,NewCategoryDelegate2 {
    func createdCategoy(category: RadioCategory) {
        // post notification for refresh category table
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED), object: nil, userInfo: ["category": category])
        
        print("Notification Post")
    }
}
//extension RadioViewController: NewCategoryDelegate2 {
//    func createdCategoy(category: RadioCategory) {
//        // post notification for refresh category table
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED), object: nil, userInfo: ["category": category])
//    }
//}
extension Notification.Name {
    static let viewAllListOfCaterotyOrRadioStation = Notification.Name("ViewAllListOfCaterotyOrRadioStation")
}
