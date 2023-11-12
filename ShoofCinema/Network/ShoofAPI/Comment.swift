//
//  Comment.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Comment : Codable {
        let id: String
        let userID: String
        let userName: String?
        let userProfileURL: URL?
        let message: String
        let date: String
        
        private enum CodingKeys: String, CodingKey {
            case id, userName
            case userID = "userId"
            case userProfileURL = "userPhotoUrl"
            case message = "text"
            case date = "createDate"
        }
    }
}
