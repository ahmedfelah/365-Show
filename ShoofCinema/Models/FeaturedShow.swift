//
//  Movie.swift
//  Giganet
//
//  Created by Husam Aamer on 4/4/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON


struct FeaturedShow:Codable {
    var id:Int
    var title:String
    var poster:URL?
    var type:ShowType
    
    
    init?(from json:[String:Any]) {
        if let idStr = json["id"] as? String, let idInt = Int(idStr) {
            id = idInt
        } else {
            return nil
        }
        title = json["title"] as? String ?? ""
        if let typeStr = json["type"] as? String,
            let typeInt = Int(typeStr) {
            type = ShowType(rawValue: typeInt) ?? .unknown
        } else {
            type = .unknown
        }
    }
}
