//
//  MainNavbarItem.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/14/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit


class MainNavBarItem : UIBarButtonItem {
    
    let activityIndicator = UIActivityIndicatorView()
    
    lazy var buttonString = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        buttonString = self.title ?? "item"
        /// setting the font
        self.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18)], for: .normal)
        activityIndicator.color = .white
        activityIndicator.isHidden = true
    }
    
    func showActivityIndicator() {
        self.title = ""
        self.isEnabled = false
        self.customView = activityIndicator
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        self.customView = nil
        self.title = buttonString
        self.isEnabled = true
    }
    
}
