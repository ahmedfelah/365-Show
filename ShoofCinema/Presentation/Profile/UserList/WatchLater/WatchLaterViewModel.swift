//
//  WatchLaterViewModel.swift
//  ShoofCinema
//
//  Created by mac on 8/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation

class WatchLaterViewModel: ObservableObject {
    
    @Published var status: ResponseStatus = .none
    @Published var shows: [ShoofAPI.Show] = []
    
    var pageNumber = 1
    
    
    func load() {
        self.status = .loading
        ShoofAPI.shared.loadWatchLaterShows(pageNumber: pageNumber) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.WatchLaterShow]>.Response, Error>) {
        do {
            let response = try result.get()
            let shows = response.body.compactMap(\.show)
            
            DispatchQueue.main.async { [self] in
                self.shows = shows
                self.status = .loaded
            }
        } catch let error as URLError {
            DispatchQueue.main.async { [self] in
                //                if error.code == .userAuthenticationRequired {
                //                    showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentNotLoggedInMessage, imageName: "ic-no-fav-icon", actionButtonTitle: .loginButtonTitle, action: segueToLogin)
                //                } else {
                //                    tabBar?.alert.genericError()
                //                 }
                
                self.status = .failed
            }
        } catch {
            DispatchQueue.main.async { [self] in
                //                showsCollectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
                self.status = .failed
            }
        }
        
    }
}
