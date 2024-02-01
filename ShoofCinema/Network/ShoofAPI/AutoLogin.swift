//
//  AutoLogin.swift
//  ShoofCinema
//
//  Created by ممم on 10/10/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


struct Reseller: Codable {
    let status: Int
    let message: String?
    let token: String?
}
extension ShoofAPI {
    struct AutoLogin : Codable {
        let token: String?
        
        static var current: Bool {
            get {
                return UserDefaults.standard.bool(forKey: "AUTO-LOGIN")
            }
            
            set {
                UserDefaults.standard.set(true, forKey: "AUTO-LOGIN")
            }
        }
    }
}
