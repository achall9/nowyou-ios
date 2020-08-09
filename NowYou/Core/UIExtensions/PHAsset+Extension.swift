//
//  PHAsset+Extension.swift
//  NowYou
//
//  Created by Apple on 1/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {
    var thumbnailImage : UIImage {
        get {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: self, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                thumbnail = result!
            })
            return thumbnail
        }
    }
}
