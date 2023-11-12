//
//  Notification.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/25/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Notification : Decodable {
        let creationDate: Date?
        let aps: Aps?
        let imageURL: URL?
        let targetID: String?
        @LossyCodableProperty var type: `Type`?
        
//        let id: String
//        let isGlobal: Bool
//        let userID: String
//        let isDeleted: Bool
        
        private enum CodingKeys : String, CodingKey {
            case creationDate, type, aps
            case imageURL = "photoLink"
            case targetID = "id"
//            case id, isDeleted
//            case isGlobal = "global"
//            case userID = "userId"
        }
        
        enum `Type`: String, Codable {
            case episode = "1"
            case request = "2"
            case show = "3"
            case note = "4"
        }
    }
    
}

extension ShoofAPI.Notification {
    struct Aps: Decodable {
        let alert: Alert?
        
        private enum CodingKeys : String, CodingKey {
            case alert
        }

    }
}

extension ShoofAPI.Notification.Aps {
    struct Alert: Decodable {
        let title: String?
        let body: String?
        
        private enum CodingKeys : String, CodingKey {
            case title, body
        }
    }
}


