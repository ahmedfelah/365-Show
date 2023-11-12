//
//  SuggesteShow.swift
//  ShoofCinema
//
//  Created by mac on 3/4/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation



extension ShoofAPI {
    struct SuggestShow : Codable {
        let id: String
        let title: String
        let showId: String
        let isDeleted: Bool
        
        
        private enum CodingKeys: String, CodingKey {
            case id, title, showId, isDeleted
        }
    }
}
