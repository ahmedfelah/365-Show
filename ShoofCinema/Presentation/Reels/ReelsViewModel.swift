//
//  ReelsViewModel.swift
//  365Show
//
//  Created by ممم on 18/11/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation

class ReelsViewModel: ObservableObject {
    
    @Published var status: ResponseStatus = .none
    @Published var reels: [ShoofAPI.Reel] = []
    @Published var errorsMessage: String = ""
    
    var currentPage = 1
    
    
    
    func loadReels () {
        self.status = .loading
        ShoofAPI.shared.loadExplores(pageNumber: currentPage) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Explore]>.Response, Error>?) {
        ShoofAPI.shared.loadReels(pageNumber: 1) { [weak self] result in
            do {
                let response = try result.get()
                DispatchQueue.main.async {
                    self?.reels.append(contentsOf: response.body)
                    print("reels", self?.reels)
                }
            } catch {
                print("ERROR LOADING REELS: ", error)
            }
        }
    }
    

    
}
