//
//  DarkTheme.swift
//  ShoofCinema
//
//  Created by mac on 3/12/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit


struct DarkTheme: ThemeProtocol {
    
    var tintColor: UIColor = UIColor(red: 0.83921569, green: 0.01568627, blue: 0.01568627, alpha: 1.00)
    
    var secondaryColor: UIColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.00)
    
    var tabbarColor: UIColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00)
    
    var secondaryLightColor: UIColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.00)
        
    
    var ratingColor: UIColor = UIColor(red:1, green:0.77, blue:0.07, alpha:1)
    
    var bright_tintColor: UIColor = UIColor(red:0.82, green:0.12, blue:0.27, alpha:1)
    
    var navbarColor: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
    
    var captionsColor: UIColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1)
    
    var captionsDarkerColor: UIColor = UIColor(red:0.423, green:0.423, blue:0.423, alpha:1)
    
    var textColor: UIColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1)
    
    var pressed_areaColor: UIColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1)
    
    var backgroundColor: UIColor = UIColor(red:0, green:0, blue:0, alpha:1.00)
    
    var separatorColor: UIColor = UIColor(red:0.217, green:0.217, blue:0.217, alpha:1.00)
    
    var buttonColor: UIColor = UIColor(red:0.196, green:0.196, blue:0.196, alpha:1.00)
    
    var splashScreenVideoUrl: URL? = Bundle.main.url(forResource: "default-mode", withExtension: "mp4")
    
    
}
