//
//  SCLoadingIndicator.swift
//  SuperCell
//
//  Created by Husam Aamer on 7/14/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
class SCRefreshControl: UIRefreshControl {
    
    init(target:Any, selector:Selector) {
        super.init()
        
        tintColor = Theme.current.tintColor
        addTarget(target, action: selector, for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
