//
//  ShowDataCM.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/5/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation


// MARK: - Datum
struct ShowDataCM: Codable {
    
    private let movie_id: Int
    private let movie_slider: String
    private let movie_alt_title, movie_title, movie_des: String
    private let movie_trailer_file: String
    private let movie_poster: String
    private let movie_iscam, movie_year: Int
    private let movie_runtime: String?
    private let movie_rate: String
    private let movie_stars: [String]?
    private let movie_trailer: String
    private let movie_directors, movie_writers: [String]?
    private let movie_imdb_id: String?
    private let movie_watched: Int
    private let movie_token, movie_added_date: String
    private let movie_poster_1, movie_poster_2, movie_poster_3, movie_poster_4: String
    private let isSeries, isFav: Int
    private let movie_genres: [String]?
    private let user: UserCM
    private let mpaa: MPAACM
    private let category: CategoryCM
    private let category_parents: String?

    
    public var title : String {
        return Language.isEnglish() ? self.movie_title.capitalized : self.movie_alt_title
    }
    
    public var slider : URL? {
        return URL(string: "\(self.movie_slider)")
    }
    
    public var poster : URL? {
        return URL(string: "\(self.movie_poster)")
    }
    
    public var views : String {
        return "\(self.movie_watched.getFormattedViewsNumber())"
    }

    public var imbdRating : String {
        return "\(self.movie_rate.getFormattedIMDBRating())"
    }

    public var year : String {
        return "\(self.movie_year)"
    }
    
    public var genres : String {
        if let g = self.movie_genres {
            return g.joined(separator: ", ")
        } else {
            return NSLocalizedString("noGenres", comment: "")
        }
    }
    
    public var mapaaRaging : String {
        if self.mpaa.mpaa_name == "Not Rated" {
            return "N/A"
        } else {
            return self.mpaa.mpaa_name.uppercased()
        }
    }

}

