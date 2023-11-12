//
//  ExploreViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


class ExploreViewModel: ObservableObject {
    
    @Published var status: ResponseStatus = .none
    @Published var explore: [ShoofAPI.Explore] = []
    @Published var errorsMessage: String = ""
    
    var currentPage = 1
    
    
    
    func loadExplore () {
        self.status = .loading
        ShoofAPI.shared.loadExplores(pageNumber: currentPage) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Explore]>.Response, Error>?) {
        do {
            let response = try result?.get()
            let explore = response?.body ?? []
            
            DispatchQueue.main.async {
                self.explore = explore
                self.status = .loaded
            }
        } catch {
            print("ERROR!", error)
        }
    }
    

    
}
