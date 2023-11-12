//
//  Media.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    enum Media : Decodable {
        case movie(Movie), series(seasons: [Season])
        
        private enum CodingKeys: String, CodingKey {
            case isMovie, seasons
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if try container.decode(Bool.self, forKey: .isMovie) {
                let movie = try Movie(from: decoder)
                self = .movie(movie)
            } else {
                let seasons = try container.decode([Season].self, forKey: .seasons)
                self = .series(seasons: seasons)
            }
        }
        
        enum Resolution : Decodable {
            case hd720
            case hd1080
            case sd480
            case sd360
            case sd240
            case other(String)
            
            var description: String {
                switch self {
                case .hd720: return "720"
                case .hd1080: return "1080"
                case .sd480: return "480"
                case .sd360: return "360"
                case .sd240: return "240"
                case .other(let resolution): return resolution
                }
            }
            
            init(resolution: Int) {
                switch resolution {
                case 240: self = .sd240
                case 360: self = .sd360
                case 480: self = .sd480
                case 720: self = .hd720
                case 1080: self = .hd1080
                default: self = .other(String(resolution))
                }
            }
            
            init(resolution: String) {
                if let resolution = Int(resolution) {
                    self.init(resolution: resolution)
                } else {
                    self = .other(resolution)
                }
            }
            
            private enum CodingKeys : String, CodingKey {
                case resolution
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let resolution = try container.decode(Int.self, forKey: .resolution)
                self.init(resolution: resolution)
            }
        }
        
        struct Subtitle: Decodable {
            let type: Int
            let path: URL
        }
        
        struct Timeline : Decodable {
            let id: String
            let startTime: Double
            let endTime: Double
        }
        
        struct Movie : Decodable {
            let files: [File]
            let subtitles: [Subtitle]?
            let skips: [Timeline]
            let familyModTimelines: [Timeline]
        }
        
        struct Episode : Decodable {
            let id: String
            let number: Int
            let files: [File]
            let subtitles: [Subtitle]?
            let skips: [Timeline]
            let familyModTimelines: [Timeline]
            
            private enum CodingKeys : String, CodingKey {
                case id, subtitles, skips, familyModTimelines
                case number = "episodeNumber"
                case files = "episodeFiles"
            }
        }
        
        struct Season : Decodable {
            let id: String
            let number: Int
            let description: String?
            let episodes: [Episode]?
            let numberOfEpisodes: Int
            
            private enum CodingKeys : String, CodingKey {
                case id, description, episodes
                case numberOfEpisodes = "episodesCount"
                case number = "seasonNumber"
            }
        }
        
        struct File {
            let id: String
            let url: URL? // MARK: - SHOULD NEVER BE NIL. API error must be fixed...
            let resolution: Resolution
        }
    }
}

extension ShoofAPI.Media.Episode : Equatable {
    static func == (lhs: ShoofAPI.Media.Episode, rhs: ShoofAPI.Media.Episode) -> Bool {
        lhs.id == rhs.id
    }
}

extension ShoofAPI.Media.File : Decodable {
    private enum CodingKeys : String, CodingKey {
        case id
        case url = "path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
        self.resolution = try ShoofAPI.Media.Resolution(from: decoder)
    }
}
