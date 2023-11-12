//
//  Explore.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Explore : Decodable {
        let id: String
        let filter: Filter
        let imageURL: URL
        
        private enum CodingKeys: String, CodingKey {
            case id, filter
            case imageURL = "img"
        }
    }
}
