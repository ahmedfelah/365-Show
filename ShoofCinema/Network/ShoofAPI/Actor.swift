//
//  Actor.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Actor : Decodable {
        let id: Int
        let name: String
        let imageURL: URL?
        
        init(id: Int, name: String, imageURL: URL?) {
            self.id = id
            self.name = name
            self.imageURL = imageURL
        }
        
        private enum CodingKeys: String, CodingKey {
            case id, name
            case imageURL = "photoLink"
        }
    }
}
