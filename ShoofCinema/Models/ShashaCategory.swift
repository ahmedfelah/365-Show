//
//  Movie.swift
//  Giganet
//
//  Created by Husam Aamer on 4/4/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

enum ShowType:Int,Codable {
    case movie, series ,unknown
    static func from(string:String) -> ShowType {
        if string == "movie" {
            return ShowType.movie
        }
        if string == "series" {
            return ShowType.series
        }
        return ShowType.unknown
    }
}
/*
 {
 "id": "0",
 "title": "Movies",
 "badquality": "0",
 "type": "0",
 "vorder": "1",
 "imdb": "0",
 "elcinema": "0",
 "parent": "0"
 }
 */


struct SCCategory {

    
    var id : Int
    var title : String
    var subcategories  : [SCCategory] = []
    
    init?(from json:JSON) {
        if let title = json["category_name"].string {
            self.title = title
        } else {
            return nil
        }
        
        if let idStr = json["category_id"].int {
            id = idStr
        } else {
            return nil
        }
        subcategories = json["sub_categories"].arrayValue.compactMap({SCCategory(from: $0)})
    }
    
    init(id: Int, title: String, subcategories: [SCCategory] = []) {
        self.id = id
        self.title = title
        self.subcategories = subcategories
    }
}
