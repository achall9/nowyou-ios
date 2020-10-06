//
//  CategoryViewController.swift
//  NowYou
//
//  Created by Apple on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import CRRefresh

class CategoryViewController: BaseTableViewController, IndicatorInfoProvider,UIViewControllerTransitioningDelegate {
    
    var itemInfo = IndicatorInfo(title: "Popular Categories")
    var transition = CATransition()
    var interactor = Interactor()
    var categories = [RadioCategory]()
    var sendCategory :RadioCategory!
    var radioVC: RadioViewController?
    var viewAllState: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAllState = false
        tableView.register(UINib(nibName: "RadioCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCategoryCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: NEW_CATEGORY_ADDED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewAllList(notification:)), name: .viewAllListOfCaterotyOrRadioStation, object: nil)
        
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()) {
            self.getCategories()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewAllState = false
        getCategories()
        tableView.reloadData()
        super.viewWillAppear(true)
    }
    @objc func viewAllList(notification: Notification) {
        let allCategory = UIViewController.viewControllerWith("AllCategoryViewController") as! AllCategoryViewController
      allCategory.transitioningDelegate = self
      allCategory.interactor = interactor
      transitionNavMode(to: allCategory)

    }
              
     func transitionNavMode(to controller: UIViewController) {
         transition.duration = 0.1
         transition.type = CATransitionType.fade
         transition.subtype = CATransitionSubtype.fromTop
         view.window?.layer.add(transition, forKey: kCATransition)
         navigationController?.pushViewController(controller, animated: false)
     }
    
    @objc func refresh(notification: Notification) {
        print("111111111")
        getCategories()
        tableView.reloadData()
    }
    
    func getCategories() {
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
//                Utils.showSpinner()
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
                                self.tableView.reloadData()
                            }
                        } catch {
                            
                        }
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
            return categories.count
        } else{
            return categories.count > 6 ? 6 : categories.count
        }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        radioVC?.performSegue(withIdentifier: "toRadios", sender: categories[indexPath.row])
        self.sendCategory = categories[indexPath.row]
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if categories.count > 6 {
            return tableView.frame.height / 6
        }else{
            if Utils.isIPhoneX() {
                return 812 * 0.0839 + 16
            } else {
                return 667 * 0.0839 + 20
            }
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
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let dest = segue.destination as? SubRadioViewController {
//            if (sender as? RadioCategory) != nil {
//                dest.category = category
//            }
//
//        }
//    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    @objc func onDidReceiveNewCategoryData(_notification: Notification){
        getCategories()
        tableView.reloadData()
    }
}
