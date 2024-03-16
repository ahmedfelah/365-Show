//
//  Filter.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Filter {
        var genreID: Int?
        let categoryID: Int?
        let tagID: Int?
        let rate: String?
        var year: String?
        var mediaType: MediaType
        var sortType: SortType?
        
        static func convertToString(from: Any?) -> String? {
            if let from = from {
                return "\(from)"
            }
            return nil
        }
        
        static let none = ShoofAPI.Filter(genreID: nil, categoryID: nil, tagID: nil, rate: nil, year: nil, mediaType: .all, sortType: nil)
    }
}

extension ShoofAPI.Filter : Codable {
    enum MediaType : Int, Identifiable, Codable, CaseIterable {
        case movies, series, all
        
        var id: String {
            title
        }
        
        var title: String {
            switch self {
            case .all:
                return "all"
            case .movies:
                return "movies"
            case .series:
                return "series"
            }
        }
        
        private enum CodingKeys : String, CodingKey {
            case isMovie
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let isMovie = try container.decodeIfPresent(Bool.self, forKey: .isMovie) {
                self = isMovie ? .movies : .series
            } else {
                self = .all
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .movies: try container.encode(true, forKey: .isMovie)
            case .series: try container.encode(false, forKey: .isMovie)
            case .all: break
            }
        }
    }
    
    private enum CodingKeys : String, CodingKey {
        case rate, year, sortType
        case genreID = "genreId"
        case categoryID = "categoryId"
        case tagID = "tagId"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.genreID = try container.decodeIfPresent(Int.self, forKey: .genreID)
        self.categoryID = try container.decodeIfPresent(Int.self, forKey: .categoryID)
        self.tagID = try container.decodeIfPresent(Int.self, forKey: .tagID)
        self.rate = try container.decodeIfPresent(String.self, forKey: .rate)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year).map(String.init)
        self.mediaType = try MediaType(from: decoder)
        self.sortType = try container.decodeIfPresent(SortType.self, forKey: .sortType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(genreID, forKey: .genreID)
        try container.encodeIfPresent(categoryID, forKey: .categoryID)
        try container.encodeIfPresent(tagID, forKey: .tagID)
        try container.encodeIfPresent(rate, forKey: .rate)
        try container.encodeIfPresent(year, forKey: .year)
        try mediaType.encode(to: encoder)
        try container.encodeIfPresent(sortType, forKey: .sortType)
        
    }
}
