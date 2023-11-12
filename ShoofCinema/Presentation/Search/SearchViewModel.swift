//
//  SearchViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/21/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


class SearchViewModel: ObservableObject {
    
    @Published var shows: [ShoofAPI.Show] = []
    @Published var searchKeyword: String = ""
    @Published var currentPage: Int = 1
    @Published var mediaType: ShoofAPI.Filter.MediaType = .all
    @Published var fromYearSelectedIndex = 0
    @Published var toYearSelectedIndex = 0
    @Published var rate: CGFloat = 0
    @Published var actors = ""
    @Published var genreSelectedIndex = 0
    @Published var filterBadgeCount = 0
    @Published var status: ResponseStatus = .none
    @Published var noData: Bool = false
    @Published var isLastPage: Bool = false
    
    var allYearsReversed: [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        var years = (1900...currentYear).map { String($0) }
       //years.append(.allTitle)
        
        return years.reversed()
    }
    
    var allYears: [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        var years = (1900...currentYear).map { String($0) }
       //years.append(.allTitle)
        
        return years
    }
    
    var allGenres: [ShoofAPI.Genre] {
        [ShoofAPI.Genre(id: -1, name: .allTitle)] + ShoofAPI.Genre.allGenres
    }
    
    let shoofAPI: ShoofAPI = .shared
    
    
    
    func loadShows() {
        self.status = .loading
        shoofAPI.searchShows(
            withKeywords: searchKeyword,
            genreID: genreSelectedIndex == 0 ? nil : allGenres[genreSelectedIndex].id,
            fromDate: allYears[fromYearSelectedIndex],
            toDate: allYearsReversed[toYearSelectedIndex],
            rate: Int(rate),
            pageNumber: currentPage
        ) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    func loadShowsMore() {
        guard !isLastPage else {return}
        self.status = .loading
        shoofAPI.searchShows(
            withKeywords: searchKeyword,
            genreID: genreSelectedIndex == 0 ? nil : allGenres[genreSelectedIndex].id,
            fromDate: allYears[fromYearSelectedIndex],
            toDate: allYearsReversed[toYearSelectedIndex],
            rate: Int(rate),
            pageNumber: currentPage + 1
        ) { [weak self] result in
            self?.handleAPIResponseShowMore(result: result)
        }
    }
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            print("resp", response.isOnLastPage)
            DispatchQueue.main.async {
                self.shows = response.body
                self.isLastPage = response.isOnLastPage
                self.status = .loaded
                self.noData = false
            }
        }  catch is URLError {
            DispatchQueue.main.async {
                //self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                self.noData = true
            }
        }
    }
    
    private func handleAPIResponseShowMore(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            DispatchQueue.main.async {
                self.shows.append(contentsOf: response.body)
                self.isLastPage = response.isOnLastPage
                self.currentPage = response.currentPage
                self.status = .loaded
            }
        }  catch is URLError {
            DispatchQueue.main.async {
                //self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
            }
        }
    }
    
    private func checkFilterChanged() {
        self.filterBadgeCount = 0
        
        if self.fromYearSelectedIndex != 0 {
            self.filterBadgeCount += 1
        }
        
        if self.toYearSelectedIndex != 0 {
            self.filterBadgeCount += 1
        }
        
        if !actors.isEmpty {
            self.filterBadgeCount += 1
        }
        
        if rate != 0 {
            self.filterBadgeCount += 1
        }
        
        if genreSelectedIndex != 0 {
            
            self.filterBadgeCount += 1
        }
    }
    
    func updateShows() {
        self.checkFilterChanged()
        self.loadShows()
    }
    
    
    func clearAll() {
        self.toYearSelectedIndex = 0
        self.fromYearSelectedIndex = 0
        self.rate = 0
        self.genreSelectedIndex = 0
        self.actors = ""
    }
    
}
