//
//  PreferencesManager.swift
//  Repo
//
//  Created by Husam Aamer on 8/3/17.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

import Foundation

extension RPref {
    enum Keys {
        static let DebugModeActivated = "DebugModeActivated"
        static let user_info = "user_info"
        static let token = "token"
        static let fcmToken = "fcmToken"
        static let walkthroghSeen = "walkthroghSeen"
        static let showReview = "showReview"
        static let openCount = "openCount"
        
    }
}
struct RPref  {

    static var DebugModeActivated :Bool  {
        set {
            PrefManager.save(value:newValue, forKey: Keys.DebugModeActivated)
        }
        get {
            return PrefManager.loadValue(forKey:Keys.DebugModeActivated) as? Bool ?? false
        }
    }
    static var account_info :AccountInfo?  {
        set {PrefManager.save(value:try? JSONEncoder().encode(newValue), forKey: Keys.user_info)}
        get {return PrefManager.loadStruct(ofType: AccountInfo.self, forKey: Keys.user_info) as? AccountInfo}
    }
    static var token :String?  {
        set {PrefManager.save(value:newValue, forKey: Keys.token)}
        get {return PrefManager.loadValue(forKey: Keys.token) as? String}
    }
    static var fcmToken :String?  {
        set {PrefManager.save(value:newValue, forKey: Keys.fcmToken)}
        get {return PrefManager.loadValue(forKey: Keys.fcmToken) as? String}
    }
    
    static var walkthroghSeen :Bool  {
        set {
            PrefManager.save(value:newValue, forKey: Keys.walkthroghSeen)
        }
        get {
            return PrefManager.loadValue(forKey:Keys.walkthroghSeen) as? Bool ?? false
        }
    }
    
    static var showReview :Bool  {
        set {
            PrefManager.save(value:newValue, forKey: Keys.showReview)
        }
        get {
            return PrefManager.loadValue(forKey:Keys.showReview) as? Bool ?? false
        }
    }
    
    static var openCount :Int  {
        set {
            PrefManager.save(value:newValue, forKey: Keys.openCount)
        }
        get {
            return PrefManager.loadValue(forKey:Keys.openCount) as? Int ?? 0
        }
    }
    
}
