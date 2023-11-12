//
//  FirebaseRemoteConfig.swift
//  BOC
//
//  Created by Husam Aamer on 10/3/17.
//  Copyright © 2017 HA. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

////Fabric Answers log
func FABLog(event name:String) {
    Crashlytics.crashlytics().log(format:"%@", arguments: getVaList([name]))
}
