//
//  Codable+UserDefaults.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/22/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension UserDefaults {
    func setEncodable<Object>(_ object: Object?, forKey key: String) where Object : Encodable {
        if let object = object {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(object)
            set(data, forKey: key)
        } else {
            removeObject(forKey: key)
        }
    }
    
    func decodable<Object>(forKey key: String) throws -> Object? where Object : Decodable {
        if let data = data(forKey: key) {
            let decoder = JSONDecoder()
            return try decoder.decode(Object.self, from: data)
        }
        
        return nil
    }
}
