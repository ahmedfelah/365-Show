//
//  PreferencesManager.swift
//  Repo
//
//  Created by Husam Aamer on 8/3/17.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

import Foundation
import Security

class PrefManager {
    static var defaults = UserDefaults.standard
    class  func save (value: Any?,forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    class  func loadValue(forKey key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    class  func loadStruct<T:Decodable>(ofType type:T.Type ,forKey key: String) -> Decodable? {
        if let data = defaults.object(forKey: key) as? Data {
            return try? JSONDecoder().decode(type.self, from: data)
        }
        return nil
    }
    class  func loadInt(forKey key: String) -> Int? {
        return defaults.integer(forKey: key)
    }
    
    
    class  func save(secureValue value: String?,forKey key: String) {
        let dict = dictForKey(key: key)
        if let v = value {
            var _: Data = v.data(using: .utf8, allowLossyConversion: false)!
            (SecItemDelete(dict as NSDictionary as CFDictionary))
            dict[kSecValueData as NSString] = v.data(using: .utf8, allowLossyConversion:false);
            _ = SecItemAdd(dict as NSDictionary as CFDictionary, nil)
        } else {
            _ = SecItemDelete(dict as NSDictionary as CFDictionary)
        }
    }
    
    class  func loadSecureValue(forKey key: String) -> String? {
        let dict = dictForKey(key: key)
        dict[kSecReturnData as NSString] = kCFBooleanTrue
        var result: AnyObject?
        var value: NSString? = nil
        let status = SecItemCopyMatching(dict as NSDictionary as CFDictionary, &result)
        if status == noErr, let data = result as? Data {
            value = NSString(data: data,encoding: String.Encoding.utf8.rawValue)
        
        }
        
        let val :String? =  value as String?
        return val
    }
    
    class private func dictForKey(key: String) -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict[kSecClass as NSString] = kSecClassGenericPassword as NSString
        dict[kSecAttrService as NSString] = key
        return dict
    }
    
}
