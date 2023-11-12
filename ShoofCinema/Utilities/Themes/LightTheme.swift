//
//  LightTheme.swift
//  ShoofCinema
//
//  Created by mac on 3/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit



struct LightTheme: ThemeProtocol {
    
    var tintColor: UIColor = UIColor(red: 1, green: 0.803, blue: 0.621, alpha: 1)
    
    var secondaryColor: UIColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.00)
    
    var tabbarColor: UIColor = UIColor(named: "Navy") ?? .blue
    
    var secondaryLightColor: UIColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.00)
    
    var ratingColor: UIColor = UIColor(red:1, green:0.77, blue:0.07, alpha:1)
    
    var bright_tintColor: UIColor = UIColor(red:0.82, green:0.12, blue:0.27, alpha:1)
    
    var navbarColor: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1)
    
    var captionsColor: UIColor = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1)
    
    var captionsDarkerColor: UIColor = UIColor(red:0.423, green:0.423, blue:0.423, alpha:1)
    
    var textColor: UIColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1)
    
    var pressed_areaColor: UIColor =  UIColor(red:0.11, green:0.11, blue:0.11, alpha:1)
    
    var backgroundColor: UIColor = UIColor(named: "Navy") ?? .blue
    
    var separatorColor: UIColor = UIColor(red:0.217, green:0.217, blue:0.217, alpha:1.00)
    
    var buttonColor: UIColor = .systemOrange
    
    var splashScreenVideoUrl: URL? = Bundle.main.url(forResource: "ramadan-mode", withExtension: "mp4")
    
}
