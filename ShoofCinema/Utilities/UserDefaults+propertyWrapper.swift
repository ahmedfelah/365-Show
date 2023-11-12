//
//  UserDefaults+propertyWrapper.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 4/5/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    let container: UserDefaults

    init(wrappedValue defaultValue: Value, _ key: String, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
