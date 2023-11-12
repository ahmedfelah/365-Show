//
//  FirebaseRemoteConfig.swift
//  BOC
//
//  Created by Husam Aamer on 10/3/17.
//  Copyright © 2017 HA. All rights reserved.
//

import UIKit
import Firebase
import FirebaseRemoteConfig

enum FIRParams:String {
    case appstore_build = "appstore_build"
    case last_update_features = "last_update_features"
    
    static func value(key:FIRParams) -> RemoteConfigValue {
        return RemoteConfig.remoteConfig().configValue(forKey: key.rawValue)
    }
}
