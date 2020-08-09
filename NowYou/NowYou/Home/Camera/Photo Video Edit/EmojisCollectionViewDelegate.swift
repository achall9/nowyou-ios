//
//  EmojisCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/30/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

class EmojisCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let faceEmojiRanges = [
        0x1F600...0x1F637,
        0x1F910...0x1F915,
        0x1F917...0x1F917,
        0x1F920...0x1F92F,
        0x1F973...0x1F976,
        0x1F470...0x1F47F
    ]
    
    let handGestureEmojiRanges = [
        0x1F4AA...0x1F4AA,
        0x270C...0x270C,
        0x1F91D...0x1F91D,
        0x1F446...0x1F450,
        0x1F918...0x1F91F
    ]
    
    let animalFaceEmojiRanges = [
//        0x1F638...0x1F64A
        0x26f7...0x26f7,
        0x1F466...0x1F469

    ]
    
    let emotionEmojiRanges = [
        0x1F4A2...0x1F4A9,
        0x1F6B4...0x1F6B5,
        0x1F48B...0x1F48C,
        0x1F493...0x1F49F
    ]
    
    let transportMapSymbolRanges = [
        0x1F3CD...0x1F3CE,
        0x1F6E9...0x1F6EC,
        0x1F680...0x1F6C5,
        0x1F694...0x1F694
    ]
    
//    let emojiRanges = [
//        0x1F601...0x1F64F, // emoticons
////                0x1F600...0x1F636,  // Additional emoticons
//        0x1F30D...0x1F567, // Other additional symbols
//        0x1F680...0x1F6C0, // Transport and map symbols
//        0x1F681...0x1F6C5 //Additional transport and map symbols
//    ]
    
    var faceEmojis: [String] = []
    var handGestureEmojis: [String] = []
    var emotionEmojis: [String] = []
    var transportMaps: [String] = []
    
    override init() {
        super.init()
        
        // add face emojis
        for range in faceEmojiRanges {
            for i in range {
                let c = String(describing: UnicodeScalar(i)!)
                faceEmojis.append(c)
            }
        }
        
        for range in animalFaceEmojiRanges {
            for i in range {
                let c = String(describing: UnicodeScalar(i)!)
                faceEmojis.append(c)
            }
        }

        // add emotion emojis
        for range in emotionEmojiRanges {
            for i in range {
                let c = String(describing: UnicodeScalar(i)!)
                emotionEmojis.append(c)
            }
        }
        
        // add hand gesture emojis
        for range in handGestureEmojiRanges {
            for i in range {
                let c = String(describing: UnicodeScalar(i)!)
                handGestureEmojis.append(c)
            }
        }
        
        // add transport & map symbols
        for range in transportMapSymbolRanges {
            for i in range {
                let c = String(describing: UnicodeScalar(i)!)
                transportMaps.append(c)
            }
        }
    }
    
    var stickerDelegate : StickerDelegate?
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmojiCollectionHeaderView", for: indexPath) as? EmojiCollectionHeaderView {
                switch indexPath.section {
                case 0:
                    v.emojiCategoryLabel.text = "Faces"
                case 1:
                    v.emojiCategoryLabel.text = "Emotions"
                case 2:
                    v.emojiCategoryLabel.text = "Hand Gestures"
                case 3:
                    v.emojiCategoryLabel.text = "Travel & Symbols"
                default:
                    break
                }
                
                return v
            }
            
            return UICollectionReusableView()
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return faceEmojis.count
        case 1:
            return emotionEmojis.count
        case 2:
            return handGestureEmojis.count
        case 3:
            return transportMaps.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emojiLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 170, height: 170))
        
        switch indexPath.section {
        case 0:
            emojiLabel.text = faceEmojis[indexPath.item]
        case 1:
            emojiLabel.text = emotionEmojis[indexPath.item]
        case 2:
            emojiLabel.text = handGestureEmojis[indexPath.item]
        case 3:
            emojiLabel.text = transportMaps[indexPath.item]
        default:
            break
        }
        
        emojiLabel.font = UIFont.systemFont(ofSize: 150)
        stickerDelegate?.viewTapped(view: emojiLabel)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionViewCell", for: indexPath) as! EmojiCollectionViewCell
        
        switch indexPath.section {
        case 0:
            cell.emojiLabel.text = faceEmojis[indexPath.item]
        case 1:
            cell.emojiLabel.text = emotionEmojis[indexPath.item]
        case 2:
            cell.emojiLabel.text = handGestureEmojis[indexPath.item]
        case 3:
            cell.emojiLabel.text = transportMaps[indexPath.item]
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
