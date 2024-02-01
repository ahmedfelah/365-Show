//
//  Reel.swift
//  365Show
//
//  Created by ممم on 18/11/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


extension ShoofAPI {
    struct Reel : Codable {
        let id: String
        let videoUrl: String
        let fakeVideoUrl = "http://imdb-video.media-imdb.com/vi1225109529/1421100405014-mxwp62-1434643350557.m3u8"
        let showId: String
        let showTitle: String
        let showPhoto: String
        let views: Int
        let order: Int
        
        private enum CodingKeys: String, CodingKey {
            case id, videoUrl, showId, showTitle, showPhoto, views, order
        }
    }
}
