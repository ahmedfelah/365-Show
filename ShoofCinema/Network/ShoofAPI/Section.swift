//
//  Section.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/26/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

extension ShoofAPI {
    struct Section {
        let title: String
        let style: Style?
        let id: String
        var shows: [Show]
        let actions: Action?
        
        enum Style : String, Decodable {
            case featured = "Featured"
            case vertical = "Vertical"
            case horizontal = "Horizontal"
            case special = "Special"
            case history = "History"
            
            init?(rawValue: String?) {
                switch rawValue {
                case "Featured", "featured": self = .featured
                case "Vertical", "vertical": self = .vertical
                case "Horizontal", "horizontal": self = .horizontal
                case "Special", "special" : self = .special
                case "History", "history": self = .history
                default: return nil
                }
            }
        }
    }
}



extension ShoofAPI.Section : Decodable {
    private enum CodingKeys : String, CodingKey {
        case style = "type"
        case shows, id, title, actions
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try? container.decodeIfPresent(Style.self, forKey: .style)
        self.title = try container.decode(String.self, forKey: .title)
        self.id = try container.decode(String.self, forKey: .id)
        self.shows = try container.decode([ShoofAPI.Show].self, forKey: .shows)
        self.actions = try? container.decode(ShoofAPI.Action.self, forKey: .actions)
    }
}




extension ShoofAPI.Section : Equatable {
    static func ==(lhs: ShoofAPI.Section, rhs: ShoofAPI.Section) -> Bool {
        return lhs.title == rhs.title && lhs.style == rhs.style && lhs.id == rhs.id && lhs.id == rhs.id
    }
}
