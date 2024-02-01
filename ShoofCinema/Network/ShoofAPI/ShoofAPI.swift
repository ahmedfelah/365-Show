//
//  ShoofAPI.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 11/3/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation
import Combine
import TBKNetworking
import FirebaseAuth
import GoogleSignIn
import Firebase
import FBSDKLoginKit

class ShoofAPI {
    private let session : URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    static let shared = ShoofAPI()
    private lazy var fireAuth = Auth.auth()
    private lazy var facebookLoginManager = LoginManager()
    
    private(set) var isInNetwork: Bool = false
    
    private(set) var apiUrl: String = "cinema5-api.shoofnetwork.net"
    private var apiUrlInNetwork: String = "cinema5-api.shoofnetwork.net"
    //365ar.show
    
    func loadNetworkStatus(completionHandler: @escaping (Result<ShoofAPI.OldAPIEndpoint<ShoofAPI.NetworkStatusResponse>.Response, Swift.Error>) -> Void) {
        session.load(.networkStatus) { [weak self] result in
            do {
                let response = try result.get()
                self?.isInNetwork = response.inNetwork
                
                guard let self = self else {return}
                
                self.apiUrl = self.isInNetwork ? self.apiUrlInNetwork : self.apiUrl
                
            } catch {
                print(error)
            }
            
            completionHandler(result)
        }
    }
    
    func loadReels(pageNumber: Int,  completionHandler: @escaping (Result<ShoofAPI.Endpoint<[ShoofAPI.Reel]>.Response, Swift.Error>) -> Void) {
        session.load(.reels(pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadSections(withTarget target: ShoofAPI.Endpoint<[ShoofAPI.Section]>.Target, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Swift.Error>) -> Void) {
        session.load(.sections(withTarget: target, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadExplores(pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Explore]>.Response, Swift.Error>) -> Void) {
        session.load(.explores(pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func register(withEmail email: String, userName: String, name: String, password: String,  completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        session.load(.register(withEmail: email, userName: userName, name: name, password: password)) { [weak self] result in
            self?.handleAuthentication(result: result)
            completionHandler(result)
        }
    }
    
    func addComment(_ commentMessage: String, showID: String, completionHandler: @escaping (Result<ShoofAPI.Endpoint<ShoofAPI.Comment>.Response, Swift.Error>) -> Void) {
        session.load(.addComment(commentMessage, showID: showID), completionHandler: completionHandler)
    }
    
    func loadComments(showId: String, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[ShoofAPI.Comment]>.Response, Swift.Error>) -> Void) {
        session.load(.getComments(showId: showId, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadWatchLaterShows(pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[WatchLaterShow]>.Response, Swift.Error>) -> Void) {
        session.load(.watchLaterShows(pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func addShowToWatchLater(_ show: Show, completionHandler: @escaping (Result<ShoofAPI.Endpoint<WatchLaterShow>.Response, Swift.Error>) -> Void) {
        session.load(.addShowToWatchLater(showID: show.id), completionHandler: completionHandler)
    }
    
    func subcribe(to show: Show, completionHandler: @escaping (Result<ShoofAPI.Endpoint<SubscribeShow>.Response, Swift.Error>) -> Void) {
        session.load(.subscribe(toShowWithID: show.id)) { result in
            do {
                let response = try result.get()
                let topic = response.body.topic
                
                Messaging.messaging().subscribe(toTopic: topic) { error in
                  print("Subscribed to \(topic) topic")
                }
            } catch {
                print("Failed to subscribe to topic with error: \(error)")
            }
            
            completionHandler(result)
        }
    }
    
    func unsubscrible(from show: Show, completionHandler: @escaping (Result<ShoofAPI.NoValueEndpoint.Response, Swift.Error>) -> Void) {
        session.load(.unsubscrible(fromShowWithID: show.id)) { result in
            do {
                let _ = try result.get()
                let topic = "Series_\(show.id)"
                
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                  print("Unsubscribed from \(topic) topic")
                }
            } catch {
                print("Failed to unsubscribe from topic with error: \(error)")
            }
            
            completionHandler(result)
        }
    }
    
    func removeShowFromWatchLater(_ show: Show, completionHandler: @escaping (Result<ShoofAPI.Endpoint<WatchLaterShow>.Response, Swift.Error>) -> Void) {
        session.load(.removeShowFromWatchLater(showID: show.id), completionHandler: completionHandler)
    }
    
    func signInWithFacebook(on viewController: UIViewController, completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        facebookLoginManager.logIn(permissions: ["public_profile"], from: viewController) { [weak self] result, error in
            if let result = result {
                guard !result.isCancelled else {
                    completionHandler(.failure(Error.authenticationCancelled))
                    return
                }
                
                if let token = result.token {
                    let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                    
                    self?.fireAuth.signIn(with: credential) { result, error in
                        if let result = result {
                            self?.signInWithShoof(userUID: result.user.uid, completionHandler: completionHandler)
                        } else if let error = error {
                            completionHandler(.failure(error))
                        } else {
                            completionHandler(.failure(Error.unknown))
                        }
                    }
                } else {
                    completionHandler(.failure(Error.unknown))
                }

            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.failure(Error.unknown))
            }
        }
    }
    
    enum Error : LocalizedError {
        case notInNetwork
        case notLoggedIn
        case authenticationCancelled
        case appNotReady
        case unknown
        case apiError
        
        // FIXME: - Localize this...
        var errorDescription: String? {
            switch self {
            case .notInNetwork: return "Performing a request outside ShoofNetwork"
            case .appNotReady: return "App not ready"
            case .unknown: return "Unknown error has occured"
            case .authenticationCancelled: return "Authentication cancelled"
            default: return nil
            }
        }
    }
    
    func signInWithGoogle(on viewController: UIViewController, completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completionHandler(.failure(Error.appNotReady)) // Should never happen
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] result, error in
            if let user = result?.user, let UseridToken = user.idToken?.tokenString {
                let credential = GoogleAuthProvider.credential(withIDToken: UseridToken, accessToken: user.accessToken.tokenString)
                
                self.fireAuth.signIn(with: credential) { result, error in
                    self.fireAuth.currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            completionHandler(.failure(error))
                            return;
                        }
                        
                        if let idToken = idToken {
                            self.signInWithShoof(userUID: idToken, completionHandler: completionHandler)
                        }
                        
                    }
                    
                    if let error = error {
                        completionHandler(.failure(error))
                    }
                }
                
            } else if let error = error {
                if let error = error as? GIDSignInError, error.code == .canceled {
                    completionHandler(.failure(Error.authenticationCancelled))
                } else {
                    completionHandler(.failure(error))
                }
            } else {
                completionHandler(.failure(Error.unknown))
            }
        }
    }
    
    /// Sign in using Firebase User.uid property
    private func signInWithShoof(userUID: String, completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        session.load(.signInWithShoof(userUID: userUID)) { [weak self] result in
            self?.handleAuthentication(result: result)
            completionHandler(result)
        }
    }
    
    func signOut() {
        try? fireAuth.signOut()
        User.current = nil
    }
    
    func login(withEmail email: String, password: String,  completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        session.load(.login(withEmail: email, password: password)) { [weak self] result in
            self?.handleAuthentication(result: result)
            completionHandler(result)
        }
    }
    
    func forgetPassword(withEmail email: String, completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<String>.Response, Swift.Error>) -> Void) {
        session.load(.forgetPassword(email: email)) { result in
            completionHandler(result)
        }
    }
    
    func changePassword(code: String, password: String, token: String, completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<String>.Response, Swift.Error>) -> Void) {
        session.load(.changePassword(code: code, password: password, token: token)) { result in
            completionHandler(result)
        }
    }
    
    func updateUser(
        name: String? = ShoofAPI.User.current?.name,
        username: String? = ShoofAPI.User.current?.userName,
        email: String? = ShoofAPI.User.current?.email,
        password: String? = nil,
        phone: String? = ShoofAPI.User.current?.phone,
        image: String? = nil,
        completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void
    ) {
        session.load(.updateUser(name: name, username: username, email: email, password: password, phone: phone, image: image)) { result in
            completionHandler(result)
        }
    }
    
    func currentUser(completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) -> Void) {
        session.load(.currentUser()) { [weak self] result in
            self?.handleUpdateUser(result: result)
            completionHandler(result)
        }
    }
    
    func autoLogin(token: String?, deviceType: Int, baseUrl: String ,completionHandler: @escaping (Result<ShoofAPI.ResellerEndpoint<Bool>.Response, Swift.Error>) -> Void) {
        session.load(.autoLogin(token: token, deviceType: deviceType, baseUrl: baseUrl)) { result in
            completionHandler(result)
        }
    }

    
    func checkReseller(host: String, path: String ,completionHandler: @escaping (Result<ShoofAPI.AccountEndpoint<ShoofAPI.AutoLogin>.Response, Swift.Error>) -> Void) {
        session.load(.checkReseller(host: host, path: path)) { result in
            completionHandler(result)
        }
    }
    
    private func handleAuthentication(result: Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) {
        do {
            let response = try result.get()
            let user = response.body
            
            User.current = user
            
//            user.topics.forEach { topic in
//                Messaging.messaging().subscribe(toTopic: topic) { error in
//                  print("Subscribed to \(topic) topic")
//                }
//            }
        } catch {
            // Errors not handled here
        }
    }
    
    private func handleUpdateUser(result: Result<ShoofAPI.AccountEndpoint<User>.Response, Swift.Error>) {
        do {
            let response = try result.get()
            let user = response.body
            
            User.current = User(name: user.name, userName: user.userName, email: user.email, phone: user.phone, id: user.id, token: User.current?.token, image: user.image, topics: user.topics)
            
//            user.topics.forEach { topic in
//                Messaging.messaging().subscribe(toTopic: topic) { error in
//                  print("Subscribed to \(topic) topic")
//                }
//            }
        } catch {
            // Errors not handled here
        }
    }
    
    
    func loadShows(withFilter filter: Filter, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Show]>.Response, Swift.Error>) -> Void) {
        session.load(.shows(withFilter: filter, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadEpisodes(forSeasonWithID seasonID: String, pageNumber: Int = 1, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Media.Episode]>.Response, Swift.Error>) -> Void) {
        session.load(.episodes(forSeasonWithID: seasonID, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadDetails(for show: Show, completionHandler: @escaping (Result<ShoofAPI.Endpoint<Show>.Response, Swift.Error>) -> Void) {
        session.load(.show(withID: show.id), completionHandler: completionHandler)
    }
    
    func loadDetails(forShowWithID showID: String, completionHandler: @escaping (Result<ShoofAPI.Endpoint<Show>.Response, Swift.Error>) -> Void) {
        session.load(.show(withID: showID), completionHandler: completionHandler)
    }
    
    func loadDummyShow(completionHandler: @escaping (Result<ShoofAPI.Endpoint<Show>.Response, Swift.Error>) -> Void) {
        session.load(.testShow, completionHandler: completionHandler)
    }
    
    func loadMoreShows(forSectionWithID sectionID: String, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Show]>.Response, Swift.Error>) -> Void) {
        session.load(.shows(forSectionWithID: sectionID, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadShows(forActorWithID actorID: Int, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Show]>.Response, Swift.Error>) -> Void) {
        session.load(.shows(forActorWithID: actorID, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadHomeSections(numberOfShowsPerSection: Int, pageNumber: Int = 1, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Section]>.Response, Swift.Error>) -> Void) {
        session.load(.homeSections(numberOfShowsPerSection: numberOfShowsPerSection, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func searchShows(withKeywords keywords: String, genreID: Int?, fromDate: String?, toDate: String?, rate: Int?, pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Show]>.Response, Swift.Error>) -> Void) {
        session.load(.shows(matching: keywords, genreID: genreID, rate: rate, fromDate: fromDate, toDate: toDate, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func autocomplete(showName: String, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Autocomplete]>.Response, Swift.Error>) -> Void) {
        session.load(.autocomplete(showName: showName), completionHandler: completionHandler)
    }
    
    func loadSuggestedShows(pageNumber: Int, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[Autocomplete]>.Response, Swift.Error>) -> Void) {
        session.load(.suggestedShows(pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func increaseSearchCount(showId: String, completionHandler: @escaping (Result<ShoofAPI.NoValueEndpoint.Response, Swift.Error>) -> Void) {
        session.load(.increaseSearchCount(showId: showId), completionHandler: completionHandler)
    }
    
    func loadTVSections(completionHandler: @escaping (Result<TVEndpoint.Response, Swift.Error>) -> Void) {
        session.load(.sections, completionHandler: completionHandler)
    }
    
    func loadUserRequests(pageNumber: Int, completionHandler: @escaping (Result<Endpoint<[Request]>.Response, Swift.Error>) -> Void) {
        session.load(.userRequests(pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func loadRequests(withStatus requestStatus: Request.Status = .open, pageNumber: Int, completionHandler: @escaping (Result<Endpoint<[Request]>.Response, Swift.Error>) -> Void) {
        session.load(.allRequests(withStatus: requestStatus, pageNumber: pageNumber), completionHandler: completionHandler)
    }
    
    func addRequest(withTitle title: String, details: String, completionHandler: @escaping (Result<Endpoint<Request>.Response, Swift.Error>) -> Void) {
        session.load(.addRequest(withTitle: title, details: details), completionHandler: completionHandler)
    }
    
    func addTopic(_ topic: String, completionHandler: @escaping (Result<AccountEndpoint<Bool>.Response, Swift.Error>) -> Void) {
        if let user = User.current {
            session.load(.addTopic(topic, forUserWithID: user.id), completionHandler: completionHandler)
        } else {
            completionHandler(.failure(Error.notLoggedIn))
        }
    }
    
    func loadAllNotifications(pageNumber: Int, completionHandler: @escaping (Result<Endpoint<[Notification]>.Response, Swift.Error>) -> Void) {
        session.load(.allNotifications(pageNumber: pageNumber), completionHandler: completionHandler)
    }
}
