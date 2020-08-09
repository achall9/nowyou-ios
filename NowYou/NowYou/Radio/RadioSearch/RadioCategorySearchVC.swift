//
//  RadioCategorySearchVC.swift
//  NowYou
//
//  Created by Apple on 4/18/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RadioCategorySearchVC: BaseTableViewController, IndicatorInfoProvider, RadioCategorySearchDelegate {

    var parentVC: RadioSearchViewController?
    
    var itemInfo = IndicatorInfo(title: "Category")
    
    var searchCategories = [RadioCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "RadioCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCategoryCell")
        
        parentVC?.categorySearchDelegate = self
        self.tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "RadioCategoryCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCategoryCell")

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchCategories.count
    }

    func searchTextChanged(keyword: String) {
        print("category search --- \(keyword)")
        
        if keyword == "" {
            searchCategories.removeAll()
        } else {
            searchCategories.removeAll()
            
            for category in parentVC?.categories ?? [] {
                if category.name.lowercased().contains(keyword.lowercased()) {
                    searchCategories.append(category)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCategoryCell", for: indexPath) as! RadioCategoryCell

        cell.category = searchCategories[indexPath.row]
        
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
        
        return tableView.frame.height / 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        parentVC?.searchDelegate?.categorySelected(searchCategories[indexPath.row], sender: parentVC)
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

}
