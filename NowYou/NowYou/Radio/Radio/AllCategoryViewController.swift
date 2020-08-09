//
//  AllCategoryViewController.swift
//  NowYou
//
//  Created by 111 on 2/5/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import CRRefresh
class AllCategoryViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tblAllCategory: UITableView!
    var transition = CATransition()
    var interactor = Interactor()
    var categories = [RadioCategory]()
    var sendCategory :RadioCategory!
    var radioVC: RadioViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblAllCategory.register(UINib(nibName: "RadioCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCategoryCell")
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getCategories()
        tblAllCategory.reloadData()
    }
                  
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    func transitionNavMode(to controller: UIViewController) {
         transition.type = CATransitionType.fade
         transition.subtype = CATransitionSubtype.fromRight
         view.window?.layer.add(transition, forKey: kCATransition)
         navigationController?.pushViewController(controller, animated: false)
     }

        
    func getCategories() {
        
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.getCategories { (response) in
            DispatchQueue.main.async {
                Utils.hideSpinner()
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                    self.present(Alert.alertWithText(errorText: "Can't find Categories"), animated: true, completion: nil)
                    break
                case .success(let data):
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let json = jsonRes as? [String: Any], let categories = json["categories"] as? [[String: Any]] {
                            
                            self.categories.removeAll()
                            
                            for category in categories {
                                let category = RadioCategory(json: category)
                                self.categories.append(category)
                            }
                            AppManager.shared.categories = self.categories
                            self.tblAllCategory.reloadData()
                        }
                    } catch {
                        
                    }
                }
            }
        }
    }
}
     
    // MARK: - Table view data source
extension AllCategoryViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isScrollEnabled = true
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCategoryCell", for: indexPath) as! RadioCategoryCell
        if categories.count > indexPath.row {
             cell.category = categories[indexPath.row]
        }else{
            getCategories()
            print("Buffer Error, try again")
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.sendCategory = categories[indexPath.row]
        let vc = UIViewController.viewControllerWith("SubRadioViewController") as! SubRadioViewController
        vc.category = self.sendCategory
        vc.transitioningDelegate = self
        vc.interactor = interactor
        transitionNavMode(to: vc)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if categories.count > 8 {
            return tableView.frame.height / 8
        } else {
            if Utils.isIPhoneX() {
                return 812 * 0.0839 + 16
            } else {
                return 667 * 0.0839 + 16
            }
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

extension Notification.Name{
    static let toRadioFromAllCategoryNotification = Notification.Name("ToRadioFromAllCategoryNotification")
}
