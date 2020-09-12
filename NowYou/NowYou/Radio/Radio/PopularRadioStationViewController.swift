//
//  PopularRadioStationViewController.swift
//  NowYou
//
//  Created by 111 on 1/15/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CRRefresh
class PopularRadioStationViewController: BaseTableViewController, IndicatorInfoProvider,UIViewControllerTransitioningDelegate  {
        
    var itemInfo = IndicatorInfo(title: "Popular Radio Stations")
    var interactor = Interactor()
    var radioStations = [RadioStation]()
    var transition = CATransition()
    var radioVC: RadioViewController?
    var viewAllState : Bool = false
    var radioStationIdOnBroadCasting : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "RadioStationCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioStationCell")
        viewAllState = false
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: NEW_RADIO_STATION_ADDED), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(viewAllList(notification:)), name: .viewAllListOfCaterotyOrRadioStation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getRadioStationIdOnBroadCasting(notification:)), name: .radioIsOnBroadcastingNotification, object: nil)
       let firstTimeUser = UserDefaults.standard.bool(forKey: "firstTimeRadio")
       if firstTimeUser {
           showOnBoarding()
       } else {
        
       }
    }
//    NotificationCenter.default.addObserver(self, selector: #selector(getRadioStationIdOnBroadCasting(notification:)), name: .radioIsOnBroadcastingNotification, object: nil)
    @objc func getRadioStationIdOnBroadCasting( notification: Notification){
        guard let userInfo = notification.userInfo else{
            return
        }
        
        if let id =  Int(userInfo["radioStationId"] as! String) {
            radioStationIdOnBroadCasting = id
        }
    }
    func showOnBoarding(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewAllState = false
        super.viewWillAppear(true)
        searchRadioStations()
    }
    
    @objc func viewAllList(notification: Notification) {
        let allRadioStation = UIViewController.viewControllerWith("AllRaioStationViewController") as! AllRaioStationViewController
        allRadioStation.transitioningDelegate = self
        allRadioStation.interactor = interactor
        transitionNavMode(to: allRadioStation)
   }
    func transitionNavMode(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    @objc func refresh(notification: Notification) {
        searchRadioStations()
        tableView.reloadData()
    }
//    func showingAlert(){
//        let alert = UIAlertController(title: "", message: "No stations available. Please try again later.", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
//                if self.adTimer != nil {
//                    self.adTimer.invalidate()
//                    self.adTimer = nil
//                    }
//                self.navigationController?.popViewController(animated: true)
//        }))
//        self.present(alert,animated: true, completion: nil)
//
//    }
    func searchRadioStations() {
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
         NetworkManager.shared.popularRadioStations(limit: 100) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                    case .error(let error):
                        self.present(Alert.alertWithText(errorText: "No stations available. Please try again later."), animated: true, completion: nil)
                        break
                    case .success(let data):
                        do {
                            let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            
                            if let json = jsonRes as? [String: Any], let radioJson = json["popular_radio_stations"] as? [[String: Any]] {
                                
                                self.radioStations.removeAll()
                                
                                for radio in radioJson {
                                    if radio["radios"] != nil{
                                        let radioObj = RadioStation(json: radio)
                                        self.radioStations.append(radioObj)
                                        print(radio["radios"]!)
                                    }else{
                                         print("No audio")
                                    }
                                }
                                self.radioStations.reverse()
                                self.tableView.reloadData()
                            }
                    } catch {
                        
                    }
                }
            }
        }
    }
    
        // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if viewAllState == true {
                tableView.isScrollEnabled = true
                return radioStations.count
            } else{
                tableView.isScrollEnabled = false
                return radioStations.count > 6 ? 6 : radioStations.count
            }
        }
        
         override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioStationCell", for: indexPath) as! RadioStationCell
         
            cell.radioStation = radioStations[indexPath.row]
            
             if indexPath.row % 6 == 0 {
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x60DF76))
                   } else if indexPath.row % 7 == 1 {
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xFBAE5D))
                   } else if indexPath.row % 7 == 2 {
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x4AB3F2))
                   } else if indexPath.row % 7 == 3 {
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xF0CF3F))
                   } else if indexPath.row % 7 == 4 {
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xE58DD2))
                   } else{
                       Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744AF2))
                   }
            
            return cell
         }
        
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if radioStations.count > 6 {
                return tableView.frame.height / 6
            }
            
            if Utils.isIPhoneX() {
                return 812 * 0.0839 + 16
            } else {
                return 667 * 0.0839 + 16
            }
            
            
            
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            if radioStationIdOnBroadCasting == radioStations[indexPath.row].id{
                radioVC?.performSegue(withIdentifier: "toRadioDetail", sender: radioStations[indexPath.row])
            }else{
                let vc = UIViewController.viewControllerWith("RecordedRadioPlayViewController") as! RecordedRadioPlayViewController
                vc.radio = radioStations[indexPath.row]
                vc.transitioningDelegate = self
                vc.interactor = interactor
                transitionNavMode(to: vc)
            }
        }
        
        override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y < -10 {
                scrollView.contentOffset = CGPoint(x: 0, y: -10)
            } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
                scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
            }
        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
        func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
            return itemInfo
        }
    }
