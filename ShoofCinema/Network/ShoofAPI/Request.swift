//
//  Request.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/3/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Request : Decodable {
        let id: String
        let title: String
        let details: String?
        let creationDate: String
//        let fileURL: URL?
        let userID: String
        let reply: String?
        let userName: String?
        let userImage: URL?
//        let status: Status
        
        enum Status : Int, Decodable {
            case open = 1
            case closed = 2
            case fileNotFound = 3
        }
        
        private enum CodingKeys: String, CodingKey {
            case id, title, details, reply, userName, userImage
            case creationDate = "createDate"
//            case fileURL = "fileLink"
            case userID = "userId"
//            case status = "requestStatus"
        }
    }
}
