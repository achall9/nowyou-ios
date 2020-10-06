//
//  RadioUsernameSearchVC.swift
//  NowYou
//
//  Created by 222 on 2/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RadioUsernameSearchVC: BaseTableViewController, IndicatorInfoProvider {

    var parentVC: RadioSearchViewController?
    
    var itemInfo = IndicatorInfo(title: "UserName")
    
    var searchRadios = [RadioStation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "RadioCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCell")
        
        self.tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "RadioCell", bundle: Bundle.main), forCellReuseIdentifier: "RadioCell")

        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable(_:)), name: NSNotification.Name(rawValue: NOTIFICATION.RADIO_SEARCH_UPDATE), object: nil)
        
        search()
    }

    func search() {
        DispatchQueue.main.async {
            if self.parentVC?.searchBar.text == "" {
                self.searchRadios.removeAll()
            } else {
                self.searchRadios.removeAll()
                self.searchRadios.append(contentsOf: self.parentVC?.radios ?? [])
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshTable(_ notification: Notification) {
        search()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchRadios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RadioCell", for: indexPath) as! RadioCell

        cell.radio = searchRadios[indexPath.row]
        
        Utils.shared.setNYViewActive(nyView: cell.vDetails, color: UIColor(hexValue: 0x744af2))

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        parentVC?.searchDelegate?.radioSelected(searchRadios[indexPath.row], sender: parentVC)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
