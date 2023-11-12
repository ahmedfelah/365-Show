//
//  SCButton.swift
//  SuperCell
//
//  Created by Husam Aamer on 4/6/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

@IBDesignable
class SCButton: UIButton {
    @IBInspectable var hasShadow : Bool = true
    @IBInspectable var isTinted : Bool = true
    lazy var backgroundLayer:CAShapeLayer = CAShapeLayer()
    
    override var backgroundColor: UIColor? {
        set {
            backgroundLayer.fillColor = newValue?.cgColor
        }
        get {
            return UIColor(cgColor: backgroundLayer.fillColor ?? UIColor.clear.cgColor)
        }
    }
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? Theme.current.pressed_areaColor : Theme.current.buttonColor
            if isTinted {
                tintColor = isSelected ? Theme.current.tintColor : Theme.current.captionsColor
            }
            updateShadow()
        }
    }
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Theme.current.pressed_areaColor : isSelected ? Theme.current.pressed_areaColor : Theme.current.buttonColor
            updateShadow()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    init (fontSize:CGFloat) {
        super.init(frame: .zero)
        self.commonInit(fontSize: fontSize)
    }
    func commonInit (fontSize:CGFloat? = nil) {
        titleLabel?.adjustsFontSizeToFitWidth = true
        
        layer.insertSublayer(backgroundLayer, below: imageView?.layer)
        backgroundLayer.frame = bounds
        backgroundLayer.lineWidth = 1
        backgroundLayer.strokeColor = Theme.current.separatorColor.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        
        if isSelected {
            backgroundColor         = Theme.current.pressed_areaColor
        } else {
            backgroundColor         = Theme.current.buttonColor
        }
        titleLabel?.font        = fontSize != nil ? Fonts.almaraiLight(fontSize!) : Fonts.almaraiLight()
        titleLabel?.textColor   = Theme.current.captionsColor
        
        if isRTL {
            contentEdgeInsets       = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 14)
            imageEdgeInsets         = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        } else {
            contentEdgeInsets       = UIEdgeInsets(top: 4, left: 14, bottom: 4, right: 8)
            imageEdgeInsets         = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        }
        
        if isTinted {
            tintColor = isSelected ? Theme.current.tintColor : Theme.current.captionsColor
        }
        
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    override func prepareForInterfaceBuilder() {
        backgroundColor = Theme.current.buttonColor
    }
    override func draw(_ rect: CGRect) {
        
        updateShadow()
    }
    func updateShadow() {
        if !hasShadow {
            return
        }
        if isSelected || isHighlighted {
            layer.shadowColor = nil//Colors.separator.cgColor
            //layer.shadowOffset = CGSize.init(width: 0, height: -2)
        } else {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize.init(width: 0, height: 2)
        }
        layer.shadowOpacity = 1
        layer.shadowRadius  = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
    }
}

extension SCButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            let indicator = UIActivityIndicatorView(style: .white)
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
            
        } else {
            self.isEnabled = true
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
            
        }
    }
}
