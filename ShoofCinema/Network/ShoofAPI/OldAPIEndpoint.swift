//
//  OldAPIEndpoint.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 4/5/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation
import TBKNetworking

extension ShoofAPI {
    struct OldAPIEndpoint<Response : Decodable> : TBKNetworking.Endpoint {
        let host: String = "check.365ar.show"
        let path: String
        let scheme: Scheme = .https
    }
    
    struct NetworkStatusResponse : Decodable {
        let inNetwork: Bool
        let apiUrl: String
        
        private enum CodingKeys : String, CodingKey {
            case inside
            case apiUrl = "api_url"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.inNetwork = try container.decode(Int.self, forKey: .inside) == 1
            self.apiUrl = try container.decode(String.self, forKey: .apiUrl)
        }
    }
}

extension Endpoint where Self == ShoofAPI.OldAPIEndpoint<ShoofAPI.NetworkStatusResponse> {
    static var networkStatus: Self {
        Self(path: "/api/MobileV3/Global/network")
    }
}
