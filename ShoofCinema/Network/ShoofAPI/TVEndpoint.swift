//
//  TVEndpoint.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/2/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation
import TBKNetworking

extension ShoofAPI {
    struct TVSection : Decodable {
        let name: String
        let channels: [Channel]
    }
    
    struct Channel : Decodable {
        let name: String
        let imageURL: URL?
        let streamURL: URL
        
        private enum CodingKeys : String, CodingKey {
            case name
            case imagePath = "image"
            case streamURL = "link"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            if let imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath) {
                if imagePath.hasPrefix("http") {
                    self.imageURL = URL(string: imagePath)!
                } else {
                    self.imageURL = URL(string: "https://tv.shoofnetwork.net/" + (imagePath.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""))
                }
            } else {
                self.imageURL = nil
            }
            
            self.streamURL = try container.decode(URL.self, forKey: .streamURL)
        }
    }
    
    struct TVEndpoint : TBKNetworking.Endpoint {
        let host: String = "tv.shoofnetwork.net"
        let path: String = "/api"
        
        struct Response : Decodable {
            let sections: [TVSection]
        }
    }
}

extension ShoofAPI.Channel {
    func asPlayerSource () -> CPlayerSource? {
//        let url = streamURL
//        var resolutions = [CPlayerResolutionSource]()
//        resolutions.append(CPlayerResolutionSource(title:"Auto",url))
        let metadata = CPlayerMetadata(title: name, image: imageURL, description: nil)
        let resolutions = CPlayerResolutionSource(title: "Auto", streamURL)
        return CPlayerSource(resolutions: [resolutions], metadata: metadata)
    }
}


extension Endpoint where Self == ShoofAPI.TVEndpoint {
    static var sections: Self {
        ShoofAPI.TVEndpoint()
    }
}
