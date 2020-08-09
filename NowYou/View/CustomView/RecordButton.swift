//
//  RecordButton.swift
//  Instant
//
//  Created by Samuel Beek on 21/06/15.
//  Copyright (c) 2015 Samuel Beek. All rights reserved.
//

import UIKit

@objc public enum RecordButtonState : Int {
    case recording, idle, hidden;
}

@objc open class RecordButton : UIButton {
    
    open var buttonColor: UIColor! = .white {
        didSet {
            circleLayer.backgroundColor = buttonColor.cgColor
            circleBorder.borderColor = buttonColor.cgColor
        }
    }
    
    open var progressColor: UIColor!  = .red {
        didSet {
//            gradientMaskLayer.colors = [progressColor.cgColor, progressColor.cgColor]
        }
    }
    
    
    var progress1Color: UIColor = UIColor(hexValue: 0xF0CF3F)
    var progress2Color: UIColor = UIColor(hexValue: 0x3FADF0)
    var progress3Color: UIColor = UIColor(hexValue: 0xE58DCF)
    var progress4Color: UIColor = UIColor(hexValue: 0xFBAE5D)
    var progress5Color: UIColor = UIColor(hexValue: 0x60DF76)
    
    /// Closes the circle and hides when the RecordButton is finished
    open var closeWhenFinished: Bool = false
    
    open var buttonState : RecordButtonState = .idle {
        didSet {
            switch buttonState {
            case .idle:
                self.alpha = 1.0
                currentProgress = 0
                setProgress(0)
                setRecording(false)
            case .recording:
                self.alpha = 1.0
                setRecording(true)
            case .hidden:
                self.alpha = 0
            }
        }
        
    }
    
    fileprivate var circleLayer: CALayer!
    fileprivate var circleBorder: CALayer!
    fileprivate var progressLayer: CAShapeLayer!
    
    fileprivate var progressLayer1: CAShapeLayer!
    fileprivate var progressLayer2: CAShapeLayer!
    fileprivate var progressLayer3: CAShapeLayer!
    fileprivate var progressLayer4: CAShapeLayer!
    fileprivate var progressLayer5: CAShapeLayer!
    
//    fileprivate var gradientMaskLayer: CAGradientLayer!
    
    fileprivate var gradientMaskLayer1: CAGradientLayer!
    fileprivate var gradientMaskLayer2: CAGradientLayer!
    fileprivate var gradientMaskLayer3: CAGradientLayer!
    fileprivate var gradientMaskLayer4: CAGradientLayer!
    fileprivate var gradientMaskLayer5: CAGradientLayer!
    
    var currentProgress: CGFloat! = 0

    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        
//        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
//        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
//        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        
//        let photoGesture = UITapGestureRecognizer(target: self, action: #selector(onTakePhoto(_:)))
//        photoGesture.numberOfTapsRequired = 1
//        self.addGestureRecognizer(photoGesture)
//
//        let recGesture = UILongPressGestureRecognizer(target: self, action: #selector(onRecVideo(_:)))
//        self.addGestureRecognizer(recGesture)
        
        self.drawButton()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.addTarget(self, action: #selector(RecordButton.didTouchDown), for: .touchDown)
//        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpInside)
//        self.addTarget(self, action: #selector(RecordButton.didTouchUp), for: .touchUpOutside)
        
//        let photoGesture = UITapGestureRecognizer(target: self, action: #selector(onTakePhoto(_:)))
//        photoGesture.numberOfTapsRequired = 1
//        self.addGestureRecognizer(photoGesture)
//
//        let recGesture = UILongPressGestureRecognizer(target: self, action: #selector(onRecVideo(_:)))
//        self.addGestureRecognizer(recGesture)
        
        self.drawButton()
    }
    
    
    fileprivate func drawButton() {
        
        self.backgroundColor = UIColor.clear
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.cgColor
        
        let size: CGFloat = self.frame.size.width / 1.5
        circleLayer.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, at: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 1
        circleBorder.borderColor = buttonColor.cgColor
        circleBorder.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width - 1.5, height: self.bounds.size.height - 1.5)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
        
//        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi/2)
//        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi/2)
        
        let startAngle: CGFloat = CGFloat(Double.pi) + CGFloat(Double.pi/2) - CGFloat(Double.pi / 10)
        let endAngle: CGFloat = CGFloat(Double.pi) * 3 + CGFloat(Double.pi/2) - CGFloat(Double.pi / 10)
        
        let centerPoint: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
//        gradientMaskLayer = self.gradientMask()
        gradientMaskLayer1 = self.gradientMask(color: progress1Color)
        gradientMaskLayer2 = self.gradientMask(color: progress2Color)
        gradientMaskLayer3 = self.gradientMask(color: progress3Color)
        gradientMaskLayer4 = self.gradientMask(color: progress4Color)
        gradientMaskLayer5 = self.gradientMask(color: progress5Color)
        
        
        progressLayer = CAShapeLayer()
        
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        progressLayer.backgroundColor = UIColor.clear.cgColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        
        
        
        let midAngle1: CGFloat = startAngle + CGFloat(2 * Double.pi / 5)
        let midAngle2: CGFloat = midAngle1 + CGFloat(2 * Double.pi / 5)
        let midAngle3: CGFloat = midAngle2 + CGFloat(2 * Double.pi / 5)
        let midAngle4: CGFloat = midAngle3 + CGFloat(2 * Double.pi / 5)
        
        progressLayer1 = CAShapeLayer()
        progressLayer1.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 4, startAngle: startAngle, endAngle: midAngle1, clockwise: true).cgPath
        progressLayer1.backgroundColor = UIColor.clear.cgColor
        progressLayer1.fillColor = nil
        progressLayer1.strokeColor = UIColor.black.cgColor
        progressLayer1.lineWidth = 8.0
        progressLayer1.strokeStart = 0.0
        progressLayer1.strokeEnd = 0.0
//        layer.insertSublayer(progressLayer1, at: 0)
        
        progressLayer2 = CAShapeLayer()
        progressLayer2.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 4, startAngle: midAngle1, endAngle: midAngle2, clockwise: true).cgPath
        progressLayer2.backgroundColor = UIColor.clear.cgColor
        progressLayer2.fillColor = nil
        progressLayer2.strokeColor = UIColor.black.cgColor
        progressLayer2.lineWidth = 8.0
        progressLayer2.strokeStart = 0.0
        progressLayer2.strokeEnd = 0.0
//        layer.insertSublayer(progressLayer2, at: 1)
        
        progressLayer3 = CAShapeLayer()
        progressLayer3.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 4, startAngle: midAngle2, endAngle: midAngle3, clockwise: true).cgPath
        progressLayer3.backgroundColor = UIColor.clear.cgColor
        progressLayer3.fillColor = nil
        progressLayer3.strokeColor = UIColor.black.cgColor
        progressLayer3.lineWidth = 8.0
        progressLayer3.strokeStart = 0.0
        progressLayer3.strokeEnd = 0.0
//        layer.insertSublayer(progressLayer3, at: 2)
        
        progressLayer4 = CAShapeLayer()
        progressLayer4.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 4, startAngle: midAngle3, endAngle: midAngle4, clockwise: true).cgPath
        progressLayer4.backgroundColor = UIColor.clear.cgColor
        progressLayer4.fillColor = nil
        progressLayer4.strokeColor = UIColor.black.cgColor
        progressLayer4.lineWidth = 8.0
        progressLayer4.strokeStart = 0.0
        progressLayer4.strokeEnd = 0.0
//        layer.insertSublayer(progressLayer4, at: 3)
        
        progressLayer5 = CAShapeLayer()
        progressLayer5.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 4, startAngle: midAngle4, endAngle: endAngle, clockwise: true).cgPath
        progressLayer5.backgroundColor = UIColor.clear.cgColor
        progressLayer5.fillColor = nil
        progressLayer5.strokeColor = UIColor.black.cgColor
        progressLayer5.lineWidth = 8.0
        progressLayer5.strokeStart = 0.0
        progressLayer5.strokeEnd = 0.0
        
//        layer.insertSublayer(progressLayer5, at: 4)
        
        gradientMaskLayer1.mask = progressLayer1
        gradientMaskLayer2.mask = progressLayer2
        gradientMaskLayer3.mask = progressLayer3
        gradientMaskLayer4.mask = progressLayer4
        gradientMaskLayer5.mask = progressLayer5
//        gradientMaskLayer.mask = progressLayer
//
//
        layer.insertSublayer(gradientMaskLayer1, at: 0)
        layer.insertSublayer(gradientMaskLayer2, at: 1)
        layer.insertSublayer(gradientMaskLayer3, at: 2)
        layer.insertSublayer(gradientMaskLayer4, at: 3)
        layer.insertSublayer(gradientMaskLayer5, at: 4)
        
    }
    
    fileprivate func setRecording(_ recording: Bool) {
        
        let duration: TimeInterval = 0.15
        circleLayer.contentsGravity = CALayerContentsGravity(rawValue: "center")
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 0.6
        scale.toValue = recording ? 0.6 : 1.0
        scale.duration = duration
        scale.fillMode = CAMediaTimingFillMode.forwards
        scale.isRemovedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = CAMediaTimingFillMode.forwards
        color.isRemovedOnCompletion = false
        color.toValue = recording ? progressColor.cgColor : buttonColor.cgColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.isRemovedOnCompletion = false
        circleAnimations.fillMode = CAMediaTimingFillMode.forwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = CAMediaTimingFillMode.forwards
        borderColor.isRemovedOnCompletion = false
        borderColor.toValue = recording ? UIColor(red: 0.83, green: 0.86, blue: 0.89, alpha: 1).cgColor : buttonColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 0.6
        borderScale.toValue = recording ? 0.6 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = CAMediaTimingFillMode.forwards
        borderScale.isRemovedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.isRemovedOnCompletion = false
        borderAnimations.fillMode = CAMediaTimingFillMode.forwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = CAMediaTimingFillMode.forwards
        fade.isRemovedOnCompletion = false
        
        circleLayer.add(circleAnimations, forKey: "circleAnimations")
        progressLayer1.add(fade, forKey: "fade")
        progressLayer2.add(fade, forKey: "fade")
        progressLayer3.add(fade, forKey: "fade")
        progressLayer4.add(fade, forKey: "fade")
        progressLayer5.add(fade, forKey: "fade")
        
        circleBorder.add(borderAnimations, forKey: "borderAnimations")
        
    }
    
    fileprivate func gradientMask(color: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
//        let topColor = UIColor(hexValue: 0xFBAE5D)// progressColor
//        let bottomColor = progressColor
        gradientLayer.colors = [color.cgColor as Any, color.cgColor as Any]
        return gradientLayer
    }
    
    override open func layoutSubviews() {
        circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleLayer.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        circleBorder.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        circleBorder.position = CGPoint(x: self.bounds.midX,y: self.bounds.midY)
        super.layoutSubviews()
    }
    
    // record video
    @objc func onRecVideo(_ sender: UIGestureRecognizer){
        if sender.state == .began {
            self.buttonState = .recording
//            print ("rec started")
        } else if sender.state == .ended {
//            print ("rec ended")
            if(closeWhenFinished) {
                self.setProgress(1)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.buttonState = .hidden
                }, completion: { completion in
                    self.setProgress(0)
                    self.currentProgress = 0
                })
            } else {
                self.buttonState = .idle
            }
        }
    }
    
    // take photo
    @objc func onTakePhoto(_ sender: UIGestureRecognizer){
//        print ("take photo")
    }
    
    @objc open func didTouchDown(){
        self.buttonState = .recording
        print ("tap down")
    }
    
    @objc open func didTouchUp() {
        print ("tap up")
        if(closeWhenFinished) {
            self.setProgress(1)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonState = .hidden
                }, completion: { completion in
                    self.setProgress(0)
                    self.currentProgress = 0
            })
        } else {
            self.buttonState = .idle
        }
    }
    
    
    /**
    Set the relative length of the circle border to the specified progress
    
    - parameter newProgress: the relative lenght, a percentage as float.
    */
    open func setProgress(_ newProgress: CGFloat) {
        if newProgress == 0 {
            progressLayer1.backgroundColor = UIColor.clear.cgColor
            progressLayer1.fillColor = nil
            progressLayer1.strokeStart = 0.0
            progressLayer1.strokeEnd = 0.0
            
            progressLayer2.backgroundColor = UIColor.clear.cgColor
            progressLayer2.fillColor = nil
            progressLayer2.strokeStart = 0.0
            progressLayer2.strokeEnd = 0.0
            
            progressLayer3.backgroundColor = UIColor.clear.cgColor
            progressLayer3.fillColor = nil
            progressLayer3.strokeStart = 0.0
            progressLayer3.strokeEnd = 0.0
            
            progressLayer4.backgroundColor = UIColor.clear.cgColor
            progressLayer4.fillColor = nil
            progressLayer4.strokeStart = 0.0
            progressLayer4.strokeEnd = 0.0
            
            progressLayer5.backgroundColor = UIColor.clear.cgColor
            progressLayer5.fillColor = nil
            progressLayer5.strokeStart = 0.0
            progressLayer5.strokeEnd = 0.0
            
            progressLayer1.strokeEnd = 0.0
            progressLayer2.strokeEnd = 0.0
            progressLayer3.strokeEnd = 0.0
            progressLayer4.strokeEnd = 0.0
            progressLayer5.strokeEnd = 0.0
            return
        }
        
        if newProgress < 0.2 {
            
            progressLayer1.strokeEnd = newProgress * 5
        } else if newProgress < 0.4 {
            
            progressLayer2.strokeEnd = (newProgress - 0.2) * 5
        } else if newProgress < 0.6 {
            
            progressLayer3.strokeEnd = (newProgress - 0.4) * 5
        } else if newProgress < 0.8 {
            
            progressLayer4.strokeEnd = (newProgress - 0.6) * 5
        } else {
            
            progressLayer5.strokeEnd = (newProgress - 0.8) * 5
        }
//        progressLayer.strokeEnd = newProgress
    }
    
    
}

