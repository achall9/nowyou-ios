//
//  SubRadioViewController.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class SubRadioViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate, RadioSearchDelegate {

    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var vLogo: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var tblRadios: UITableView!
    
    @IBOutlet weak var btnPlus: UIButton!
    
    var category: RadioCategory!
    
    var radios = [RadioStation]()
    var categories = [RadioCategory]()
    
    var totalViewCount: Int = 0

    var interactor = Interactor()
    var transition = CATransition()
    var radioStationIdOnBroadCasting : Int = 0
    
    @IBOutlet weak var emptyVideo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tblRadios.register(UINib(nibName: "RadioStationCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioStationCell")
        
        initUI()
        
        tblRadios.alwaysBounceVertical = false
        tblRadios.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(getRadioStationIdOnBroadCasting(notification:)), name: .radioIsOnBroadcastingNotification, object: nil)
//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//        recognizer.delegate = self
//        view.addGestureRecognizer(recognizer)
    }

    @objc func getRadioStationIdOnBroadCasting( notification: Notification){
        let userInfo = notification.userInfo
        radioStationIdOnBroadCasting = userInfo?["radioStationId"] as? Int ?? 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadRadio()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        DispatchQueue.main.async {
            self.tblRadios.reloadData()
        }        
    }
    
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.5
        let translation = sender.translation(in: view)
        let fingerMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor.hasStarted = true
//            dismiss(animated: true)
            
        case .changed:
            
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
            
        case .cancelled:
            
            interactor.hasStarted = false
            interactor.cancel()
            
        case .ended:
            
            interactor.hasStarted = false
            
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
    
    func loadRadio() {
        // load radio
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
   
        NetworkManager.shared.getRadiosByCategory(category_id: category.id!) { (response) in
             DispatchQueue.main.async {
                 Utils.hideSpinner()
             }
             
             switch response {
             case .error(let error):
                 DispatchQueue.main.async {
                     self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                 }
             case .success(let data):
                 do {
                     let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                     
                     if let json = jsonRes as? [String: Any], let radioJson = json["radio_stations"] as? [[String: Any]] {

                         self.radios.removeAll()
                         
                         for radio in radioJson {
                             let radioObj = RadioStation(json: radio)
                             self.radios.append(radioObj)
                         }
                         
                         self.totalViewCount = json["total_view_count"] as? Int ?? 0
                         
                         DispatchQueue.main.async {
                             if self.radios.count > 0 {
                                 
                                 self.emptyVideo.isHidden = true
                             } else {
                                 self.emptyVideo.isHidden = false
                             }
                             
                             self.tblRadios.reloadData()
                             
                             self.lblViewCount.text = "\(self.totalViewCount)"
                         }
                     }
                 } catch {
                     
                 }
             }
         }
    }
    
    func initUI() {
        
        btnPlus.isHidden = true
        btnPlus.isEnabled = false
        
        lblCategory.text = category.name
        
        btnPlay.layer.borderWidth = 1
        btnPlay.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        btnPlay.setCircular()
        
        vLogo.layer.borderColor = UIColor(hexValue: 0x744AF2).cgColor
        vLogo.layer.borderWidth = 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CreateRadioViewController {
            vc.category = category
        } else if segue.identifier == "toDetails" {
            if let vc = segue.destination as? RadioDetailsViewController {
                if let radio = sender as? RadioStation {
                    vc.radio = radio
                }
            }
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
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        
        transition.subtype = CATransitionSubtype.fromRight
        
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let radioSearch = Utils.viewControllerWith("RadioSearchViewController") as! RadioSearchViewController
        radioSearch.categories = self.categories
//        radioSearch.top100 = radios
        radioSearch.searchDelegate = self
        
        radioSearch.transitioningDelegate = self
        radioSearch.interactor = interactor
        
        transition(to: radioSearch)
//        self.present(radioSearch, animated: true, completion: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: RadioSearch Delegate
    func categorySelected(_ category: RadioCategory, sender: RadioSearchViewController?) {
        sender?.dismiss(animated: false, completion: {
            self.lblCategory.text = category.name
            self.category = category
            self.loadRadio()
        })
    }
    
    func radioSelected(_ radio: RadioStation, sender: RadioSearchViewController?) {
        sender?.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "toDetails", sender: radio)
        })
    }
    
//    func selectedCategory(category: RadioCategory) {
//
//    }
//
//    func selectedTopRadio(radio: Radio) {
//        performSegue(withIdentifier: "toDetails", sender: radio)
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension SubRadioViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return radios.count //> 6 ? 6 : radios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioStationCell", for: indexPath) as! RadioStationCell
        
        cell.radioStation = radios[indexPath.row]
        
        Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))
        
        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if radios.count > 6 {
            return tableView.frame.height / 6
        }
        
        return view.frame.height * 0.0839 + 16
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if radioStationIdOnBroadCasting == radios[indexPath.row].id{
            performSegue(withIdentifier: "toDetails", sender: radios[indexPath.row])
        }else{
            let vc = UIViewController.viewControllerWith("RecordedRadioPlayViewController") as! RecordedRadioPlayViewController
            vc.radio = radios[indexPath.row]
            vc.transitioningDelegate = self
            vc.interactor = interactor
            transition(to: vc)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
/*        if scrollView.contentOffset.y < -10 {
            scrollView.contentOffset = CGPoint(x: 0, y: -10)
        } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height + 10 {
            if (scrollView.contentSize.height - scrollView.frame.size.height) > 0 {
                scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.size.height)
            }
            
        } */
    }
}
