//
//  News.swift
//  365Show
//
//  Created by ممم on 09/12/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation


extension ShoofAPI {
    struct News : Codable {
        let title: String
        let author: String
        let content: String
        let description: String
        let publishedAt: String
        let url: String
        let urlToImage: URL?
        let source: Source
    }
    
    struct Source: Codable {
        let id: String?
        let name: String
    }
    
    struct NewsAPI<T>: Codable {
        let status: String
        let totalResults: Int
        let articles: Int
    }
}
