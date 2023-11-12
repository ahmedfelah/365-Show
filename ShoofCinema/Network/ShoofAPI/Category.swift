//
//  Category.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Category : Codable {
        let id: Int
        let name: String?
    }
}

extension ShoofAPI.Category {
    static var allCategories: [ShoofAPI.Category] {
        [
            ShoofAPI.Category(id: 215, name: "اجنبي"),
            ShoofAPI.Category(id: 217, name: "هندي"),
            ShoofAPI.Category(id: 226, name: "تركي"),
            ShoofAPI.Category(id: 221, name: "عربي"),
            ShoofAPI.Category(id: 219, name: "أسيوي"),
            ShoofAPI.Category(id: 228, name: "كارتون"),
            ShoofAPI.Category(id: 235, name: "وثائقي"),
            ShoofAPI.Category(id: 243, name: "برامج"),
            ShoofAPI.Category(id: 223, name: "أنمي"),
            ShoofAPI.Category(id: 0, name: " ")
        ]
    }
}
