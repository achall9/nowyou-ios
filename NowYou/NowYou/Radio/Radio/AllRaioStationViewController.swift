//
//  AllRaioStationViewController.swift
//  NowYou
//
//  Created by 111 on 2/5/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class AllRaioStationViewController:BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var tblAllRadioStations: UITableView!
    var interactor = Interactor()
    var radioStations = [RadioStation]()
    var radioVC: RadioViewController?
    var transition = CATransition()
    var radioStationIdOnBroadCasting : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblAllRadioStations.register(UINib(nibName: "RadioStationCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioStationCell")
        NotificationCenter.default.addObserver(self, selector: #selector(getRadioStationIdOnBroadCasting(notification:)), name: .radioIsOnBroadcastingNotification, object: nil)
        addRigthSwipe()
    }

    func addRigthSwipe(){
           let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
           rightSwipe.direction = .right
           view.addGestureRecognizer(rightSwipe)
       }
   @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
      if (sender.direction == .right) {
           navigationController?.popViewController(animated: true)
           print("Swipe right")
      }
   }
    @objc func getRadioStationIdOnBroadCasting( notification: Notification){
        let userInfo = notification.userInfo
        radioStationIdOnBroadCasting = userInfo!["radioStationId"] as! Int
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchRadioStations()
        tblAllRadioStations.reloadData()
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    func transitionNavMode(to controller: UIViewController) {
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc func refresh(notification: Notification) {
        searchRadioStations()
        tblAllRadioStations.reloadData()
    }
    
    func searchRadioStations() {
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
         NetworkManager.shared.popularRadioStations(limit: 100) { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()

                switch response {
                case .error( _):
                        self.present(Alert.alertWithText(errorText: "Please try again later when there are radio live stations available. Thanks!"), animated: true, completion: nil)
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
                                self.tblAllRadioStations.reloadData()
                            }
                    } catch {
                        
                    }
                }
            }
        }
    }
}
        // MARK: - Table view data source
extension AllRaioStationViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                tableView.isScrollEnabled = true
                return radioStations.count
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if radioStations.count > 8 {
                return tableView.frame.height / 8
            }
            
            if Utils.isIPhoneX() {
                return 812 * 0.0839 + 16
            } else {
                return 667 * 0.0839 + 16
            }
        }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if radioStationIdOnBroadCasting == radioStations[indexPath.row].id{
            let vc = UIViewController.viewControllerWith("RadioDetailsVC") as! RadioDetailsViewController
            vc.radio = radioStations[indexPath.row]
            vc.transitioningDelegate = self
            vc.interactor = interactor
            transitionNavMode(to: vc)
        }else{
            let vc = UIViewController.viewControllerWith("RecordedRadioPlayViewController") as! RecordedRadioPlayViewController
            vc.radio = radioStations[indexPath.row]
            vc.transitioningDelegate = self
            vc.interactor = interactor
            transitionNavMode(to: vc)
        }
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if scrollView.contentOffset.y < -10 {
                scrollView.contentOffset = CGPoint(x: 0, y: -10)
            } else if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
                scrollView.contentOffset.y = scrollView.contentSize.height - scrollView.frame.size.height
            }
        }
        
    }
