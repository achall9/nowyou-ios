//
//  RadioContainerViewController.swift
//  NowYou
//
//  Created by Apple on 1/28/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class RadioContainerViewController: BasePagerVC {

    var isReload = false
    
    var radioVc: RadioViewController?
    
    var childCategories: CategoryViewController?
    var topRadios: PopularRadioStationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonBarView.selectedBar.backgroundColor = UIColor(hexValue: 0x60DF76)
        buttonBarView.backgroundColor = UIColor.clear
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 13)
        settings.style.buttonBarItemTitleColor = UIColor.black
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        childCategories = CategoryViewController(style: .plain)
        childCategories?.radioVC = radioVc
        
        topRadios       = PopularRadioStationViewController(style: .plain)
        topRadios?.radioVC   = radioVc
        
        guard isReload else {
            return [childCategories!, topRadios!]
        }
        
        var childControllers = [childCategories!, topRadios!]
        
        for index in childControllers.indices {
            let nElements = childControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            
            if n != index {
                childControllers.swapAt(index, n)
            }
        }
        
        let nItems = 1 + (arc4random() % 4)
        return Array(childControllers.prefix(upTo: Int(nItems)))
        
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

}
