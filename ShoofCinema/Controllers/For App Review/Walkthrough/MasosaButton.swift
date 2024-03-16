//
//  GradientButton.swift
//  Masosa
//
//  Created by Husam Aamer on 5/1/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

@IBDesignable
class MasosaButton: UIButton {
    @IBInspectable var corner:CGFloat = 5
    @IBInspectable var withGradient:Bool = true
    
    init(frame: CGRect, corner:CGFloat = 5,withGradient:Bool = true) {
        super.init(frame: frame)
        
        self.corner = corner
        self.withGradient = withGradient
        
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    func commonInit () {
        titleLabel?.font = UIFont.systemFont(ofSize: titleLabel!.font.pointSize, weight: .semibold)
        contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
    }
    var drawn = false
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if !drawn {
            //Set corner radius
            layer.cornerRadius = corner
            layer.masksToBounds = true
            
            //Add gradient
            if withGradient {
                setTitleColor(.white, for: .normal)
                let colors = [UIColor(named: "secondary-brand") ?? .red]
                setGradientBackgroundColors(colors, direction: .toBottomRight, for: .normal)
            }
        }
    }
    
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
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.imageEdgeInsets.top = -buttonHeight * 2
                self.titleEdgeInsets.top = -buttonHeight * 2
                self.layoutSubviews()
            }, completion: nil)
        } else {
            self.isEnabled = true
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
            self.imageEdgeInsets.top = frame.height * 2
            self.titleEdgeInsets.top = frame.height * 2
            self.layoutSubviews()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.imageEdgeInsets.top = 0
                self.titleEdgeInsets.top = 0
                self.layoutSubviews()
            }, completion: nil)
            
        }
    }
}
public extension UIButton {
    func setGradientBackgroundColors(_ colors: [UIColor], direction: DTImageGradientDirection, for state: UIControl.State) {
        if colors.count > 1 {
            // Gradient background
            setBackgroundImage(UIImage(size: CGSize(width: 1, height: 1), direction: direction, colors: colors), for: state)
        }
        else {
            if let color = colors.first {
                // Mono color background
                setBackgroundImage(UIImage(color: color, size: CGSize(width: 1, height: 1)), for: state)
            }
            else {
                // Default background color
                setBackgroundImage(nil, for: state)
            }
        }
    }
}
public enum DTImageGradientDirection {
    case toLeft
    case toRight
    case toTop
    case toBottom
    case toBottomLeft
    case toBottomRight
    case toTopLeft
    case toTopRight
}

public extension UIImage {
    convenience init?(size: CGSize, direction: DTImageGradientDirection, colors: [UIColor]) {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil } // If the size is zero, the context will be nil.
        
        guard colors.count >= 1 else { return nil } // If less than 1 color, return nil
        
        if colors.count == 1 {
            // Mono color
            let color = colors.first!
            color.setFill()
            
            let rect = CGRect(origin: CGPoint.zero, size: size)
            UIRectFill(rect)
        }
        else {
            // Gradient color
            var location: CGFloat = 0
            var locations: [CGFloat] = []
            
            for (index, _) in colors.enumerated() {
                let index = CGFloat(index)
                locations.append(index / CGFloat(colors.count - 1))
            }
            
            guard let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors.compactMap { $0.cgColor.components }.flatMap { $0 }, locations: locations, count: colors.count) else {
                return nil
            }
            
            var startPoint: CGPoint
            var endPoint: CGPoint
            
            switch direction {
            case .toLeft:
                startPoint = CGPoint(x: size.width, y: size.height/2)
                endPoint = CGPoint(x: 0.0, y: size.height/2)
            case .toRight:
                startPoint = CGPoint(x: 0.0, y: size.height/2)
                endPoint = CGPoint(x: size.width, y: size.height/2)
            case .toTop:
                startPoint = CGPoint(x: size.width/2, y: size.height)
                endPoint = CGPoint(x: size.width/2, y: 0.0)
            case .toBottom:
                startPoint = CGPoint(x: size.width/2, y: 0.0)
                endPoint = CGPoint(x: size.width/2, y: size.height)
            case .toBottomLeft:
                startPoint = CGPoint(x: size.width, y: 0.0)
                endPoint = CGPoint(x: 0.0, y: size.height)
            case .toBottomRight:
                startPoint = CGPoint(x: 0.0, y: 0.0)
                endPoint = CGPoint(x: size.width, y: size.height)
            case .toTopLeft:
                startPoint = CGPoint(x: size.width, y: size.height)
                endPoint = CGPoint(x: 0.0, y: 0.0)
            case .toTopRight:
                startPoint = CGPoint(x: 0.0, y: size.height)
                endPoint = CGPoint(x: size.width, y: 0.0)
            }
            
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions())
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        
        self.init(cgImage: image)
        
        defer { UIGraphicsEndImageContext() }
    }
    
    convenience init?(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIRectFill(rect)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        
        self.init(cgImage: image)
        
        defer { UIGraphicsEndImageContext() }
    }
}
