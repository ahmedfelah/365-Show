//
//  Autocomplete.swift
//  ShoofCinema
//
//  Created by mac on 3/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


extension ShoofAPI {
    struct Autocomplete : Codable {
        let id: String
        let title: String
        let showId: String?
        
        
        private enum CodingKeys: String, CodingKey {
            case id, title, showId
        }
    }
}
