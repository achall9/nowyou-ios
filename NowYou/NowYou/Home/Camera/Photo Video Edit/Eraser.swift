//
//  Pencil.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/26/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

extension PhotoEditorViewController {
    
    func removeLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        
        var img: UIImageView
        if frames.count > 1 {
            img = tempImageViews[selectedFrame]
        } else {
            img = self.tempImageView
        }
        
        let drawingBoard = img.viewWithTag(200) as? UIImageView
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        if let context = UIGraphicsGetCurrentContext(), let drawingImgView = drawingBoard {
            drawingImgView.image?.draw(in: CGRect(x: 0, y: 0, width: drawingImgView.frame.size.width, height: drawingImgView.frame.size.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap( CGLineCap.round)
            context.setLineWidth(CGFloat(penWidth + 10))
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.clear)
            // 4
            context.strokePath()
            // 5
            drawingImgView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
}



