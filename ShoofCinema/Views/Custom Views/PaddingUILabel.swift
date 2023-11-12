//
//  PadingUILabel.swift
//  Enjaz Services
//
//  Created by Abdulla Jafar on 2/19/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class PaddingUILabel: MainLabel {
    
    
    @IBInspectable var sidesInset: CGFloat = 13
    @IBInspectable var topAndDownInset: CGFloat = 10
    

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        layer.cornerRadius = (size.height + (2 * topAndDownInset)) / 2
        layer.masksToBounds = true
        return CGSize(width: size.width + (2 * sidesInset),
                      height: size.height + (2 * topAndDownInset))
    }
    
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topAndDownInset, left: sidesInset, bottom: topAndDownInset, right: sidesInset)
        super.drawText(in: rect.inset(by: insets))

    }
    
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (sidesInset)
        }
    }
    

}
