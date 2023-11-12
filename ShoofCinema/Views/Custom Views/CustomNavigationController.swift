//
//  CustomNavigationController.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/26/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        var prefersStatusBarHidden: Bool {
            return tabBar?.statusBarShouldBeHidden ?? false
        }
        var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
            return .slide
        }
        
        var preferredStatusBarStyle: UIStatusBarStyle {get {return .lightContent}}

        var prefersHomeIndicatorAutoHidden: Bool {
            return tabBar?.homeIndicatorShouldBeHidden ?? false
        }
        
    }
    

}
