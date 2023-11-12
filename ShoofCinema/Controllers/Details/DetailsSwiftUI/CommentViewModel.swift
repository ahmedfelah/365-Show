//
//  CommentViewModel.swift
//  ShoofCinema
//
//  Created by mac on 5/25/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


class CommentViewModel: ObservableObject {
    
    @Published var comments: [ShoofAPI.Comment] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    
    private var currentPageNumber = 1
    @Published var hasNextPage: Bool = false
    
    let mockComment = ShoofAPI.Comment(id: "1", userID: "1", userName: "Ahmed Al-Imran", userProfileURL: nil, message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy", date: "")
    
    let showId: String
    
    init(showId: String) {
        self.showId = showId
    }
   
    
    
    func fetchComments() {
        self.isLoading = true
        loadComments(showId: showId, pageNumber: currentPageNumber) {[weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                let response = try? result.get()
                self?.comments = response?.body ?? []
                self?.hasNextPage = !(response?.isOnLastPage ?? true)
            }
        }
    }
    
    func fetchMoreComment() {
        if !hasNextPage || isLoading || isLoadingMore {
            return
        }
        
        isLoadingMore.toggle()
        loadComments(showId: showId, pageNumber: currentPageNumber + 1) {[weak self] result in
            DispatchQueue.main.async {
                do {
                    let response = try result.get()
                    self?.hasNextPage = !response.isOnLastPage
                    self?.currentPageNumber += 1
                    DispatchQueue.main.async {
                        self?.comments.append(contentsOf: response.body)
                        
                    }
                } catch {
                    
                }
                
                self?.isLoadingMore = false
            }
        }
    }
    
    
    private func loadComments(showId: String, pageNumber: Int, completionHandler: @escaping
        (Result<ShoofAPI.Endpoint<[ShoofAPI.Comment]>.Response, Error>) -> Void) {
            ShoofAPI.shared.loadComments(showId: showId, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
}
