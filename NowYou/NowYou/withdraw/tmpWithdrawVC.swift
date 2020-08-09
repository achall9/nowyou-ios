////
////  WithdrawViewController.swift
////  NowYou
////
////  Created by 111 on 2/29/20.
////  Copyright © 2020 Apple. All rights reserved.
////
//
//import UIKit
//import MaterialComponents
//import Stripe
//class WithdrawViewController: StripeBaseViewController {
//
//    @IBOutlet weak var imgLogo: UIImageView!
//    @IBOutlet weak var lblNoBank: UILabel!
//    @IBOutlet weak var lblNoCard: UILabel!
//
//
//    @IBOutlet weak var bankTable: UITableView!
//    @IBOutlet weak var cardTable: UITableView!
//
//    @IBOutlet weak var btnAddBank: UIButton!
//    @IBOutlet weak var btnAddCard: UIButton!
//    @IBOutlet weak var btnWithdraw: UIButton!
//
//    var stripeCards = [StripeCard]()
//    var stripeBanks = [StripeBank]()
////    var cardCount: Int = 2
////    var bankCount: Int = 2
//    //    private var cardNameController: MDCTextInputControllerOutlined?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        // Do any additional setup after loading the view.
//        getAllCards()
//        getAllBankCounts()
//    }
//
//    private func configureUI(){
//        bankTable.register(UINib(nibName: "BankTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "BankTableViewCell")
//        cardTable.register(UINib(nibName: "CardTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CardTableViewCell")
//        cardTable.delegate = self
//        cardTable.dataSource  = self
//        bankTable.delegate = self
//        bankTable.dataSource = self
//        setBtnUI(btn: btnAddBank, radius: 8)
//        setBtnUI(btn: btnAddCard, radius: 8)
//        setBtnUI(btn: btnWithdraw, radius: 16)
//
//        lblNoCard.alpha = 0.0
//        imgLogo.setCircular()
//
//    }
//
//    func getAllCards(){
//        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
//        StripeManager.shared.listAllCards(customAccountId: stripeCustomAccountId){
//            (result,error) in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self.showAlertWithError(title: "", message: error.message ?? "")
//                }else{
//                    self.stripeCards = result
//                    if self.stripeCards.count == 0{
//                        self.lblNoCard.alpha = 1.0
//                    }
//                    self.cardTable.reloadData()
//                }
//            }
//        }
//    }
////        let stripeCustomerId = UserDefaults.standard.object(forKey: "StripeCustomerId") as? String ?? ""
////        StripeManager.shared.listAllCards(customerId: stripeCustomerId){
////            (result,error) in
////            DispatchQueue.main.async {
////                if let error = error {
////                    self.showAlertWithError(title: "", message: error.message!)
////                }else{
////                    self.stripeCards = result
////                    if self.stripeCards.count == 0{
////                        self.lblNoCard.alpha = 1.0
////                    }
////                    self.cardTable.reloadData()
////                }
////            }
////        }
////    }
//    func getAllBankCounts(){
//        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
//        StripeManager.shared.listAllbankAcccounts(customAccountId: stripeCustomAccountId){
//          (result,error) in
//          DispatchQueue.main.async {
//              if let error = error {
//                  self.showAlertWithError(title: "", message: error.message ?? "")
//              }else{
//                  self.stripeBanks = result
//                  if self.stripeBanks.count == 0{
//                      self.lblNoBank.alpha = 1.0
//                  }
//                  self.bankTable.reloadData()
//              }
//          }
//        }
//    }
//
////        let stripeCustomerId = UserDefaults.standard.object(forKey: "StripeCustomerId") as? String ?? ""
////        StripeManager.shared.listAllbankAcccounts(customerId: stripeCustomerId){
////            (result,error) in
////            DispatchQueue.main.async {
////                if let error = error {
////                    self.showAlertWithError(title: "", message: error.message!)
////                }else{
////                    self.stripeBanks = result
////                    if self.stripeBanks.count == 0{
////                        self.lblNoBank.alpha = 1.0
////                    }
////                    self.bankTable.reloadData()
////                }
////            }
//    @IBAction func onBack(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//}
//
//extension WithdrawViewController : UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .checkmark
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.accessoryType = .none
//        }
//    }
//}
//extension WithdrawViewController : UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == self.bankTable {
//            if self.stripeBanks.count == 0{
//                self.lblNoBank.alpha = 1.0
//            }else{
//                self.lblNoBank.alpha = 0.0
//            }
//            return self.stripeBanks.count
//        }else{
//            if self.stripeCards.count == 0{
//              self.lblNoCard.alpha = 1.0
//           }else{
//               self.lblNoCard.alpha = 0.0
//           }
//           return stripeCards.count
//        }
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView == self.bankTable {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BankTableViewCell", for: indexPath) as! BankTableViewCell
//            cell.stripeBank = stripeBanks[indexPath.row]
//            return cell
//        }else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as! CardTableViewCell
//            cell.stripeCard = stripeCards[indexPath.row]
//            return cell
//        }
//
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if Utils.isIPhoneX() {
//            return 812 * 0.0839 + 16
//        } else {
//            return 667 * 0.0839 + 16
//        }
//    }
//}
//
