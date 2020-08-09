//
//  RadioStationCell.swift
//  NowYou
//
//  Created by 111 on 1/16/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class RadioStationCell: UITableViewCell {

    @IBOutlet var vDetails: NYView!
    @IBOutlet var lblRadioTitle: UILabel!
    @IBOutlet var liveView: UIView!
    
    var radioStation: RadioStation? {
        didSet {
            lblRadioTitle.text = radioStation?.name
            
            if let _ = radioStation?.audios {
                liveView.isHidden = true
            } else {
                liveView.isHidden = false
                Database.database().reference().child("Radio").child("\(radioStation!.id)").child("data").observeSingleEvent(of: .value) { (snapshot) in
                    if let snapValue = snapshot.value as? [String: Any], let lastUpdate = snapValue["date"] as? String {
                        
                        let localTimeStr = self.UTCToLocal(date: lastUpdate)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        dateFormatter.timeZone = .current
                        let lastUpdated = dateFormatter.date(from: localTimeStr)!
                        print (lastUpdated.timeIntervalSinceNow)
                        if abs(lastUpdated.timeIntervalSinceNow) > 5 {
                            self.liveView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblRadioTitle.text = ""
        liveView.isHidden = true
    }
}
