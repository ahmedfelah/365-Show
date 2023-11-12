//
//  VerticalButton.swift
//  Giganet
//
//  Created by Husam Aamer on 4/25/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import Shimmer
/// This is a subclass of `FBShimmeringView` to allow creating shimmering view via IB
// When designing your shimmering view make the first subview as a container for all elements
@IBDesignable
class FBShimmeringView2: FBShimmeringView {
    @IBInspectable var startShimmering:Bool = false {
        didSet {
            isShimmering = startShimmering
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        if let container = subviews.first {
            contentView = container
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
