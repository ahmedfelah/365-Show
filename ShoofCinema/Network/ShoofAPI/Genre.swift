//
//  Genre.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Genre : Decodable {
        let id: Int
        let name: String
        
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
}

extension ShoofAPI.Genre {
    static let comedy = ShoofAPI.Genre(id: 1, name: "Comedy")
    static let crime = ShoofAPI.Genre(id: 2, name: "Crime")
    static let thriller = ShoofAPI.Genre(id: 3, name: "Thriller")
    static let biography = ShoofAPI.Genre(id: 4, name: "Biography")
    static let war = ShoofAPI.Genre(id: 5, name: "War")
    static let adventure = ShoofAPI.Genre(id: 6, name: "Adventure")
    static let family = ShoofAPI.Genre(id: 7, name: "Family")
    static let fantasy = ShoofAPI.Genre(id: 8, name: "Fantasy")
    static let mystery = ShoofAPI.Genre(id: 9, name: "Mystery")
    static let sport = ShoofAPI.Genre(id: 10, name: "Sport")
    static let action = ShoofAPI.Genre(id: 11, name: "Action")
    static let horror = ShoofAPI.Genre(id: 12, name: "Horror")
    static let romance = ShoofAPI.Genre(id: 13, name: "Romance")
    static let drama = ShoofAPI.Genre(id: 14, name: "Drama")
    static let history = ShoofAPI.Genre(id: 15, name: "History")
    static let filmNoir = ShoofAPI.Genre(id: 16, name: "Film-Noir")
    static let musical = ShoofAPI.Genre(id: 17, name: "Musical")
    static let sciFi = ShoofAPI.Genre(id: 18, name: "Sci-Fi")
    static let documentary = ShoofAPI.Genre(id: 19, name: "Documentary")
    static let animation = ShoofAPI.Genre(id: 20, name: "Animation")
//    static let na = ShoofAPI.Genre(id: 21, name: "N/A")
    static let western = ShoofAPI.Genre(id: 22, name: "Western")
    static let short = ShoofAPI.Genre(id: 23, name: "Short")
    static let realityTV = ShoofAPI.Genre(id: 24, name: "Reality-TV")
    static let news = ShoofAPI.Genre(id: 25, name: "News")
    static let talkShow = ShoofAPI.Genre(id: 26, name: "Talk-Show")
    static let gameShow = ShoofAPI.Genre(id: 27, name: "Game-Show")
    static let adult = ShoofAPI.Genre(id: 28, name: "Adult")
    
    static let allGenres: [ShoofAPI.Genre] = [
        .comedy, .crime, .thriller, .biography, .war, .adventure, .family, .fantasy, .mystery, .sport, .action, .horror, .romance, .drama, .history, .filmNoir, .musical, .sciFi, .documentary, .animation, .western, .short, .realityTV, .news, .talkShow, .gameShow, .adult
    ]
}
