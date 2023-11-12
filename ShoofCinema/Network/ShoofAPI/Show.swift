//
//  Show.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Show {
        let id: String
        let title: String
        let rating: String?
        let year: String
        let isMovie: Bool
        let description: String?
        let genres: [Genre]?
        let coverURL: URL?
        let posterURL: URL?
        let smallPosterURL: URL?
        let trailerURL: URL?
        let numberOfViews: Int
        var isInWatchLater: Bool
        var isSubscribed: Bool
        let titleImageURL: URL?
        
        // Details (loaded on demand)
        
        let alternativeTitle: String?
        let langauges: String?
        let imdbID: String?
        var media: Media?
        let youtubeID: String?
        let category: Category?
        let actors: [Actor]?
        let relatedShows: [Show]?
        let comments: [Comment]?
        var writers: [String]?
        var directors: [String]?
        let ageRating: String?
    }
}

extension ShoofAPI.Show : Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, title, year, description, genres, isMovie, isInWatchLater, isSubscribed
        case rating = "rate"
        case coverURL = "coverPhotoUrl"
        case posterURL = "photoUrl"
        case trailerURL = "trailerLink"
        case smallPosterURL = "smallPhotoUrl"
        case numberOfViews = "views"
        case titleImageURL = "featuredLogo"
        
        case alternativeTitle, languages, files, seasons, subtitles, category, actors, relatedShows, familyModTimelines, skips, comments, writers, directors, ageRating
        case imdbID = "imDbId"
        case youtubeID = "youTubeId"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.rating = try? container.decode(String.self, forKey: .rating)
        self.year = try container.decode(String.self, forKey: .year)
        self.isMovie = try container.decode(Bool.self, forKey: .isMovie)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.genres = try container.decodeIfPresent([ShoofAPI.Genre].self, forKey: .genres)
        self.coverURL = try? container.decode(URL.self, forKey: .coverURL)
        self.posterURL = try? container.decode(URL.self, forKey: .posterURL)
        self.smallPosterURL = try? container.decode(URL.self, forKey: .smallPosterURL)
        self.trailerURL = try? container.decodeIfPresent(URL.self, forKey: .trailerURL)
        self.numberOfViews = try container.decode(Int.self, forKey: .numberOfViews)
        self.isInWatchLater = try container.decode(Bool.self, forKey: .isInWatchLater)
        self.isSubscribed = try container.decode(Bool.self, forKey: .isSubscribed)
        if let titleImageURLString = try container.decodeIfPresent(String.self, forKey: .titleImageURL), let encodedString = titleImageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.titleImageURL = URL(string: encodedString)
        } else {
            self.titleImageURL = nil
        }
        // DETAILS
        
        self.alternativeTitle = try container.decodeIfPresent(String.self, forKey: .alternativeTitle)
        self.langauges = try container.decodeIfPresent(String.self, forKey: .languages)
        self.imdbID = try container.decodeIfPresent(String.self, forKey: .imdbID)
        
        self.media = try? ShoofAPI.Media(from: decoder)
        
        self.youtubeID = try container.decodeIfPresent(String.self, forKey: .youtubeID)
        self.category = try container.decodeIfPresent(ShoofAPI.Category.self, forKey: .category)
        self.actors = try container.decodeIfPresent([ShoofAPI.Actor].self, forKey: .actors)
        self.relatedShows = try container.decodeIfPresent([ShoofAPI.Show].self, forKey: .relatedShows)
        self.comments = try container.decodeIfPresent([ShoofAPI.Comment].self, forKey: .comments)?.sorted(by: { $0.date < $1.date })
        self.writers = try container.decodeIfPresent([String].self, forKey: .writers)
        self.directors = try container.decodeIfPresent([String].self, forKey: .directors)
        self.ageRating = try container.decodeIfPresent(String.self, forKey: .ageRating)
    }
}

extension ShoofAPI.Show {
    var formattedGenres: String {
        if let genres = genres, !genres.isEmpty {
            return genres.map(\.name).joined(separator: ", ")
        } else {
            return NSLocalizedString("noGenre", comment: "")
        }
    }
}
