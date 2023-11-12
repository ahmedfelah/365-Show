//
//  GradientView.swift
//
//  Created by Mathieu Vandeginste on 06/12/2016.
//  Copyright © 2018 Mathieu Vandeginste. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
   
    public var gradientLayer: CAGradientLayer!
    
    @IBInspectable var topColor: UIColor = Theme.current.backgroundColor {
        didSet {
            self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        }
    }
    
    @IBInspectable var bottomColor: UIColor = Theme.current.backgroundColor {
        didSet {
            self.gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        }
    }
    
//    @IBInspectable var shadowColor: UIColor = .clear {
//        didSet {
//            self.layer.shadowColor = shadowColor.cgColor
//        }
//    }
//
//    @IBInspectable var shadowX: CGFloat = 0 {
//        didSet {
//            self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
//        }
//    }
    
//    @IBInspectable var shadowY: CGFloat = -3 {
//        didSet {
//            self.layer.shadowOffset = CGSize(width: shadowX, height: shadowY)
//        }
//    }
    
//    @IBInspectable var shadowBlur: CGFloat = 3 {
//        didSet {
//            self.layer.shadowRadius = shadowBlur
//        }
//    }
    
    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        }
    }
    
    @IBInspectable var startPointY: CGFloat = 0.5 {
        didSet {
            self.gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        }
    }
    
    @IBInspectable var endPointX: CGFloat = 1 {
        didSet {
            self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        }
    }
    
    @IBInspectable var endPointY: CGFloat = 0.5 {
        didSet {
            self.gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit () {
        self.gradientLayer = self.layer as? CAGradientLayer
        //self.layer.shadowOpacity = 1
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = frame
    }
    
    func animate(duration: TimeInterval, newTopColor: UIColor, newBottomColor: UIColor) {
        let fromColors = self.gradientLayer?.colors
        let toColors: [AnyObject] = [ newTopColor.cgColor, newBottomColor.cgColor]
        self.gradientLayer?.colors = toColors
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = duration
        animation.isRemovedOnCompletion = true
//        animation.fillMode = CAMediaTimingFillMode.forwards
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        self.gradientLayer?.add(animation, forKey:"animateGradient")
    }
}
