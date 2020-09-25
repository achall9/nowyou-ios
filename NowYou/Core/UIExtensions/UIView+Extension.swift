//
//  UIView+Extension.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width))/self.frame.width) + 1
    }
}

extension UIView {
    
    func setRoundCorner(radius: CGFloat)
    {
        layer.cornerRadius  = radius
        clipsToBounds       = true
    }
    
    func setCircular() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius  = frame.size.height / 2
        clipsToBounds       = true
    }
    
    func setCornerRadius() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: 2000), byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        layoutIfNeeded()
    }
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    
    // transformed coordinate
    /// Helper to get pre transform frame
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    /// Helper to get point offset from center
    func centerOffset(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - center.x, y: point.y - center.y)
    }
    
    /// Helper to get point back relative to center
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + center.x, y: point.y + center.y)
    }
    
    /// Helper to get point relative to transformed coords
    func newPointInView(_ point: CGPoint) -> CGPoint {
        // get offset from center
        let offset = centerOffset(point)
        // get transformed point
        let transformedPoint = offset.applying(transform)
        // make relative to center
        return pointRelativeToCenter(transformedPoint)
    }
    
    var newTopLeft: CGPoint {
        return newPointInView(originalFrame.origin)
    }
    
    var newTopRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        return newPointInView(point)
    }
    
    var newBottomLeft: CGPoint {
        var point = originalFrame.origin
        point.y += originalFrame.height
        return newPointInView(point)
    }
    
    var newBottomRight: CGPoint {
        var point = originalFrame.origin
        point.x += originalFrame.width
        point.y += originalFrame.height
        return newPointInView(point)
    }
    
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    public func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
        ) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        let exists = existedBorder != nil
        if !exists {
            layer.addSublayer(border)
        }
        
    }
    
    public func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}


extension UIView {
    
    func pinEdgesToSuperView() {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
    }
    
}
extension CALayer {
func addShadow(radius: CGFloat) {
    self.shadowOffset = .zero
    self.shadowOpacity = 0.2
    self.shadowRadius = radius
    self.shadowColor = UIColor.black.cgColor
    self.masksToBounds = false
    if cornerRadius != 0 {
        addShadowWithRoundedCorners()
    }
}

func roundCorners(radius: CGFloat) {
    self.cornerRadius = radius
    self.masksToBounds = true
    if shadowOpacity != 0 {
        addShadowWithRoundedCorners()
    }
}
    func addShadowWithRoundedCorners() {
        if let contents = self.contents {
            masksToBounds = false
            sublayers?.filter{ $0.frame.equalTo(self.bounds) }
                .forEach{ $0.roundCorners(radius: self.cornerRadius) }
            self.contents = nil
            if let sublayer = sublayers?.first,
                sublayer.name == "shadow_layer" {
                sublayer.removeFromSuperlayer()
            }
            let contentLayer = CALayer()
            contentLayer.name = "shadow_layer"
            contentLayer.contents = contents
            contentLayer.frame = bounds
            contentLayer.cornerRadius = cornerRadius
            contentLayer.masksToBounds = true
            insertSublayer(contentLayer, at: 0)
        }
    }
}
@IBDesignable extension UIView{
    @IBInspectable
    public var cornersRadius: CGFloat{
        set{
            self.layer.roundCorners(radius: newValue)
        }get{
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable
    public var shadowRadius: CGFloat {
        set{
            self.layer.addShadow(radius: newValue)
        }get{
            return self.layer.shadowRadius
        }
    }
}
extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        for v in removedSubviews {
            if v.superview != nil {
                NSLayoutConstraint.deactivate(v.constraints)
                v.removeFromSuperview()
            }
        }
    }
}


extension UIButton {
    func drawBottomLine() {
        let bottomLine: UIView = UIView(frame: CGRect(x: 0, y: self.frame.height - 3, width: self.frame.width, height: 3))
        bottomLine.tag = 1000
        bottomLine.backgroundColor = .white
        self.addSubview(bottomLine)
    }
    
    func removeBottomLine() {
        self.subviews.forEach {
            if $0.tag == 1000 {
                $0.removeFromSuperview()
            }
        }
    }
}
extension UILabel{
    func setRightRadius(){
          // Probably inside init
        layer.borderWidth = 1.5
            layer.borderColor =  UIColor(hexValue: 0x0B691C).withAlphaComponent(0.6).cgColor
            layer.cornerRadius = 8
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            self.layer.masksToBounds = true
        }
        
    func setleftRadius(){
      // Probably inside init
        layer.borderWidth = 1.5
        layer.borderColor =  UIColor(hexValue: 0x0B691C).withAlphaComponent(0.6).cgColor
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.layer.masksToBounds = true
    }
    
    func setlabelCorner()
    {
        layer.borderWidth = 1.5
        layer.borderColor =  UIColor.lightGray.withAlphaComponent(0.4).cgColor
        layer.cornerRadius = 4
        self.layer.masksToBounds = true
    }
}
