//
//  RadioSearchViewController.swift
//  NowYou
//
//  Created by Apple on 3/16/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

enum RadioSearchMode: Int {
    case Category = 1
    case Radio
    case HashTag
    case UserName
}

protocol RadioCategorySearchDelegate {
    func searchTextChanged(keyword: String)
}

protocol RadioSearchDelegate {
    func categorySelected(_ category: RadioCategory, sender: RadioSearchViewController?)
    func radioSelected(_ radio: RadioStation, sender: RadioSearchViewController?)
}

class RadioSearchViewController: BasePagerVC, UIGestureRecognizerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchMode: RadioSearchMode = .Category
    
    var categories = [RadioCategory]()
//    var top100 = [RadioStation]()

    var childCategory: RadioCategorySearchVC!
    var childStation: RadioStationSearchVC!
    var childTag: RadioTagSearchVC!
    var childUserName: RadioUsernameSearchVC!
    
    var radios = [RadioStation]()
    
    var categorySearchDelegate: RadioCategorySearchDelegate?
    
    var searchDelegate: RadioSearchDelegate?
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    
    var isReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        buttonBarView.selectedBar.backgroundColor = UIColor(hexValue: 0x60DF76)
        buttonBarView.backgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 13)
        settings.style.buttonBarItemTitleColor = UIColor.black

//        let recognizer = UIPanGestureRecognizer(
//            target: self,
//            action: #selector(gesture(_:)))
//        recognizer.delegate = self
//        view.addGestureRecognizer(recognizer)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell:ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex:Bool, animated:Bool) in
            guard changeCurrentIndex == true else { return }

            self.radios.removeAll()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.RADIO_SEARCH_UPDATE), object: nil, userInfo: nil)
            
            let text = newCell?.label.text
            switch text {
            case "Category":
                self.searchMode = .Category
                self.categorySearchDelegate?.searchTextChanged(keyword: self.searchBar?.text ?? "")
                break
            case "Radio":
                self.searchMode = .Radio
                self.search(keyword: self.searchBar?.text ?? "", type: 2)
                    break
            case "UserName":
                self.searchMode = .UserName
                self.search(keyword: self.searchBar?.text ?? "", type: 4)
                    break
            default:
                self.searchMode = .HashTag
                self.search(keyword: self.searchBar?.text ?? "", type: 3)
                break
            }
        }
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
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        childCategory = UIViewController.viewControllerWith("RadioCategorySearchVC") as? RadioCategorySearchVC
        childCategory.parentVC = self
        
        childStation = UIViewController.viewControllerWith("RadioStationSearchVC") as? RadioStationSearchVC
        childStation.parentVC = self
        
        childTag = UIViewController.viewControllerWith("RadioTagSearchVC") as? RadioTagSearchVC
        childTag.parentVC = self
        
        childUserName = UIViewController.viewControllerWith("RadioUsernameSearchVC") as? RadioUsernameSearchVC
        childUserName.parentVC = self
        
        
        
        guard isReload else {
            return [childCategory, childStation, childTag, childUserName]
        }
        
        var childControllers = [childCategory, childStation, childTag, childUserName]
        
        for index in childControllers.indices {
            let nElements = childControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            
            if n != index {
                childControllers.swapAt(index, n)
            }
        }
        
        let nItems = 1 + (arc4random() % 4)
        return Array(childControllers.prefix(upTo: Int(nItems))) as! [UIViewController]
        
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0)
        } else {
            pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        
        super.reloadPagerTabStripView()
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
            
            interactor?.hasStarted = true
            dismiss(animated: true)
            
        case .changed:
            
            interactor?.shouldFinish = progress > percentThreshold
            interactor?.update(progress)
            
        case .cancelled:
            
            interactor?.hasStarted = false
            interactor?.cancel()
            
        case .ended:
            
            guard let interactor = interactor else { return }
            interactor.hasStarted = false
            
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
    
    func search(keyword: String, type:Int) {
        if keyword == "" {
            self.radios.removeAll()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.RADIO_SEARCH_UPDATE), object: nil, userInfo: nil)
            return
        }
        
        DataBaseManager.shared.searchRadios(keyword: keyword, type: type) { (radios, error) in
            if error != nil {
//                self.showAlertWithError(title: "Can't get radios", message: "")
            }else{
                guard let radios = radios else { return }
                self.radios.removeAll()
                self.radios.append(contentsOf: radios)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.RADIO_SEARCH_UPDATE), object: nil, userInfo: nil)
            }

        }
        
    }
 
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print ("current index = \(self.currentIndex)")
        
        if currentIndex == 0 {
            return true
        }
        return false
    }

}
/*
extension RadioSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return searchMode == .Category ? searchCategories.count : searchTop.count
        return radios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if searchMode == .RadioCategory {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCategoryCell", for: indexPath) as! RadioCategoryCell
//
//            cell.category = searchCategories[indexPath.row]
//
//            if indexPath.row % 6 == 0 {
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x60DF76))
//            } else if indexPath.row % 7 == 1 {
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xFBAE5D))
//            } else if indexPath.row % 7 == 2 {
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x4AB3F2))
//            } else if indexPath.row % 7 == 3 {
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xF0CF3F))
//            } else if indexPath.row % 7 == 4 {
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0xE58DD2))
//            } else{
//                Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744AF2))
//            }
//
//            return cell
//        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell
            
            cell.radio = radios[indexPath.row]
            
            Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))
            
            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if searchMode == .RadioCategory {
//            delegate?.selectedCategory(category: searchCategories[indexPath.row])
//        } else {
            delegate?.selectedTopRadio(radio: radios[indexPath.row])
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Utils.isIPhoneX() {
            return 812 * 0.0839 + 16
        } else {
            return 667 * 0.0839 + 16
        }
    }
}
*/
extension RadioSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if self.currentIndex == 0 {
            self.categorySearchDelegate?.searchTextChanged(keyword: searchText)
        }else{
            search(keyword: searchText, type:self.currentIndex + 1)
        }
    }
}
