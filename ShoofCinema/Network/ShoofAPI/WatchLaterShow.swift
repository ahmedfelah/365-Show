//
//  WatchLaterShow.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct WatchLaterShow : Decodable {
        let id: String
        let showID: String
        let userID: String
        let show: ShoofAPI.Show?
        
        private enum CodingKeys: String, CodingKey {
            case id, show
            case userID = "userId"
            case showID = "showId"
        }
    }
}
