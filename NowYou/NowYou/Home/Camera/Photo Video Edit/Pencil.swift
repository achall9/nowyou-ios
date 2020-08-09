//
//  Pencil.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/26/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension PhotoEditorViewController {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        
        var img: UIImageView
        if frames.count > 1 {
            img = tempImageViews[selectedFrame]
        } else {
            img = self.tempImageView
        }
        
        img.isUserInteractionEnabled = true
        
        if isDrawing || isErasing{
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: img)
            }
        }
            //Hide stickersVC if clicked outside it
        else if bottomSheetIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !bottomSheetVC.view.frame.contains(location) {
                    removeBottomSheetView()
                }
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
//            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasView)
                drawLineFrom(lastPoint, toPoint: currentPoint, isEnded: false)
                
                // 7
                lastPoint = currentPoint
            }
        } else if isErasing {
//            swiped = true
            
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasView)
                removeLineFrom(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
//            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint, isEnded: true)
//            }
        } else if isErasing {
            if !swiped {
                // draw a single point
                removeLineFrom(lastPoint, toPoint: lastPoint)
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint, isEnded: Bool) {
        // 1
        var img: UIImageView
        if frames.count > 1 {
            img = tempImageViews[selectedFrame]
        } else {
            img = self.tempImageView
        }
        
        // get drawing subview
        var drawingView: UIImageView?
        
        for subview in img.subviews {
            if subview.tag == 200 {
                drawingView = subview as? UIImageView
            }
        }
        
        UIGraphicsBeginImageContext(img.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            if drawingView == nil {
                drawingView = UIImageView(frame: CGRect(x: 0, y: 0, width: img.frame.size.width, height: img.frame.size.height))
                drawingView?.tag = 200
                img.addSubview(drawingView!)
            }
            
            drawingView?.image?.draw(in: CGRect(x: 0, y: 0, width: img.frame.size.width, height: img.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3

            context.setLineCap( CGLineCap.round)
            context.setLineWidth(CGFloat(penWidth))
            context.setStrokeColor(drawColor.cgColor)
            
            context.setBlendMode( CGBlendMode.normal)
            

            // 4
            context.strokePath()
            // 5
            
            drawingView?.image = UIGraphicsGetImageFromCurrentImageContext()
            
//            if isEnded {
//                let image = UIGraphicsGetImageFromCurrentImageContext()
//                let imageView = UIImageView(frame: img.frame)
//                imageView.image = image
//
//                img.addSubview(imageView)
//
//                img.image = nil
//            }
            
            UIGraphicsEndImageContext()
        }
    }
    
}



