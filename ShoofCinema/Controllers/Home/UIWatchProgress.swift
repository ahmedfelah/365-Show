//
//  UIWatchProgress.swift
//  Giganet
//
//  Created by Husam Aamer on 5/9/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit

@IBDesignable
class UIWatchProgress: UIView {
    var progress:CGFloat = 0.5 {
        didSet {
            if progress.isNaN || progress.isInfinite {
                progress = 0
            }
            layoutSubviews()
        }
    }
    
    private var fillLayer:CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    func commonInit() {
        backgroundColor = UIColor.white.withAlphaComponent(0.3)
        layer.cornerRadius = 2
        //layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        //layer.borderWidth = 1
        layer.masksToBounds = true
        
        fillLayer = CAShapeLayer()
        fillLayer.backgroundColor = Theme.current.textColor.cgColor
        fillLayer.opacity = 0.9
        layer.addSublayer(fillLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fillLayer.frame = bounds
        fillLayer.frame.setW(progress * frame.width)
        
        if isRTL {
            fillLayer.frame.setX(bounds.width - fillLayer.frame.width)
        }
        
        if progress <= 0 {
            alpha = 0
        } else {
            alpha = 1
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
