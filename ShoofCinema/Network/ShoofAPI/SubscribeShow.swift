//
//  SubscribeShow.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/24/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct SubscribeShow : Decodable {
        let id: String
        let showID: String
        let userID: String
//        let topic: String
        var topic: String {
            "Series_\(showID)"
        }
        
        let show: ShoofAPI.Show?
        
        private enum CodingKeys: String, CodingKey {
            case id, show
            case userID = "userId"
            case showID = "showId"
        }
    }
}
