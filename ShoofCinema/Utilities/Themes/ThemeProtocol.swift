//
//  ThemeProtocol.swift
//  ShoofCinema
//
//  Created by mac on 3/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit


protocol ThemeProtocol {
    
    var tintColor: UIColor { get set }
    
    var secondaryColor: UIColor { get set }
    
    var tabbarColor: UIColor { get set }
    
    var secondaryLightColor: UIColor { get set }

    
    var ratingColor: UIColor { get set }
    
    var bright_tintColor: UIColor { get set }
    
    
    var navbarColor: UIColor { get set }
    
    var captionsColor: UIColor { get set }
    
    var captionsDarkerColor: UIColor { get set }
    
    var textColor: UIColor { get set }
    
    var pressed_areaColor: UIColor { get set }
    
    var backgroundColor: UIColor { get set }
    
    var separatorColor: UIColor { get set }
    
    var buttonColor: UIColor { get set }
    
    var splashScreenVideoUrl: URL? { get set }
    
}
