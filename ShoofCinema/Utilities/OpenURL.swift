//
//  OpenURL.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/8/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation
import UIKit
class OpenURL {

    static func youtube (id:String) -> Bool {
        guard let appURL = URL(string:"youtube://\(id)") else {
            return false
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                return true
            } else {
                UIApplication.shared.openURL(appURL)
                return true
            }
        } else {
            let webURL = URL(string:"http://www.youtube.com/watch?v=\(id)")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                return true
            } else {
                UIApplication.shared.openURL(appURL)
                return true
            }
        }
    }
    
    static func facebook (id:String) -> Bool {
        guard let appURL = URL(string:"youtube://\(id)") else {
            return false
        }
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                return true
            } else {
                UIApplication.shared.openURL(appURL)
                return true
            }
        } else {
            let webURL = URL(string:"http://www.youtube.com/watch?v=\(id)")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                return true
            } else {
                UIApplication.shared.openURL(appURL)
                return true
            }
        }
    }
    
}
