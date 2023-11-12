//
//  HomeViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/6/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var status: ResponseStatus = .none
    @Published var sections: [ShoofAPI.Section] = []
    @Published var errorsMessage: String = ""
    
    lazy var recentShows = realm.objects(RRecentShow.self)
    
    
    
    func loadSections () {
        self.status = .loading
        ShoofAPI.shared.loadNetworkStatus { _ in
            ShoofAPI.shared.loadSections(withTarget: .home, pageNumber: 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        }
    }
    
    func recentShows (ShowId: String) -> Float {
        if let rmRecentShow = recentShows.first(where: { $0.id == ShowId }) {
            return rmRecentShow.rmContinue?.left_at_percentage ?? 0
        }
        
        return 0
    }
    
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>?) {
        do {
            let response = try result?.get()
            let sections = response?.body ?? []
            
            DispatchQueue.main.async {
                self.sections = sections
                self.status = .loaded
            }
        } catch {
            print("ERROR!", error)
        }
    }
    
    
    
    
    
}
