//
//  Firebase Events.swift
//  Shoof
//
//  Created by Husam Aamer on 9/23/17.
//  Copyright © 2017 HA. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAnalytics
//import firebase

/*
 For user segmentation
 
 Each key must be less than 40 characters in length, and the key can contain only letters, numbers, whitespace, hyphens (-), or underscores (_).
 
 */
enum FIRProperties:String {
    case isVoiceOver           = "isVoiceOver"
    case isNotificationEnabled = "isNotificationEnabled"
    case hasApp_pinco          = "hasApp_pinco"
    case hasAppleTV            = "hasAppleTV"
    case hasChromecast         = "hasChromecast"
    case numberOfDownloads     = "numberOfDownloads"
}

func FIRSet(userProperty property:String?,name:FIRProperties) {
        
    
    Analytics.setUserProperty(property, forName: "favorite_food")
    
}
