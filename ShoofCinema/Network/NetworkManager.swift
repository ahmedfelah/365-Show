//
//  ChannelsNM.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/23/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation
import SwiftyJSON


protocol NetworkViewDelegate : AnyObject {
    func requestEnded ()
    func failure()
    func success()
    func failureMessage(data: String)
}

extension NetworkViewDelegate {
    func success() { }
}

protocol ChannelsNVD : AnyObject {
    func requestEnded ()
    func failure()
    func noData()
    func success (sections : [ChannelSection])
}

protocol HomeSectionNVD : AnyObject {
    func requestEnded ()
    func failure()
    func noData()
    func homeSuccess (sections : [HomeSection])
    func moviesSuccess (sections : [HomeSection],isLast : Bool)
    func seriesSuccess (sections : [HomeSection], isLast : Bool)
    func tagsSuccess (sections : [HomeSection], isLast : Bool)
}

protocol ShowsNVD : AnyObject {
    func requestEnded ()
    func failure()
    func noData()
    func success (result : ShowsLoadingSuccessResult)
}

protocol ShowDetailsNVD : AnyObject {
    func detailsRequestEnded ()
    func detailsFailure()
    func successWith (result : JSON)
}

protocol MovieFavoriteNVD : AnyObject{
    func favoriteEnded()
    func favoriteFailure()
    func successfullyAdded()
    func successfullyRemoved ()
}

protocol ShowHistoryNVD : AnyObject{
    func historyRequestEnded()
    func historyRequestFailure()
    func clearHistorySuccess()
    func clearHistorySuccess(for movieId:String)
}


protocol RegistrationNVD : AnyObject {
    func successfullyRegistered()
}
class NetworkManager  {
    
    weak var networkVD : NetworkViewDelegate?
    weak var channelsVD : ChannelsNVD?
    weak var sectionDelegate : HomeSectionNVD?
    weak var showsDelegate : ShowsNVD?
    weak var detailsDelegate : ShowDetailsNVD?
    weak var registrationVD : RegistrationNVD?
    weak var movieFavoriteVD : MovieFavoriteNVD?
    weak var historyVD : ShowHistoryNVD?

    func getChannels() {
        RRequests.getChannels { [weak self] (channelsJson, error) in
            guard let `self` = self else {return}
            self.channelsVD?.requestEnded()
            if error != nil {
                self.channelsVD?.failure() ; return
            }
            
            guard let channelsJson = channelsJson else {
                self.channelsVD?.noData() ; return
            }
            
            if channelsJson["status"].boolValue == false {
                self.channelsVD?.failure() ; return
            }
            
            let sections = channelsJson["sections"].arrayValue
                .map({ChannelSection.init(from: $0)})
                .compactMap({$0})
            
            if sections.count == 0 {
                self.channelsVD?.failure() ; return
            }
            
            self.channelsVD?.success(sections: sections)
        }
    }

    func getHomeData () {
        RRequests.getHome { (json, error) in
            if error != nil {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.failure() ; return
            }

            guard let jsonData = json?.array else {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.noData() ; return
            }
            let sections : [HomeSection] = jsonData.compactMap { HomeSection(json: $0)}
                        
            self.sectionDelegate?.requestEnded()
            self.sectionDelegate?.homeSuccess(sections: sections)
        }

        //Get Categories
        // Categories used for getting suggested movies in the DetailsVC
        RRequests.getCategories { (json, error) in
            if error == nil {
                guard let array = json?.array else {return }
                mainCategoriesData = array.compactMap({SCCategory(from: $0)})
            }
        }
    }
    
    func getHomeMoviesData (page : Int) {
        RRequests.getHomeMovies(page: page) { (json, error) in
            if error != nil {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.failure() ; return
            }
            guard let json = json else {
                self.sectionDelegate?.requestEnded()
                return
            }
            let isLast : Bool = json["next_page_url"] == JSON.null
            guard let jsonData = json["data"].array ,!jsonData.isEmpty else {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.noData() ; return
            }
            let sections : [HomeSection] = jsonData.compactMap { HomeSection(json: $0)}
            self.sectionDelegate?.requestEnded()
            self.sectionDelegate?.moviesSuccess(sections: sections, isLast: isLast)
        }
    }
    
    func getHomeSeriesData (page : Int) {
        RRequests.getHomeSeries(page: page) { (json, error) in
            if error != nil {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.failure() ; return
            }
            guard let json = json else {
                self.sectionDelegate?.requestEnded()
                return
            }
            let isLast : Bool = json["next_page_url"] == JSON.null
            guard let jsonData = json["data"].array else {
                self.sectionDelegate?.requestEnded()
                self.sectionDelegate?.noData() ; return
            }
            
            let sections : [HomeSection] = jsonData.compactMap { HomeSection(json: $0)}
            
            self.sectionDelegate?.requestEnded()
            self.sectionDelegate?.seriesSuccess(sections: sections, isLast: isLast)
        }
    }
    
    func getHomeTagsData (page : Int) {
        RRequests.getHomeTags(page: page) { (json, error) in
            
            if error != nil {
                self.sectionDelegate?.requestEnded()
                return
            }

            guard let json = json else {
                self.sectionDelegate?.requestEnded()
                return
            }
            let isLast : Bool = json["next_page_url"] == JSON.null
            guard let jsonData = json["data"].array else {
                self.sectionDelegate?.requestEnded()
                return
            }
            
            let sections : [HomeSection] = jsonData.compactMap { HomeSection(json: $0)}
            
            self.sectionDelegate?.requestEnded()
            self.sectionDelegate?.tagsSuccess(sections: sections, isLast: isLast)
        }
    }
    
    func getShows(category : Int , page : Int , sorting:String?,sortingType:String?,year:String?, genre:String?) {
        RRequests.getCategory(with: category, page: page, with: sorting,of: sortingType, and: year, genreFilter: genre ) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getRandomShows(category : Int ) {
        RRequests.getRandomShowsForCategory(with: category) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json.array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: true)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getShowsByActor(actorName : String , page : Int , sorting:String?,sortingType:String?,year:String?, genre:String?) {
        RRequests.getActorShows(actorName: actorName, page: page, sorting:sorting, of: sortingType, yearFilter: year, genreFilter: genre) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getShowsByTagID(tagId : Int , page : Int , sorting:String?,sortingType:String?,year:String?, genre:String?) {
        RRequests.getTagsShows(tagID: tagId, page: page, sorting:sorting, of: sortingType, yearFilter: year, genreFilter: genre) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getHomeShows(tag : String, page : Int) {
        RRequests.getHomeShows(with: tag, page: page) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getShowsBySearch(keyword : String , page : Int , sorting:String?,sortingType:String?,year:String?, genre:String?) {
        RRequests.search(for: keyword, page: page, sorting: sorting, of: sortingType, year: year, genre: genre){[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }
    
    func getFavoriteShows(page : Int) {
        RRequests.getFavorites(for: page) {[weak self] (json, errr) in
            self?.showsDelegate?.requestEnded()
            guard let `self` = self else { return }
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }

        }
    }

    func getMovieDetails (token : String) {
        RRequests.getMovie(with: token) {[weak self] (json, err) in
            guard let `self` = self else {return}
            self.detailsDelegate?.detailsRequestEnded()
            if let json = json {
                self.detailsDelegate?.successWith(result: json)
            } else {
                self.detailsDelegate?.detailsFailure()
            }
        }
        
    }
    
    public func login (username : String , password : String) {
        RRequests.login(with: username,password) { [weak self] (json, err) in
            self?.networkVD?.requestEnded()
            if  err != nil {
                self?.networkVD?.failureMessage(data: err?.localizedDescription ?? "")
                return
            }
            guard let json = json else {
                self?.networkVD?.failure()
                return
            }
            if json["code"].stringValue == "done" {
                if let token = json["auth"].string {
                    self?.savingUserToken(token: token)
                    self?.registrationVD?.successfullyRegistered()
                }
            } else {
                self?.networkVD?.failure()
            }
            
        }
        
        
        
    }

    public func register (username : String , password : String, email : String) {
        
        self.networkVD?.requestEnded()
        RRequests.register(with: username,password,email) { [weak self](json, err) in
            if err != nil {
                self?.networkVD?.failureMessage(data: err?.localizedDescription ?? "")
                return
            }
            guard let json = json else {
                self?.networkVD?.failure()
                return
            }
            if json["code"].stringValue == "done" {
                if let token = json["auth"].string {
                    self?.savingUserToken(token: token)
                    self?.registrationVD?.successfullyRegistered()
                } else {
                    self?.networkVD?.failure()
                }
            } else {
                self?.networkVD?.failure()
            }
        }

    }
    
    public func getUserData () {
        RRequests.myInfo { [ weak self ] (json, err)  in
            self?.networkVD?.requestEnded()
            if err != nil {
                self?.networkVD?.failure()
                return
            }
            if let json = json?["data"] {
                self?.savingUserData(json: json)
                self?.networkVD?.success()
            } else {
                self?.networkVD?.failure()
            }
        }
    }
    
    public func logout () {
        
        RRequests.logout { (json, error) in
            self.networkVD?.requestEnded()
            if error == nil {
                Account.shared.token = nil
                Account.shared.info = nil
                NotificationCenter.default.post( name: Notification.Name(rawValue: "FavoriteUpdated"), object: nil)
                self.networkVD?.success()
            } else {
                self.networkVD?.failureMessage(data: error?.localizedDescription ?? "")
            }
            
        }
        
    }
    
    public func removeFromFavorite ( movieId : String ) {
        RRequests.deleteFromFavorite(where: String(movieId)) { (json, err) in
            self.movieFavoriteVD?.favoriteEnded()
            if err == nil {
                self.movieFavoriteVD?.successfullyRemoved()
            } else {
                self.movieFavoriteVD?.favoriteFailure()
            }
            
        }
    }
    
    public func addToFavorite ( movieId : String ) {
        RRequests.favoriteMovie(with: String(movieId)) { (json, err) in
            self.movieFavoriteVD?.favoriteEnded()
            if err == nil {
                self.movieFavoriteVD?.successfullyAdded()
            } else {
                self.movieFavoriteVD?.favoriteFailure()
            }
        }
    }
    
    public func writeComment ( movieId : String, comment : String ) {
        RRequests.addComment(with: movieId, commentText: comment) { (json, error) in
            self.networkVD?.requestEnded()
            if error == nil {
                self.networkVD?.success()
            } else {
                self.networkVD?.failureMessage(data: error?.localizedDescription ?? "")
            }
        }
    }
    
    public func submitNewRequest ( message : String) {
        RRequests.createRequest(with: message) { (json, error) in
            self.networkVD?.requestEnded()
            if error == nil {
                self.networkVD?.success()
            } else {
                self.networkVD?.failureMessage(data: error?.localizedDescription ?? "")
            }
        }
    }
    
    
    
    
    // MARK: - HISTORY
    
    public func getMyHistory(page : Int) {
        RRequests.getMyHistory(for: page) { (json, error) in
            self.showsDelegate?.requestEnded()
            if let json = json {
                if let showsJson = json["data"].array {
                    let shows = showsJson.compactMap({Show(from: $0)})
                    let isLast = json["next_page_url"] == JSON.null
                    let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
                    self.showsDelegate?.success(result: result)
                    return
                } else {
                    self.showsDelegate?.noData()
                }
            } else {
                self.showsDelegate?.failure()
                return
            }
        }
    }

    
    public func clearHistory() {
        RRequests.clearHistory() { (json, error) in
            self.historyVD?.historyRequestEnded()
            if error == nil {
                self.historyVD?.clearHistorySuccess()
            } else {
                self.historyVD?.historyRequestFailure()
            }
        }
    }
    
    public func removeShowFromHistory(movieId : String) {
        RRequests.deleteFromHistory(with: movieId) { (json, error) in
            if error == nil {
                self.historyVD?.clearHistorySuccess(for: movieId)
            } else {
                self.historyVD?.historyRequestFailure()
            }
        }
    }

    // MARK: - STORE
    private func savingUserToken(token : String) {
        Account.shared.token = token
        RRequests.sendFCM(RPref.fcmToken ?? "", completion: { (json, error) in
            if error == nil {
                print("FCM TOKEN SUCCESSFULLY UPDATED")
            }
        })
    }

    private func savingUserData(json : JSON) {
        let account = AccountInfo(
            name: json["user_name"].stringValue,
            id: json["user_id"].stringValue,
            img: json["user_img"].stringValue,
            fname: json["user_fname"].stringValue,
            email: json["user_email"].stringValue,
            date: json["user_date"].stringValue)
        Account.shared.info = account
    }
}



