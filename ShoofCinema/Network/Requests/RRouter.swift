//
//  RRouter.swift
//  Repo
//
//  Created by Husam Aamer on 7/31/17.
//  Copyright © 2017 FH. All rights reserved.
//

import UIKit

import Foundation
import Alamofire
import SwiftyJSON
//import FirebaseInstanceID
import FirebaseMessaging

enum Routes {
    
    static var cinemaWebsite :String {
        return "https://cinema.shoofnetwork.net"
    }
    
    static var cinemaAPIV1 :String {
        return "http://cinema.shoofnetwork.net/cinema/api"
    }
    static var cinemaAPI :String {
            return "http://cinema.shoofnetwork.net/cinema/api/v2"
    }
    static var cinemaAPIv3 :String {
        return "http://cinema.shoofnetwork.net/cinema/api/v3"
    }
    static var tvURLString :String {
        return "https://tv.shoofnetwork.net"
    }
    static let abraj = "https://supercellnetwork.com/abraj/api"
    
    static let categoris        = "/getFullCategories"
    static let home             = "/home"
    static let movies           = "/movies"
    static let series           = "/series"
    static let tag              = "/tags"
    static let getMovie         = "/getMovie"
    static let getByCategory    = "/getByCategory"
    static let getShowByActor   = "/getMoviesByActor"
    static let getMoviesByTagID   = "/getMoviesByTagID"
    static let search           = "/search"
    static let getRandomShows   = "/getRnd"
    
    static let login            = "/login"
    static let logout           = "/logout"
    static let register         = "/join"
    static let myInfo           = "/myInfo"
    
    static let listRequests     = "/listRequests"
    static let myRequests       = "/myRequests"
    static let reply            = "/reply"
    static let createRequest    = "/request"
    static let singleRequest    = "/gsr"
    
    static let addComment       = "/addComment"
    
    static let addFavorite      = "/addFavorite"
    static let delFavorite      = "/delFavorite"
    static let myFavorites      = "/myFavorites"
    
    static let myHistory        = "/myHistory"
    static let addToHistory     = "/addHistory"
    static let deleteFromHistory = "/deleteHistory"
    static let clearHistory     = "/clearHistory"
	
    static let updateToken      = "/updatetoken"
    static let getNotify        = "/getNotify"
    
    static let netword          = "/network" // Check whether user inside domain or not
    
    static let abraj_all        = "/all"
    static let abraj_neededData = "/getNeededData"
    static let abraj_add        = "/add"
    
}


// MARK:- Stories
extension RRequests {
    
    static func getCategories(completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.categoris, method: .get, params: [:]) { (json, error) in
            completion(json,error)
        }
    }
    static func getChannels(completion : @escaping completionBlock) {    
        startRequest(baseURL: Routes.tvURLString, path: "/api", method: .get, params: [:]) { (json, error) in
            completion(json,error)
        }
    }
    static func getHome(completion : @escaping completionBlock) {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.home, method: .get, params: [:]) { (json, error) in
            completion(json,error)
        }
    }
    static func getHomeMovies(page : Int , completion : @escaping completionBlock) {
        let params : [String:Any] = [
            "page" : page
        ]
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.movies, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    
    static func getHomeSeries(page : Int , completion : @escaping completionBlock) {
        let params : [String:Any] = [
            "page" : page
        ]
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.series, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    
    static func getHomeTags(page : Int ,completion : @escaping completionBlock) {
        let params : [String:Any] = [
            "p" : page
        ]
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.tag, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    
    static func getCategory(with categoryId:Int,
                            page:Int,
                            with sorting:String?,of sortingType:String?,
                            and yearFilter:String?, genreFilter:String?,
                            completion : @escaping completionBlock)
    {
        
        var params : [String:Any] = [
            "categoryID" : categoryId,
            "page" : page
        ]
        if let sort = sorting {
            params["sortBy"] = sort
        }
        if let sortType = sortingType {
            params["sortType"] = sortType
        }
        if let year = yearFilter {
            params["year"] = year
        }
        if let genre = genreFilter {
            params["genre"] = genre
        }
        
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.getByCategory, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    
    static func getActorShows(actorName : String ,page:Int , sorting:String?,of sortingType:String?,  yearFilter:String?, genreFilter:String?, completion : @escaping completionBlock) {
        var params : [String:Any] = [
            "actor" : actorName,
            "page" : page
        ]
        if let sort = sorting {
            params["sortBy"] = sort
        }
        if let sortType = sortingType {
            params["sortType"] = sortType
        }
        if let year = yearFilter {
            params["year"] = year
        }
        if let genre = genreFilter {
            params["genre"] = genre
        }
        
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.getShowByActor, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    
    static func getTagsShows(tagID : Int ,page:Int , sorting:String?,of sortingType:String?,  yearFilter:String?, genreFilter:String?, completion : @escaping completionBlock) {
        var params : [String:Any] = [
            "tag_id" : tagID,
            "page" : page
        ]
        if let sort = sorting {
            params["sortBy"] = sort
        }
        if let sortType = sortingType {
            params["sortType"] = sortType
        }
        if let year = yearFilter {
            params["year"] = year
        }
        if let genre = genreFilter {
            params["genre"] = genre
        }
        
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.getMoviesByTagID, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
    static func getHomeShows(with tag:String, page:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.home + "/" + tag, method: .get, params: ["page":page]) { (json, error) in
            completion(json,error)
        }
    }
    static func getMovie(with token:String,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.getMovie, method: .get, params: ["token":token]) { (json, error) in
            completion(json,error)
        }
    }
    static func getRandomShowsForCategory(with category_id:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.getRandomShows, method: .get, params: ["categoryID":category_id]) { (json, error) in
            completion(json,error)
        }
    }
    static func search(for keyword:String,
                       page:Int,
                       sorting:String?,of sortingType:String?,
                       year:String?,genre:String?,
                       completion : @escaping completionBlock)
    {
        
        var params : [String:Any] = [
            "keyword" : keyword,
            "page" : page
        ]
        if let sort = sorting {
            params["sortBy"] = sort
        }
        if let sortType = sortingType {
            params["sortType"] = sortType
        }
        if let year = year {
            params["year"] = year
        }
        if let genre = genre {
            params["genre"] = genre
        }
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.search, method: .get, params: params) { (json, error) in
            completion(json,error)
        }
    }
}

//MARK:- Favorite
extension RRequests {
    static func favoriteMovie(with movie_id:String,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPIV1, path: Routes.addFavorite, method: .post, params: [
            "movie_id":movie_id
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func deleteFromFavorite(where movie_id:String,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPIV1, path: Routes.delFavorite, method: .post, params: [
            "movie_id":movie_id
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func getFavorites(for page:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.myFavorites, method: .get, params: [
            "page":page
        ]) { (json, error) in
            completion(json,error)
        }
    }
}


//MARK:- history
extension RRequests {
	@available(*, deprecated, message: "Use local history instead")
    static func addToHistory(with movie_id:String,completion : @escaping completionBlock) {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.addToHistory, method: .post, params: [
            "movie_id":movie_id
        ]) { (json, error) in
            completion(json,error)
        }
    }
    
	@available(*, deprecated, message: "Use local history instead")
    static func getMyHistory(for page:Int,completion : @escaping completionBlock) {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.myHistory, method: .get, params: [
            "page":page
        ]) { (json, error) in
            completion(json,error)
        }
    }
    
	@available(*, deprecated, message: "Use local history instead")
    static func clearHistory(completion : @escaping completionBlock) {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.clearHistory, method: .post, params: [:]) {
            (json, error) in
            completion(json,error)
        }
    }
    
	@available(*, deprecated, message: "Use local history instead")
    static func deleteFromHistory(with movie_id:String,completion : @escaping completionBlock) {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.deleteFromHistory, method: .post, params: [
            "movie_id":movie_id
        ]) { (json, error) in
            completion(json,error)
        }
    }
}

extension RRequests {
    static func login(with username:String,_ password:String ,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.login, method: .post, params: [
            "user_name":username,
            "user_password":password,
            "fToken":RPref.token ?? ""
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func register(with username:String,_ password:String,_ email:String ,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.register, method: .post, params: [
            "user_name":username,
            "user_password":password,
            "user_email":email,
            "fToken":nil ?? ""
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func logout(completion : @escaping completionBlock)
    {
        let params : [String:Any] = {
            if let fToken = RPref.fcmToken {
                return ["fToken":fToken, "flag":1]
            } else {
                return ["flag":0]
            }
        }()
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.logout, method: .post, params:params) { (json, error) in
            completion(json,error)
        }
    }
    static func myInfo(completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPIv3, path: Routes.myInfo, method: .get, params: [:]) { (json, error) in
            completion(json,error)
        }
    }
}


extension RRequests {
    static func listRequests(for page:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.listRequests, method: .get, params: [
            "page":page
        ]) { (json, error) in
            completion(json,error)
        }
    }
    //Used in notifications, when user received notification about admin reply
    static func getSingleRequest(with id:String,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.singleRequest, method: .get, params: [
            "request_id":id
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func listMyRequests(for page:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.myRequests, method: .get, params: [
            "page":page
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func replyRequest(with id:String,
                             replyText:String,
                             completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.reply, method: .post, params: [
            "reply_txt":replyText,
            "request_id":id
        ]) { (json, error) in
            completion(json,error)
        }
    }
    static func createRequest(with message:String,
                             completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.createRequest, method: .post, params: [
            "request_txt":message
        ]) { (json, error) in
            completion(json,error)
        }
    }
}

extension RRequests {
    static func addComment(with movie_id:String,
                             commentText:String,
                             completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.addComment, method: .post, params: [
            "comment":commentText,
            "movie_id":movie_id
        ]) { (json, error) in
            completion(json,error)
        }
    }
}

extension RRequests {
    static func getNotifications(for page:Int,completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.getNotify, method: .post, params: [
            "page":page
        ]) { (json, error) in
            completion(json,error)
        }
    }
}
extension RRequests {
    static func testNetwork(completion : @escaping completionBlock)
    {
        startRequest(baseURL: Routes.cinemaAPI, path: Routes.netword, method: .get, params: [:]) { (json, error) in
            completion(json,error)
        }
    }
}

extension RRequests {
    static func getPoints (completion:@escaping completionBlock) {
        
        let url = URL(string: Routes.abraj + Routes.abraj_all)!
        AF.request(url,
                          method: .get,
                          parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (resp) in
                let rsp = resp
                let examined = examine(Response : resp)
                
                /*
                 Check alamofire error
                 */
                if let error = examined.error {
                    //alert(title: "Error", body: "Error in \(url.absoluteString)  : \(error.localizedDescription)", cancel: "Cancel")
                    completion(nil, error)
                    let msg = "Error in \(url.absoluteString)  : \(error.localizedDescription)"
                    //fatalError()
                    //return // uncomment after putting error alert
                }
                
                /*
                 Check api error
                 */
                if let json = examined.json {
                    /*
                     here we should check api error
                     but shasha.giganet has no error info !
                     */
                    completion(json , nil)
                }
        }
    }
    static func getAbrajCitiesAndTypes (completion:@escaping completionBlock) {
        
        let url = URL(string: Routes.abraj + Routes.abraj_neededData)!
        AF.request(url,
                          method: .get,
                          parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (resp) in
                let examined = examine(Response : resp)
                
                /*
                 Check alamofire error
                 */
                if let error = examined.error {
                    //alert(title: "Error", body: "Error in \(url.absoluteString)  : \(error.localizedDescription)", cancel: "Cancel")
                    completion(nil, error)
                    let msg = "Error in \(url.absoluteString)  : \(error.localizedDescription)"
                    //fatalError()
                    //return // uncomment after putting error alert
                }
                
                /*
                 Check api error
                 */
                if let json = examined.json {
                    /*
                     here we should check api error
                     but shasha.giganet has no error info !
                     */
                    completion(json , nil)
                }
        }
    }
    static func addBurj (info:[String:Any],completion:@escaping completionBlock) {
        
        let url = URL(string: Routes.abraj + Routes.abraj_add)!
        AF.request(url,
                          method: .post,
                          parameters: info, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (resp) in
                let examined = examine(Response : resp)
                
                /*
                 Check alamofire error
                 */
                if let error = examined.error {
                    //alert(title: "Error", body: "Error in \(url.absoluteString)  : \(error.localizedDescription)", cancel: "Cancel")
                    completion(nil, error)
                    let msg = "Error in \(url.absoluteString)  : \(error.localizedDescription)"
                    //fatalError()
                    //return // uncomment after putting error alert
                }
                
                /*
                 {
                 "success" : false,
                 "server_response" : "The phones field is required."
                 }
                 */
                
                /*
                 Check api error
                 */
                guard let json = examined.json else {
                    let message = "رد الخادم غير متوقع"
                    completion(nil, RError(localizedTitle: "خطأ",
                                            localizedDescription: message, code: 500))
                    return
                }
                
                if json["success"].bool == false {
                    let message = json["server_response"].string ?? "خطأ غير معروف"
                    completion(nil, RError(localizedTitle: "خطأ",
                                            localizedDescription: message, code: 0))
                    return
                }
                
                completion(json , nil)
        }
    }
}
