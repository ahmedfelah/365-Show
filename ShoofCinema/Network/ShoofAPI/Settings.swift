//
//  Settings.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/4/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    class Settings {
        static let shared = Settings()
        
        @UserDefault("SHOOF-FAMILYMOD") var isFamilyModOn: Bool = true {
            didSet {
                NotificationCenter.default.post(name: .familyModDidChange, object: isFamilyModOn)
            }
        }
        
//        var isFamilyModOn: Bool {
//            get {
//                UserDefaults.standard.bool(forKey: "SHOOF-FAMILYMOD")
//            } set {
//                UserDefaults.standard.set(newValue, forKey: "SHOOF-FAMILYMOD")
//                NotificationCenter.default.post(name: .familyModDidChange, object: newValue)
//            }
//        }
    }
}

extension Notification.Name {
    static let familyModDidChange = Notification.Name("SHOOF-familyModDidChange")
}
