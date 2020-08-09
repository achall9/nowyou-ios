//
//  CameraRollViewController.swift
//  NowYou
//
//  Created by Apple on 1/25/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

protocol CameraRollDelegate {
    func selectedAsset(asset: PHAsset)
}

class CameraRollViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var clvCameraRoll: UICollectionView!
    
    var assets = PHFetchResult<PHAsset>()
    
    var delegate: CameraRollDelegate?
    
    var interactor = Interactor()
    let transition = CATransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(gesture(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)

        
        clvCameraRoll.layer.cornerRadius = 3
        clvCameraRoll.layer.masksToBounds = true
        checkAuthorizationForPhotoLibraryAndGet()
    }
    

    private func checkAuthorizationForPhotoLibraryAndGet(){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            getPhotosAndVideos()
        }else {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.getPhotosAndVideos()
                }else {
                    
                }
            })
        }
    }

    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.window?.layer.add(transition, forKey: nil)
        
        if let homeVc = presentingViewController {
            homeVc.view.alpha = 1.0
        }
        navigationController?.popViewController(animated: false)
//        dismiss(animated: false, completion: nil)
    }
    
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.15
        let translation = sender.translation(in: view)
        let fingerMovement = translation.y / view.bounds.height
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor.hasStarted = true
//            dismiss(animated: true)
            
        case .changed:
            
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
            
        case .cancelled:
            
            interactor.hasStarted = false
            interactor.cancel()
            
        case .ended:
            
            interactor.hasStarted = false
            
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
    
    private func getPhotosAndVideos(){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        assets = PHAsset.fetchAssets(with: fetchOptions)
        
        DispatchQueue.main.async {
            self.clvCameraRoll.reloadData()
        }
        
    }
    
    @IBAction func swipeDown(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        transitionDismissal()
    }
    
}

extension CameraRollViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CameraRollCell
        
        let asset = assets[indexPath.row]
        
        cell.imgThumbnail.image = asset.thumbnailImage
        
        let duration = asset.duration
        
        if duration == 0 {
            cell.lblLength.isHidden = true
        } else {
            cell.lblLength.isHidden = false
            cell.lblLength.text = getFormattedString(time: Int(duration))
        }
        
        return cell
    }
    
    func getFormattedString(time: Int) -> String {
        if time < 10 {
            return "00:0\(time)"
        }
        
        let min = time / 60
        let sec = time % 60
        
        let minStr = min < 10 ? "0\(min)" : "\(min)"
        let secStr = sec < 10 ? "0\(sec)" : "\(sec)"
        
        return "\(minStr):\(secStr)"
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        delegate?.selectedAsset(asset: assets[indexPath.row])
        navigationController?.popViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 6) / 3
        
        return CGSize(width: width, height: width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        print (clvCameraRoll.contentOffset.y)
        if clvCameraRoll.contentOffset.y < 5 {
            return true
        }
        
        return false
    }
}
