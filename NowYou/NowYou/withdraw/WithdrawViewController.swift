//
//  WithdrawViewController.swift
//  NowYou
//
//  Created by 111 on 2/29/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import MaterialComponents
import Stripe
class WithdrawViewController: StripeBaseViewController {

    @IBOutlet weak var imgLogo: UIImageView!

    @IBOutlet weak var lblCard: UILabel!
    
    @IBOutlet weak var lblBank: UILabel!
    
    @IBOutlet weak var bankTable: UITableView!
    @IBOutlet weak var cardTable: UITableView!
    
    @IBOutlet weak var btnAddBank: UIButton!
    @IBOutlet weak var btnAddCard: UIButton!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var bankTableHeight: NSLayoutConstraint!
    @IBOutlet weak var cardTableHeight: NSLayoutConstraint!
    var stripeCards = [StripeCard]()
    var stripeBanks = [StripeBank]()
    var externalAccountId : String = ""
    var externalAccountIndex : Int = 0
    var externalAccountState: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Do any additional setup after loading the view.

        getAllCards()
        getAllBankCounts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllCards()
        getAllBankCounts()
    }
    private func configureUI(){
        bankTable.register(UINib(nibName: "BankTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "BankTableViewCell")
        cardTable.register(UINib(nibName: "CardTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CardTableViewCell")
        cardTable.delegate = self
        cardTable.dataSource  = self
        cardTable.allowsMultipleSelection = false
        cardTable.allowsSelectionDuringEditing = false
        
        bankTable.delegate = self
        bankTable.dataSource = self
        bankTable.allowsMultipleSelection = false
        bankTable.allowsSelectionDuringEditing = false
        
        setBtnUI(btn: btnAddBank, radius: 8)
        setBtnUI(btn: btnAddCard, radius: 8)
        setBtnUI(btn: btnRemove, radius: 8)
        setBtnUI(btn: btnWithdraw, radius: 16)
        btnRemove.alpha = 0.0
        btnWithdraw.alpha = 0.0
        lblCard.text = "Card"
        lblBank.text = "Bank"
        imgLogo.setCircular()
    }
  
    func getAllCards(){
        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
        StripeManager.shared.listAllCards(customAccountId: stripeCustomAccountId){
            (result,error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertWithError(title: "", message: error.message ?? "")
                }else{
                    self.stripeCards = result
                    if self.stripeCards.count == 0{
                        self.lblCard.text = "No Card"
                    }else{
                        self.lblCard.text = "Card"
                    }
                    self.loaddata()
                    self.cardTable.reloadData()
                }
            }
        }
    }

    func getAllBankCounts(){
        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
        StripeManager.shared.listAllbankAcccounts(customAccountId: stripeCustomAccountId){
          (result,error) in
          DispatchQueue.main.async {
              if let error = error {
                  self.loaddata()
                  self.cardTable.reloadData()
                  self.showAlertWithError(title: "", message: error.message ?? "")
              }else{
                  self.stripeBanks = result
                  if self.stripeBanks.count == 0{
                    self.cardTable.reloadData()
                    self.lblBank.text = "No Bank"
                  }
                self.loaddata()
                self.bankTable.reloadData()

              }
          }
        }
    }


    func loaddata(){
        let cardCount: Int = stripeCards.count
        let bankCount: Int = stripeBanks.count
        var cellSize: Int = 0
        if Utils.isIPhoneX() {
            cellSize = Int(812 * 0.0839) + 8
        } else {
            cellSize = Int(667 * 0.0839) + 8
        }
        if cardCount == 0 && bankCount == 0 {
            btnRemove.alpha = 0.0
            btnWithdraw.alpha = 0.0
        }else{
            btnRemove.alpha = 1.0
            btnWithdraw.alpha = 1.0
        }
        bankTableHeight.constant = CGFloat(bankCount * cellSize)
        cardTableHeight.constant = CGFloat(cardCount * cellSize)
    }

    @IBAction func onBack(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "MetricsViewController") as! MetricsViewController
        navigationController?.popViewController(animated: true)
    }
    //card_1GLjuHGE4iroJHOaB29ANjJm
    @IBAction func onWithdraw(_ sender: Any) {
        
        let cashInfo = UserManager.myCashInfo()!

        let cashAmount = cashInfo.total_cash
        if cashAmount < 10.00 {
             self.showAlertWithError(title: "", message: "Can not withdraw less money than $ 10")
            return
        }
        if externalAccountId == "" {
            self.showAlertWithError(title: "", message: "Please select card or bank")
            return
        }else{
            StripeManager.shared.createPayout(amount: Int(cashAmount), currency: "usd", destination: externalAccountId){
                (result,error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showAlertWithError(title: "", message: error.message ?? "")
                    }else{
                        DataBaseManager.shared.withdrawedInfoFromApp(amount: cashAmount) { (error) in
                            print(error.debugDescription)
                        }
                        print(result)
                    }
                }
            }
        }
        
    }

    @IBAction func onRemove(_ sender: Any){
        let stripeCustomAccountId = UserDefaults.standard.object(forKey: "StripeCustomAccountId") as? String ?? ""
        if stripeCustomAccountId == ""{
            return
        }else if self.externalAccountId == ""{
            self.showAlertWithError(title: "", message: "There is not the card or Bank")
            return
        }
        StripeManager.shared.removeBankorCard(stripeCustomAccountId, externalAccountId){
            (error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertWithError(title: "", message: error.message ?? "")
                }else{
                    if self.externalAccountState == false{
                        self.stripeBanks.remove(at: self.externalAccountIndex)
                        let indexPath = NSIndexPath(row: self.externalAccountIndex, section: 0)
                        if let cell =  self.bankTable.cellForRow(at: indexPath as IndexPath) {
                            cell.accessoryType = .none
                        }
                        self.loaddata()
                        self.bankTable.reloadData()
                    }else{
                        let indexPath = NSIndexPath(row: self.externalAccountIndex, section: 0)
                        if let cell =  self.cardTable.cellForRow(at: indexPath as IndexPath) {
                           cell.accessoryType = .none
                        }
                        self.stripeCards.remove(at: self.externalAccountIndex)
                        self.loaddata()
                        self.cardTable.reloadData()
                    }
                }
            }
        }
        
    }
  
}

extension WithdrawViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.bankTable {
            if let cell = bankTable.cellForRow(at: indexPath) {
                for index in 0...stripeCards.count-1{
                    let indexPath = NSIndexPath(row: index, section: 0)
                    self.cardTable.deselectRow(at: indexPath as IndexPath, animated: true)
                    if let cell =  self.cardTable.cellForRow(at: indexPath as IndexPath) {
                        cell.accessoryType = .none
                    }
                }
                self.externalAccountId = self.stripeBanks[indexPath.row].id ?? ""
                self.externalAccountIndex = indexPath.row
                externalAccountState = false
                cell.accessoryType = .checkmark
            }
        }else if tableView == self.cardTable{
            if let cell = cardTable.cellForRow(at: indexPath) {
                for index in 0...stripeCards.count-1{
                    let indexPath = NSIndexPath(row: index, section: 0)
                    self.bankTable.deselectRow(at: indexPath as IndexPath, animated: true)
                    if let cell =  self.bankTable.cellForRow(at: indexPath as IndexPath) {
                        cell.accessoryType = .none
                    }
                }
                self.externalAccountId = self.stripeCards[indexPath.row].id ?? ""
                self.externalAccountIndex = indexPath.row
                externalAccountState = true
                cell.accessoryType = .checkmark
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.bankTable {
            if let cell = bankTable.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        }else if tableView == self.cardTable{
           if let cell = cardTable.cellForRow(at: indexPath) {
               cell.accessoryType = .none
           }
        }
    }
}
extension WithdrawViewController : UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.bankTable {
            if self.stripeBanks.count == 0{
                self.lblBank.text = "No Bank"
            }else{
                self.lblBank.text = "Bank"
            }
            return self.stripeBanks.count
        }else{
            if self.stripeCards.count == 0{
                self.lblCard.text = "No Card"
           }else{
                self.lblCard.text = "Card"
           }
           return stripeCards.count
        }
       
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.bankTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankTableViewCell", for: indexPath) as! BankTableViewCell
            cell.stripeBank = stripeBanks[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as! CardTableViewCell
            cell.stripeCard = stripeCards[indexPath.row]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Utils.isIPhoneX() {
            return 812 * 0.0839 + 8
        } else {
            return 667 * 0.0839 + 8
        }
    }
}


