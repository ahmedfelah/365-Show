//
//  UIApplication.swift
//  ShoofCinema
//
//  Created by mac on 3/13/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit


extension UINavigationController {
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.tag = 100
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
    
    func removeStatusBar() {
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        else {
            print("No!")
        }
    }
    
}

