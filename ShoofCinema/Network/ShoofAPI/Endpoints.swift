//
//  Endpoints.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 12/10/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation
import TBKNetworking

// MARK: - Home
extension ShoofAPI.Endpoint where ResponseBody == [ShoofAPI.Section] {
    enum Target : Int {
        case home = 1
        case movies = 2
        case shows = 3
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Section]> {
    static func homeSections(numberOfShowsPerSection: Int, pageNumber: Int = 1) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Home/GetHomeSections") {
            URLQueryItem(name: "showsPerSection", value: "\(numberOfShowsPerSection)")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
    
    static func sections(withTarget target: Self.Target, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Sections/GetAll") {
            URLQueryItem(name: "showsPerSection", value: "10")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
            URLQueryItem(name: "target", value: "\(target.rawValue)")
        }
    }
}

// MARK: - Load Reels
extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Reel]> {
    static func reels(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Clips/GetClips") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

// MARK: - Load More Shows
extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Show]> {
    static func shows(forSectionWithID sectionID: String, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Sections/GetSectionsSection") {
            URLQueryItem(name: "id", value: sectionID)
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
    
    static func shows(forActorWithID actorID: Int, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetActorShows") {
            URLQueryItem(name: "actorId", value: "\(actorID)")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
    
    static func shows(matching keywords: String, genreID: Int?, rate: Int?, fromDate: String?, toDate: String?, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/SearchShows") {
            URLQueryItem(name: "showName", value: keywords)
            if let genreID = genreID {
                URLQueryItem(name: "genreId", value: "\(genreID)")
            }
            
            if let fromDate = fromDate {
                URLQueryItem(name: "from", value: "\(fromDate)")
            }
            
            if let tomDate = toDate {
                URLQueryItem(name: "to", value: "\(toDate)")
            }
            
            if let rate = rate {
                URLQueryItem(name: "rate", value: "\(rate)")
            }
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
    
    static func shows(withFilter filter: ShoofAPI.Filter, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetShows") {
            if let genreID = filter.genreID {
                URLQueryItem(name: "genreId", value: "\(genreID)")
            }
            
            if let categoryID = filter.categoryID {
                URLQueryItem(name: "categoryId", value: "\(categoryID)")
            }
            if let tagID = filter.tagID {
                URLQueryItem(name: "tagId", value: "\(tagID)")
            }
            if let rate = filter.rate {
                URLQueryItem(name: "rate", value: "\(rate)")
            }
            if let year = filter.year {
                URLQueryItem(name: "year", value: "\(year)")
            }
            if filter.mediaType == .movies {
                URLQueryItem(name: "isMovie", value: "true")
            } else if filter.mediaType == .series {
                URLQueryItem(name: "isMovie", value: "false")
            }
            if let sortType = filter.sortType {
                URLQueryItem(name: "sortType", value: "\(sortType.rawValue)")
            }
            
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

// MARK: - Load Show Details
extension Endpoint where Self == ShoofAPI.Endpoint<ShoofAPI.Show> {
    static func show(withID showID: String) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetShow") {
            URLQueryItem(name: "id", value: showID)
        }
    }
    
    static func movie(withID showID: String) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetShow") {
            URLQueryItem(name: "id", value: showID)
        }
    }
    
    static func series(withID showID: String) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Series/GetSeries") {
            URLQueryItem(name: "id", value: showID)
        }
    }
    
    static var testShow: Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetShow") {
            URLQueryItem(name: "id", value: "013a6b06-3948-40dd-8d9b-5723abe6e5fe")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Genre]> {
    static var genres: Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Genre/GetGenres")
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]> {
    static func episodes(forSeasonWithID seasonID: String, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Series/GetEpisodes") {
            URLQueryItem(name: "sessionId", value: seasonID)
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Explore]> {
    static func explores(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Explore/GetExplores") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<ShoofAPI.WatchLaterShow> {
    static func addShowToWatchLater(showID: String) -> Self {
        ShoofAPI.Endpoint(method: .post(data: .empty), path: "/api/MobileV3/WatchLater/Add/showId") {
            URLQueryItem(name: "showId", value: showID)
        }
    }
    
    static func removeShowFromWatchLater(showID: String) -> Self {
        ShoofAPI.Endpoint(method: .delete, path: "/api/MobileV3/WatchLater/DeleteShow/ByShow/\(showID)")
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<ShoofAPI.SubscribeShow> {
    static func subscribe(toShowWithID showID: String) -> Self {
        ShoofAPI.Endpoint(method: .post(data: .empty), path: "/api/MobileV3/Subscribe/Add/showId") {
            URLQueryItem(name: "showId", value: showID)
        }
    }
}

extension Endpoint where Self == ShoofAPI.NoValueEndpoint {
    static func unsubscrible(fromShowWithID showID: String) -> Self {
        ShoofAPI.NoValueEndpoint(method: .delete, path: "/api/Mobilev3/Subscribe/\(showID)")
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.WatchLaterShow]> {
    static func watchLaterShows(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/WatchLater/GetAll") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension ShoofAPI.Endpoint {
    struct AddComment : Codable {
        let showID: String
        let message: String
        
        private enum CodingKeys : String, CodingKey {
            case showID = "showId"
            case message = "text"
        }
    }
    
    struct AddRequest : Codable {
        let title: String
        let details: String
    }
    
    init<Form : Encodable>(form: Form, path: String) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(form)
        self.init(method: .post(data: data), path: path)
    }
}

extension ShoofAPI.ResellerEndpoint {
    struct SasUserInfo: Codable {
        let token: String?
        let deviceType: Int
        let baseUrl: String
    }
    
    init<Form : Encodable>(form: Form, path: String) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(form)
        self.init(method: .post(data: data), path: path)
    }
}



extension Endpoint where Self == ShoofAPI.Endpoint<ShoofAPI.Comment> {
    static func addComment(_ commentMessage: String, showID: String) -> Self {
        let form = Self.AddComment(showID: showID, message: commentMessage)
        return ShoofAPI.Endpoint(form: form, path: "/api/MobileV3/Comments/AddComment")
    }
    
    static func getComments(showId: String, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Request/GetUserRequests") {
            URLQueryItem(name: "showId", value: "\(showId)")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Comment]> {
    static func getComments(showId: String, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Comments/Get") {
            URLQueryItem(name: "showId", value: "\(showId)")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Request]> {
    static func userRequests(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Request/GetUserRequests") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
    
    static func allRequests(withStatus requestStatus: ShoofAPI.Request.Status, pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Request/GetAllRequests") {
            URLQueryItem(name: "status", value: "\(requestStatus.rawValue)")
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Autocomplete]> {
    static func autocomplete(showName: String) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/SearchAutoComplete") {
            URLQueryItem(name: "showName", value: "\(showName)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Autocomplete]> {
    static func suggestedShows(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Show/GetSuggestedShows") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}

extension Endpoint where Self == ShoofAPI.NoValueEndpoint {
    static func increaseSearchCount(showId: String) -> Self {
        ShoofAPI.NoValueEndpoint(method: .put(data: .empty), path: "/api/MobileV3/Show/IncreaseSearchCount/\(showId)")
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<ShoofAPI.Request> {
    static func addRequest(withTitle title: String, details: String) -> Self {
        let form = Self.AddRequest(title: title, details: details)
        return ShoofAPI.Endpoint(form: form, path: "/api/MobileV3/Request/AddRequest")
    }
}

extension Endpoint where Self == ShoofAPI.Endpoint<[ShoofAPI.Notification]> {
    static func allNotifications(pageNumber: Int) -> Self {
        ShoofAPI.Endpoint(path: "/api/MobileV3/Notification/GetAll") {
            URLQueryItem(name: "pageNumber", value: "\(pageNumber)")
        }
    }
}
