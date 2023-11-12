//
//  Theme.swift
//  ShoofCinema
//
//  Created by mac on 3/12/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit



class Theme {
    static var current: ThemeProtocol = ShoofAPI.User.ramadanTheme ? LightTheme() : DarkTheme()
}
