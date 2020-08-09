//
//  MetricsViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import SwiftCharts

enum MetricsMode {
    case DAILY
    case MONTHLY
    case YEARLY
}

class MetricsViewController: BaseViewController {
    @IBOutlet weak var dashboardIntroIV: UIImageView!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var segView: LuvSegmentedControl!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var lblFollowerCount: UILabel!
    @IBOutlet weak var lblIncreasedFollowerCount: UILabel!
    
    @IBOutlet weak var lblDailyEarned: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblWeekViewcount: UILabel!
    
    @IBOutlet weak var lblEarned: UILabel!
    @IBOutlet weak var vAmount: UIView!
    @IBOutlet weak var vFollower: UIView!
    
    @IBOutlet weak var vDaily: UIView!
    
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var btnCloseTutor: UIButton!
    fileprivate var chart: Chart?
    
    let sideSelectorHeight: CGFloat = 50
    
    var isFirstRun: Bool = false
    var metricsMode: MetricsMode = .DAILY {
        didSet {
            chartView.isHidden = false
            vDaily.isHidden = true
            showChart(horizontal: false)
            if metricsMode == .YEARLY {
                lblEarned.text = "+ $\(UserManager.myCashInfo()?.yearly.truncate(places: 2) ?? 0.00) this year"
            } else if metricsMode == .MONTHLY {
                 lblEarned.text = "+ $\(UserManager.myCashInfo()?.monthly.truncate(places: 2) ?? 0.00) this month"
            } else {
                 lblEarned.text = "+ $\(UserManager.myCashInfo()?.daily.truncate(places: 2) ?? 0.00) today"
            }
        }
    }
    
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var btnCashout: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !isFirstRun else {
            return
        }
        
        dashboardIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
        let dashShown = UserDefaults.standard.bool(forKey: "dashShown")
        if !dashShown {
            dashboardIntroIV.alpha = 1.0
            btnCloseTutor.alpha = 1.0
            UserDefaults.standard.set(true, forKey: "dashShown")
            btnCloseTutor.isEnabled = true
        }
        // load user info
        NetworkManager.shared.getUserDetails(userId: (UserManager.currentUser()?.userID)!) { (response) in
            switch response {
            case .error(let error):
                DispatchQueue.main.async {
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                }
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let json = jsonRes as? [String: Any] {
                        if let userJson = json["user"] as? [String: Any] {
                            let user = User(json: userJson)
                            let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user)
                            UserDefaults.standard.set(encodedUser, forKey: USER_INFO)
                            UserDefaults.standard.synchronize()
                            
                            self.isFirstRun = true
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadUserInfo()
                    }
                } catch {
                    
                }
            }
        }
        //load my info
        NetworkManager.shared.getMyCashInfo() { (response) in
            switch response {
            case .error(let error):
                DispatchQueue.main.async {
                    self.present(Alert.alertWithText(errorText: error.localizedDescription), animated: true, completion: nil)
                }
            case .success(let data):
                do {
                    let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let json = jsonRes as? [String: Any] {
                        if let userJson = json["cash_info"] as? [String: Any] {
                            let cashInfo = CashInfo(json: userJson)
                            let encodedUser = NSKeyedArchiver.archivedData(withRootObject: cashInfo)
                            UserDefaults.standard.set(encodedUser, forKey: CASH_INFO)

                            UserDefaults.standard.synchronize()
                            
                            self.isFirstRun = true
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadCashInfo()
                    }
                } catch {
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        segView.items = ["Day", "Month", "Year"]
        segView.selectedIndex = 0
        
        loadUserInfo()

        loadCashInfo()
        
        segView.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        segView.layer.borderWidth = 1
        segView.setRoundCorner(radius: 6)
        
        btnCashout.layer.cornerRadius = 6
        btnCashout.layer.masksToBounds = true
        
        segView.addTarget(self, action: #selector(viewModeChange(_:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playScreenOpened(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.PLAY_SCREEN_OPENED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userPhotoUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.USER_PHOTO_UPDATED), object: nil)
        getPaymentEmail()
        
        NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
    }
    
    @objc func openTutor(notification: Notification){
        dashboardIntroIV.alpha = 1.0
        btnCloseTutor.alpha = 1.0
        UserDefaults.standard.set(true, forKey: "dashShown")
        btnCloseTutor.isEnabled = true
    }
    @objc func closeTutor(notification: Notification){
        dashboardIntroIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    @objc func playScreenOpened(notification: Notification) {
        print("notiication user info **** = \(String(describing: notification.userInfo))")
        if let userInfo = notification.userInfo, let visible = userInfo["visible"] as? Bool {
            self.overlayView.isHidden = visible
        }
    }
    @objc func userPhotoUpdated(notification: Notification) {
        DispatchQueue.main.async {
             self.loadUserInfo()
        }
    }
    @objc func userInfoUpdated(notification: Notification) {
        DispatchQueue.main.async {
            self.loadUserInfo()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imgProfile.layer.borderWidth = 3
        imgProfile.layer.borderColor = UIColor(hexValue: 0xBABABA).cgColor
        imgProfile.setCircular()
    }
    
    private func loadCashInfo(){
//        lblViewCount.text = "\(cashInfo.total_view_count)"
//        lblEarned.text = "+ $\(UserManager.currentUser()?.earning_daily ?? 0.00) today"
        showChart(horizontal: false)
    }
    private func loadUserInfo() {
        let user = UserManager.currentUser()!
        //----
        lblViewCount.text = "\(user.view_count_total)"
//        lblEarned.text = String(format: "+ $ %.2f today", UserManager.myCashInfo()?.daily ?? 0.00)
        lblEarned.text = "+ $\(UserManager.myCashInfo()?.daily.truncate(places: 2) ?? 0.00) today"
        //----
        lblWeekViewcount.text = "+\(user.view_count_weekly) this week"
        
        lblFollowerCount.text = "\(user.followers_count)"
        lblIncreasedFollowerCount.text = "+\(UserManager.myCashInfo()?.this_week_followers ?? 0) this week"
//        lblIncreasedFollowerCount.text = "+\(user.this_week_followers) this week"

        
        lblUsername.text = user.fullname
        
        lblDailyEarned.text = "+ $\(UserManager.currentUser()?.earning_daily ?? 0.00)"
        
        imgProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: user.userPhoto)), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)

    }
    
    @objc func viewModeChange(_ sender: Any?) {
        if segView.selectedIndex == 0 {
            metricsMode = .DAILY
        } else if segView.selectedIndex == 1 {
            metricsMode = .MONTHLY
        } else {
            metricsMode = .YEARLY
        }
    }
    
    func getMonthName(month: Double) -> String {
//        return ""
        
        if metricsMode == .MONTHLY {
            return "\(Int(month) * 3 + 1)"
        }
        
        if metricsMode == .DAILY {
            return "\(Int(month) * 2)"
        }
        
        switch (month + 1.0) {
        case 1.0:
            return "Jan"
        case 2.0:
            return "Feb"
        case 3.0:
            return "Mar"
        case 4.0:
            return "Apr"
        case 5.0:
            return "May"
        case 6.0:
            return "Jun"
        case 7.0:
            return "Jul"
        case 8.0:
            return "Aug"
        case 9.0:
            return "Sep"
        case 10.0:
            return "Oct"
        case 11.0:
            return "Nov"
        case 12.0:
            return "Dec"
        default:
            return ""
        }
    }
    
    fileprivate func barsChart(horizontal: Bool) -> Chart {
        var tuplesXY = [(Int, Int)]()
        
        if metricsMode == .YEARLY {
            if let monthly_history = UserManager.myCashInfo()?.monthly_history, monthly_history.count == 12 {
                // get top value of monthly history
                let topValue = monthly_history.max() ?? 0.0
                var multiple = 1
                if topValue < 0.00001{
                    multiple = 1000000
                }else if topValue < 0.0001 {
                    multiple = 100000
                } else if topValue < 0.001 {
                    multiple = 10000
                } else if topValue < 0.01 {
                    multiple = 1000
                }else if topValue < 0.1 {
                    multiple = 100
                } else if topValue < 0.5 {
                    multiple = 20
                } else if topValue < 1.0 {
                    multiple = 10
                } else if topValue < 10 {
                    multiple = 5
                } else {
                    multiple = 1
                }
                
                for index in 1..<13 {
                    tuplesXY.append((index - 1, Int(monthly_history[index - 1] * Double(multiple))))
                }
            }
        } else if metricsMode == .MONTHLY {
            if let daily_history = UserManager.myCashInfo()?.daily_history, daily_history.count > 29 {
                
                let topValue = daily_history.max() ?? 0.0
                var multiple = 1
                if topValue < 0.00001{
                    multiple = 1000000
                }else if topValue < 0.0001 {
                    multiple = 100000
                } else if topValue < 0.001 {
                    multiple = 10000
                } else if topValue < 0.01 {
                    multiple = 1000
                }else if topValue < 0.1 {
                    multiple = 100
                } else if topValue < 0.5 {
                    multiple = 20
                } else if topValue < 1.0 {
                    multiple = 10
                } else if topValue < 10 {
                    multiple = 5
                } else {
                    multiple = 1
                }
                
                for index in 1..<10 {
                    tuplesXY.append((index - 1, Int((daily_history[(index - 1) * 3 ] + daily_history[(index - 1) * 3 + 1] + daily_history[(index - 1) * 3 + 2]) * Double(multiple))))
                }
            }
        } else {
        //----
            if let timely_history = UserManager.myCashInfo()?.timely_history, timely_history.count > 23 {
                let topValue = timely_history.max() ?? 0.0
                var multiple = 1
                
                if topValue < 0.00001{
                    multiple = 1000000
                }else if topValue < 0.0001 {
                    multiple = 100000
                } else if topValue < 0.001 {
                    multiple = 10000
                } else if topValue < 0.005 {
                    multiple = 5000
                } else if topValue < 0.01 {
                    multiple = 1000
                } else if topValue < 0.05 {
                    multiple = 500
                }else if topValue < 0.1 {
                    multiple = 100
                } else if topValue < 0.5 {
                    multiple = 20
                } else if topValue < 1.0 {
                    multiple = 10
                } else if topValue < 10 {
                    multiple = 5
                } else {
                    multiple = 1
                }
                
                for index in 1..<25 {
                    if index % 2 == 0 {
                        tuplesXY.append((index / 2 - 1, Int((timely_history[index - 1] + timely_history[index - 2]) * Double(multiple))))
                    }
                }
            }
        }
        
//        let tuplesXY = [(0, 2), (1, 4), (2, 5), (3, 2), (4, 5), (5, 3), (6, 7), (7, 4), (8, 5), (9, 6), (10, 8), (11, 4)]
        
        func reverseTuples(_ tuples: [(Int, Int)]) -> [(Int, Int)] {
            return tuples.map{($0.1, $0.0)}
        }
        
        let chartPoints = (horizontal ? reverseTuples(tuplesXY) : tuplesXY).map{ChartPoint(x: ChartAxisValueInt($0.0), y: ChartAxisValueInt($0.1))}
        
        let labelSettings = ChartLabelSettings(font: UIFont(name: "Gilory-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14), fontColor: UIColor.black, rotation: metricsMode == .YEARLY ? 90 : 0, rotationKeep: .bottom)
        
        
        let generator = ChartAxisGeneratorMultiplier(1)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            
            return ChartAxisLabel(text: "\(self.getMonthName(month: scalar))", settings: labelSettings)
        }
        let xGenerator = ChartAxisGeneratorMultiplier(1)
        
        
        var lastModelValue: Double = 12
        
        if metricsMode == .YEARLY {
            lastModelValue = 12
        } else if metricsMode == .DAILY {
            lastModelValue = 12
        } else {
            lastModelValue = 10
        }
        let xModel = ChartAxisModel(firstModelValue: 0, lastModelValue: lastModelValue, axisTitleLabels: [ChartAxisLabel(text: "", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: labelsGenerator)
        let yModel = ChartAxisModel(firstModelValue: 0, lastModelValue: lastModelValue, axisTitleLabels: [ChartAxisLabel(text: "Axis title", settings: labelSettings.defaultVertical())], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        let barViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let bottomLeft = layer.modelLocToScreenLoc(x: 0, y: 0)
            
            var barWidth: CGFloat = 20
            
            if self.metricsMode == .YEARLY {
                barWidth = 20.0
            } else if self.metricsMode == .DAILY {
                barWidth = 20.0
            } else {
                barWidth = 20.0
            }
            
            let settings = ChartBarViewSettings(animDuration: 0.5)
            
            let (p1, p2): (CGPoint, CGPoint) = {
                if horizontal {
                    return (CGPoint(x: bottomLeft.x, y: chartPointModel.screenLoc.y), CGPoint(x: chartPointModel.screenLoc.x, y: chartPointModel.screenLoc.y))
                } else {
                    return (CGPoint(x: chartPointModel.screenLoc.x + 10, y: bottomLeft.y), CGPoint(x: chartPointModel.screenLoc.x + 10, y: chartPointModel.screenLoc.y))
                }
            }()
            
            var bgColor: UIColor = UIColor(hexValue: 0x60DF76)
            
            if chartPointModel.chartPoint.y.scalar == 0.0 {
                bgColor = bgColor.withAlphaComponent(0.4)
            }
            
            return ChartPointViewBar(p1: p1, p2: p2, width: barWidth, bgColor: UIColor(hexValue: 0x60DF76), settings: settings)
        }
        
        let frame = vAmount.bounds
        let chartFrame = chart?.frame ?? CGRect(x: 10, y: 0, width: frame.size.width - 60, height: frame.size.height - 20)
        
        let chartSettings = iPhoneChartSettings
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: chartPoints, viewGenerator: barViewGenerator)

        return Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                chartPointsLayer
            ]
        )
    }
    
    fileprivate var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 0
        chartSettings.trailing = 10
        chartSettings.bottom = 0
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        
        
        return chartSettings
    }
    
    fileprivate func showChart(horizontal: Bool) {
        self.chart?.clearView()
        
        let chart = barsChart(horizontal: horizontal)
        
        for subview in vAmount.subviews {
            subview.removeFromSuperview()
        }
        
        vAmount.addSubview(chart.view)
        self.chart = chart
    }
    fileprivate func getPaymentEmail(){
        DataBaseManager.shared.getPaymentEmail()
        { (result,error) in
            if error != ""{
                UserDefaults.standard.set("Connect Error", forKey: "StripeCustomAccountId")
                print(error)
            }else{
                let stripeCustomAccoundId = result.self
                UserDefaults.standard.set(stripeCustomAccoundId, forKey: "StripeCustomAccountId")
                print("download stripe custom account id successfully")
            }
        }
    }
    
    @IBAction func onCashout(_ sender: Any) {
        let stripeCustomeAccountId = UserDefaults.standard.object(forKey:"StripeCustomAccountId") as? String
        if stripeCustomeAccountId == "Connect Error"{
            return
        }
        
        let storyboard = UIStoryboard(name: "withdraw", bundle: nil)
        if stripeCustomeAccountId == ""{
            print("go to user register")
            let vc = storyboard.instantiateViewController(withIdentifier: "UserInfoRegisterVC") as! UserInfoRegisterViewController
            navigationController?.pushViewController(vc, animated: true)
        }else{
            print("go to payment gateway")
            let vc = storyboard.instantiateViewController(withIdentifier: "WithdrawViewController") as! WithdrawViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {   var res : Double = 0.0
        if self == 0.0 {
            res = 0.00
        }else if Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places))) == 0.00{
             let mul : Double = pow(10, floor(log10(abs(self))))
             res = Double((self/mul)*mul)
        }else{
            res = Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
        }
       return res
    }
    
}
