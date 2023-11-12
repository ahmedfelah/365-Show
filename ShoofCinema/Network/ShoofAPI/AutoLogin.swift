//
//  AutoLogin.swift
//  ShoofCinema
//
//  Created by ممم on 10/10/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


extension ShoofAPI {
    struct Reseller {
        let host: String
        let path: String
        
        static var urls: [Self] = {
            [
                .init(
                    host: "reselller1.supercellnetwork.com",
                    path: "/user/api/index.php/api/auth/autoLogin"
                ),
                .init(
                    host: "http://reselller2.supercellnetwork.com/",
                    path: "user/api/index.php/api/auth/autoLogin"
                ),
                .init(
                    host: "http://reselller3.supercellnetwork.com/",
                    path: "user/api/index.php/api/auth/autoLogin"
                ),
                .init(
                    host: "http://reselller4.supercellnetwork.com/",
                    path: "user/api/index.php/api/auth/autoLogin"
                ),
                .init(
                    host: "http://reseller.scn-ftth.com/user/api/index.php/api/auth/autoLogin",
                    path: "user/api/index.php/api/auth/autoLogin"
                )
                
            ]
            
        }()
    }
    
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
