//
//  RmShow.swift
//  Giganet
//
//  Created by Husam Aamer on 5/6/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RGenre : Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    
    override init() {
        super.init()
    }
    
    init(name: String, id: Int) {
        super.init()
        
        self.name = name
        self.id = id
    }
}

class RCategory : Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    
    override init() {
        super.init()
    }
    
    init(name: String?, id: Int) {
        super.init()
        
        self.name = name
        self.id = id
    }
}

class RActor : Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @Persisted var imageURL: String?
    
    override init() {
        super.init()
    }
    
    init(name: String, id: Int, imageURL: String?) {
        super.init()
        
        self.name = name
        self.id = id
        self.imageURL = imageURL
    }
    
}

class RShow : Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var story: String? // ShoofAPI.Show.description
    @Persisted var year: String
    @Persisted var isMovie: Bool = true
    @Persisted var numberOfViews: Int
    
    @Persisted var runtime: TimeInterval = 0
    
    @Persisted var genres: List<String>
    @Persisted var rating: String?
    @Persisted var coverURL: String?
    @Persisted var posterURL: String?
    @Persisted var languages: String?
    @Persisted var imdbID: String?
    @Persisted var youtubeID: String?
    @Persisted var category: String?
	
    @Persisted var creationDate = Date()
    
    func asShoofShow() -> ShoofAPI.Show {
        let shoofGenres: [ShoofAPI.Genre] = genres.map { ShoofAPI.Genre(id: 0, name: $0) }
        let shoofCategory = category != nil ? ShoofAPI.Category(id: 0, name: category!) : nil
        let posterURL = posterURL.flatMap(URL.init)
        let coverURL = coverURL.flatMap(URL.init)
        
        return ShoofAPI.Show(id: id, title: title, rating: rating, year: year, isMovie: isMovie, description: story, genres: shoofGenres, coverURL: coverURL, posterURL: posterURL, smallPosterURL: nil, trailerURL: nil, numberOfViews: numberOfViews, isInWatchLater: false, isSubscribed: false, titleImageURL: nil, alternativeTitle: nil, langauges: languages, imdbID: imdbID, media: nil, youtubeID: youtubeID, category: shoofCategory, actors: [], relatedShows: nil, comments: nil, writers: nil, directors: nil, ageRating: nil)
    }
    
    override init() {
        super.init()
    }
    
    init(from rmShow: RmShow) {
        super.init()
        
        self.id = String(rmShow.id)
        self.title = rmShow.title
        self.story = rmShow.story
        if let year = rmShow.year.value {
            self.year = String(year)
        }
        self.isMovie = !rmShow.isSeries
        self.numberOfViews = rmShow.views
        if let rating = rmShow.rating.value {
            self.rating = String(rating)
        }
        self.imdbID = rmShow.imdb_id
        self.posterURL = rmShow.poster
        self.category = rmShow.categoryStr
        self.genres.append(objectsIn: rmShow.genres)
    }
    
    init(from show: ShoofAPI.Show) {
        super.init()
        
        self.id = show.id
        self.title = show.title
        self.story = show.description
        self.year = show.year
        self.isMovie = show.isMovie
        self.numberOfViews = show.numberOfViews
        self.rating = show.rating
        self.languages = show.langauges
        self.imdbID = show.imdbID
        self.youtubeID = show.youtubeID
        self.posterURL = show.posterURL?.absoluteString
        self.coverURL = show.coverURL?.absoluteString
        
        if let shoofCategory = show.category {
            self.category = shoofCategory.name
        }
        
        if let genres = show.genres?.map(\.name) {
            self.genres.append(objectsIn: genres)
        }
    }
}

class RmShow:Object {
    
    @objc dynamic var id:Int = 0
    @objc dynamic var title:String = ""
    @objc dynamic var story:String = ""
    @objc dynamic var poster:String = ""
    @objc dynamic var slider:String = ""
    var year = RealmProperty<Int?>()
    var rating = RealmProperty<Float?>()
    
    @objc dynamic var trailer : String?
    
    dynamic var stars = List<String>()
    dynamic var directors = List<String>()
    dynamic var writers = List<String>()
    dynamic var genres = List<String>()
    
    @objc dynamic var imdb_id:String?
    @objc dynamic var movie_token:String = ""
    
    @objc dynamic var views:Int = 0
    @objc dynamic var isSeries:Bool = false
    @objc dynamic var categoryStr:String = ""
    @objc dynamic var runtime:Int = 0
    
    @objc dynamic var creation_date = Date()
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    override init() {
        super.init()
    }
    init(with show:Show) {
        super.init()
        
        id = show.id
        title = show.title
        story = show.story ?? ""
        poster = show.poster ?? ""
        slider = show.slider?.absoluteString ?? ""
        year.value = show.year
        trailer = show.trailer
        imdb_id = show.imdb_id
        movie_token = show.token
        rating.value = show.rating
        views = show.views
        isSeries = show.isSeries
        categoryStr = show.categoryStr
        runtime = show.runtime
        
        if let _stars = show.stars {
            stars.append(objectsIn: _stars)
        }
        
        if let _writers = show.writers {
            writers.append(objectsIn: _writers)
        }
        
        if let _directors = show.directors {
            directors.append(objectsIn: _directors)
        }
        
        if let _genres = show.genres {
            genres.append(objectsIn: _genres)
        }
    }
    
    var asDictionary:[String:Any?] {
        return [
            "movie_id":id,
            "movie_token":movie_token,
            "movie_title":title,
            "movie_des":story,
            "movie_poster":poster,
            "movie_slider":slider,
            "movie_year":year,
            "movie_rate":"\(rating.value ?? 0)",
            "movie_trailer":trailer,
            "movie_runtime":runtime,
            "movie_imdb_id":imdb_id,
            "movie_watched":views,
            #keyPath(isSeries):isSeries,
            "category" : [
                "category_name" : categoryStr
            ],
            "movie_stars":Array(stars),
            "movie_directors":Array(directors),
            "movie_writers":Array(writers),
            "movie_genres":Array(genres),
        ]
    }
}
