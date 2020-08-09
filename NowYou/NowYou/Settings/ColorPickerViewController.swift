//
//  ColorPickerViewController.swift
//  NowYou
//
//  Created by Apple on 4/21/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class ColorPickerViewController: BaseViewController {

    var colors = ["FFFFFF", "4A80F2", "9049C4", "50AFC4", "60C191", "D4915E", "B46055", "BF4B7C", "A63333"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerCell", for: indexPath) as! ColorPickerCell
        
        cell.colorView.backgroundColor = UIColor(hexString: colors[indexPath.row])
        
        
        cell.colorView.setCircular()
        
        cell.colorView.layer.borderWidth = 1
        cell.colorView.layer.borderColor = UIColor(hexValue: 0x4E4E4E).cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let userData = UserManager.currentUser() {
            userData.color = colors[indexPath.row]
            UserManager.updateUser(user: userData)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.APP_COLOR_UPDATED), object: nil, userInfo: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
}
