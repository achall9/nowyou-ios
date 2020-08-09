//
//  ViewGestures.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/24/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit
import ActiveLabel

extension PhotoEditorViewController : UIGestureRecognizerDelegate  {
    //Translation is moving object
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                if recognizer.state == .began {
                    
                    var img: UIImageView
                    if frames.count > 1 {
                        img = tempImageViews[selectedFrame]
                    } else {
                        img = self.tempImageView
                    }
                    img.isUserInteractionEnabled = true
                    for tempImageView in subImageViews(view: img) {
                        let location = recognizer.location(in: tempImageView)
                        let alpha = tempImageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = tempImageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.numberOfTouches > 1 else {
            return
        }
        
        if let view = recognizer.view {
            let point1 = recognizer.location(ofTouch: 0, in: view)
            let point2 = recognizer.location(ofTouch: 1, in: view)
            
            var pinchView: UIView?
            
            for subview in tempImageView.subviews {
                if subview.frame.contains(point1) || subview.frame.contains(point2) {
                    
                    if subview is UITextView || subview is UITextField {
                        pinchView = subview
                        break
                    } else {
                        if subview is UIImageView {
                            continue
                        }
                        
                        pinchView = subview
                        break
                    }
                }
            }
            
            if pinchView == nil {return}
//            pinchView = view
            
            pinchView!.transform = pinchView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1.0
            
            return
            if pinchView is UITextView || pinchView is UITextField {
                pinchView?.backgroundColor = UIColor.green
                if let textView = pinchView as? UITextView {
                    if textView.font!.pointSize * recognizer.scale < 120 {
                        let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                        textView.font = font
                        let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                     height:CGFloat.greatestFiniteMagnitude))
                        textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                      height: sizeToFit.height)
                        
                    } else {
                        let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                     height:CGFloat.greatestFiniteMagnitude))
                        textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                                      height: sizeToFit.height)
                    }
                    
//                    textView.sizeToFit()
                    
                    
                    textView.setNeedsLayout()
                    textView.setNeedsDisplay()
                    
                } else if let textField = pinchView as? UITextField {
                    if textField.font!.pointSize * recognizer.scale < 150 {
                        let font = UIFont(name: textField.font!.fontName, size: textField.font!.pointSize * recognizer.scale)
                        textField.font = font
                        let sizeToFit = textField.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                     height:CGFloat.greatestFiniteMagnitude))
                        
                        if textField.intrinsicContentSize.width > UIScreen.main.bounds.size.width {
                            return
                        }
                        
                        textField.bounds.size = CGSize(width: textField.intrinsicContentSize.width,
                                                      height: sizeToFit.height)
                    } else {
                        let sizeToFit = textField.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                                     height:CGFloat.greatestFiniteMagnitude))
                        textField.bounds.size = CGSize(width: textField.intrinsicContentSize.width,
                                                      height: sizeToFit.height)
                    }
                    
                    
                    textField.setNeedsDisplay()
                }

                
            } else {
                if pinchView is UIImageView {
                    return
                } else {
                    pinchView!.transform = pinchView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
                    
                    if view is ActiveLabel {
                        attachedLinkPos[selectedFrame] = view.originalFrame
                    }
                }
/*
                if pinchView == tempImageView {
                    return
                } else {
                    if pinchView is UIImageView {
                        return
                    }
                    
                    pinchView!.transform = pinchView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
                    
                    if pinchView is ActiveLabel {
                        attachedLinkPos[selectedFrame] = view.originalFrame
                    }
                } */
            }
/*
            if view is UITextView {
                let textView = view as! UITextView
                let font = UIFont(name: textView.font!.fontName, size: textView.font!.pointSize * recognizer.scale)
                textView.font = font
                
                let sizeToFit = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width,
                                                             height:CGFloat.greatestFiniteMagnitude))
                
                textView.bounds.size = CGSize(width: textView.intrinsicContentSize.width,
                                              height: sizeToFit.height)
                
                textView.setNeedsDisplay()
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
                
                if view is ActiveLabel {
                    attachedLinkPos[selectedFrame] = view.originalFrame
                }
            }
 */
            recognizer.scale = 1
        }
    }

    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        guard recognizer.numberOfTouches > 1 else {
            return
        }
        
        if let view = recognizer.view {
            
            let point1 = recognizer.location(ofTouch: 0, in: view)
            let point2 = recognizer.location(ofTouch: 1, in: view)
            
            var rotateView: UIView?
            
            for subview in tempImageView.subviews {
                if subview.frame.contains(point1) || subview.frame.contains(point2) {
                    
                    if subview is UIImageView {
                        continue;
                    }
                    
                    rotateView = subview
                    break
                }
            }
            
            if rotateView == nil {return}
            
            rotateView!.transform = rotateView!.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            
            if rotateView is ActiveLabel {
                attachedLinkPos[selectedFrame] = rotateView!.originalFrame
                if let angle: NSNumber = view.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber {
                    attachedLinkPosAngle[selectedFrame] = angle.floatValue
                    
                }
            }
        }
    }
    
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                
            /*    var img: UIImageView
                if frames.count > 1 {
                    img = tempImageViews[selectedFrame]
                } else {
                    img = self.tempImageView
                }
                
                //Tap only on visible parts on the image
                for tempImageView in subImageViews(view: img) {
                    let location = recognizer.location(in: tempImageView)
                    let alpha = tempImageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: tempImageView)
                        break
                    }
                }*/
                if doneButton.isHidden {
                    textButtonTapped(nil)
                } else {
                    self.view.endEditing(true)
                }
            } else {
                
                if view is UITextField || view is UITextView {
                    view.becomeFirstResponder()
                } else {
                    scaleEffect(view: view)
                }
                
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
//        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer {
            return true
        }
//        if otherGestureRecognizer is UIPinchGestureRecognizer {
//            return true
//        }
        return false
    }
    
    @objc func txtEdittapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextField || view is UITextView {
                view.becomeFirstResponder()
            } else {
                if doneButton.isHidden {
                    textButtonTapped(nil)
                } else {
                    self.view.endEditing(true)
                }
            }
        }
    }
    
   @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            if !bottomSheetIsVisible {
                addBottomSheetView()
            }
        }
    }
    
    // to Override Control Center screen edge pan from bottom
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
   func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        hideToolbar(hide: true)
        deleteView.isHidden = false
        
    view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: self.view)
        //
    
    var img: UIImageView
    if frames.count > 1 {
        img = tempImageViews[selectedFrame]
    } else {
        img = self.tempImageView
    }
    
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: img).x,
                              y: view.center.y + recognizer.translation(in: img).y)
        
        //        let point = recognizer.location(in: tempImageView)
        //        view.center = point
        
        recognizer.setTranslation(CGPoint.zero, in: img)
        
        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recognizer.location(in: img)
                })
            }
                //View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recognizer.location(in: img)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            hideToolbar(hide: false)
            deleteView.isHidden = true
            let point = recognizer.location(in: self.view)
            
            if deleteView.frame.contains(point) { // Delete the view
                
                self.attachedLinkPos[selectedFrame] = CGRect.zero
                self.attachedLinks[selectedFrame] = ""
                
                view.removeFromSuperview()
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } else if !tempImageView.bounds.contains(view.center) { //Snap the view back to tempimageview
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = img.center
                    
                    if view is ActiveLabel {
                        self.attachedLinkPos[self.selectedFrame] = view.originalFrame
                        
                    }
                })
                
            } else {
                self.attachedLinkPos[self.selectedFrame] = view.originalFrame
                
            }
        }
    }
    
   @objc func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for tempImageView in view.subviews {
            if tempImageView is UIImageView {
                imageviews.append(tempImageView as! UIImageView)
            }
        }
        return imageviews
    }
}
