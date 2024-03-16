//
//  ShowsViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/17/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


class ShowViewModel: ObservableObject {
    
    enum `Type` {
        case section(id: String)
        case actor(id: Int, name: String)
        case filter(ShoofAPI.Filter)
        case shows([ShoofAPI.Show])
    }
    
    let shoofAPI = ShoofAPI.shared
    
    var type: `Type`?
    
    var allGenres: [ShoofAPI.Genre] {
        [ShoofAPI.Genre(id: -1, name: .allTitle)] + ShoofAPI.Genre.allGenres
    }
    
    @Published var status: ResponseStatus = .none
    @Published var shows: [ShoofAPI.Show] = []
    @Published var errorsMessage: String = ""
    @Published var currentPage: Int = 0
    @Published var isLastPage: Bool = false
    @Published var filter: ShoofAPI.Filter?
    
    
    init(type: `Type`?) {
        self.type = type
        
        if case .filter(let filter) = type {
            self.filter = filter
        }
    }
    
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            let shows = response.body
            
            print("Loaded page \(response.currentPage) of \(response.numberOfPages).")
            
            DispatchQueue.main.async {
                self.shows = shows
                self.currentPage += 1
                self.isLastPage = response.isOnLastPage
                self.status = .loaded
            }
        } catch is URLError {
            DispatchQueue.main.async {
                //self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    private func handleAPIResponseLoadMore(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            let shows = response.body
            
            print("Loaded page \(response.currentPage) of \(response.numberOfPages).")
            
            DispatchQueue.main.async {
                self.shows.append(contentsOf: shows)
                self.currentPage += 1
                self.isLastPage = response.isOnLastPage
                self.status = .loaded
            }
        } catch is URLError {
            DispatchQueue.main.async {
                //self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    
    func loadShows() {
        guard !isLastPage else {return}
        
        self.status = .loading
        
        switch type {
        case .section(let sectionID):
            shoofAPI.loadMoreShows(forSectionWithID: sectionID, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
            
        case .actor(let actorID, _):
            shoofAPI.loadShows(forActorWithID: actorID, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        case .filter(let filter):
            shoofAPI.loadShows(withFilter: filter, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        case .shows(let shows):
            DispatchQueue.main.async { [self] in
                self.shows = shows
                self.isLastPage = true
            }
        default: break
        }
    }
    
    func loadMoreShows() {
        guard !isLastPage, status == .loaded else {return}
        
        self.status = .loading
        
        switch type {
        case .section(let sectionID):
            shoofAPI.loadMoreShows(forSectionWithID: sectionID, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponseLoadMore(result: result)
            }
            
            
        case .actor(let actorID, _):
            shoofAPI.loadShows(forActorWithID: actorID, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponseLoadMore(result: result)
            }
            
        case .filter(let filter):
            shoofAPI.loadShows(withFilter: filter, pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponseLoadMore(result: result)
            }
            
        case .shows(let shows):
            DispatchQueue.main.async { [self] in
                self.shows = shows
                self.isLastPage = true
            }
            
        default: break
        }
    }
}
