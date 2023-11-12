//
//  Action.swift
//  ShoofCinema
//
//  Created by mac on 2/12/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


extension ShoofAPI {
    struct Action {
        let id: String?
        let genreId: Int?
        let categoryId: Int?
        let tagId: Int?
        let rate: Int?
        let year: Int?
        let isMovie: ShoofAPI.Filter.MediaType?
        let sortType: SortType?
        
    }
}

extension ShoofAPI.Action: Decodable {
    private enum CodingKeys : String, CodingKey {
        case id, genreId, categoryId, tagId, rate, year, isMovie, sortType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.genreId = try? container.decode(Int.self, forKey: .genreId)
        self.categoryId = try? container.decode(Int.self, forKey: .categoryId)
        self.tagId = try? container.decode(Int.self, forKey: .tagId)
        self.rate = try? container.decode(Int.self, forKey: .rate)
        self.year = try? container.decode(Int.self, forKey: .year)
        self.isMovie = try? container.decode(ShoofAPI.Filter.MediaType.self, forKey: .isMovie)
        self.sortType = try? container.decode(SortType.self, forKey: .sortType)
    }
}


