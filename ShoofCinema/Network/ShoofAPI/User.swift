//
//  User.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct User : Codable {
        let name: String?
        let userName: String?
        let email: String?
        let phone: String?
        let id: String
        let token: String?
        let image: URL?
        let topics: [String]?
        
        static var current: Self? {
            get {
                do {
                    return try UserDefaults.standard.decodable(forKey: "SHOOF-USER")
                } catch {
                    // User Object keys have changed... need to reset user
                    ShoofAPI.shared.signOut()
                }
                
                return nil
            }
            
            set {
                UserDefaults.standard.setEncodable(newValue, forKey: "SHOOF-USER")
                NotificationCenter.default.post(name: .userDidChange, object: newValue)
            }
        }
        
        static var ramadanTheme: Bool {
            get {
                return  UserDefaults.standard.bool(forKey: "ramadanMode") ? true : false
            }
            
            set {
                UserDefaults.standard.setValue(newValue, forKey: "ramadanMode")
                UserDefaults.standard.synchronize()
            }
        }
        
        static var language: String {
            get {
                return Locale.current.languageCode ?? "ar"  == "ar" ? "ar-iq" : "en-us"
            }
        }
    }
}

extension Notification.Name {
    static let userDidChange = Notification.Name("ShoofAPI-userDidChange")
}
