//
//  RadioCell.swift
//  
//
//  Created by Apple on 1/28/19.
//

import UIKit

class RadioCell: UITableViewCell {

    @IBOutlet var vDetails: NYView!
    @IBOutlet var lblRadioTitle: UILabel!
    @IBOutlet var liveView: UIView!
    @IBOutlet var userNameLbl: UILabel!
    
    var radio: RadioStation? {
        didSet {
            lblRadioTitle.text = radio?.name
            
            if let userName = radio?.user_name, !userName.isEmpty {
                userNameLbl.isHidden = false
                userNameLbl.text = userName
            }else{
                userNameLbl.isHidden = true
            }
            
            if let _ = radio?.audios.path {
                liveView.isHidden = true
            } else {
                liveView.isHidden = false
                
//                radio?.audios. = true
                Database.database().reference().child("Radio").child("\(radio!.id)").child("data").observeSingleEvent(of: .value) { (snapshot) in
                    if let snapValue = snapshot.value as? [String: Any], let lastUpdate = snapValue["date"] as? String {
                        
                        let localTimeStr = self.UTCToLocal(date: lastUpdate)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        dateFormatter.timeZone = .current
                        let lastUpdated = dateFormatter.date(from: localTimeStr)!
                        print (lastUpdated.timeIntervalSinceNow)
                        if abs(lastUpdated.timeIntervalSinceNow) > 5 {
                            self.liveView.isHidden = true
//                            self.radio?.isLive = false
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
