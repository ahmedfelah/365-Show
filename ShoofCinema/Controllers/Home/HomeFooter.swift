//
//  HomeFooter.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 4/11/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class HomeFooter: UICollectionReusableView {
    
    
    @IBOutlet weak var indicator : NVActivityIndicatorView!
    
    override func awakeFromNib() {
        indicator.type = .ballPulse
        indicator.tintColor = Theme.current.tintColor
//        showIndicator()
    }
    
    
    public func hideIndicator () {
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    
    public func showIndicator () {
        indicator.startAnimating()
        indicator.isHidden = false
    }
        
}
