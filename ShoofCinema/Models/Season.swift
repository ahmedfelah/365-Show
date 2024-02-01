//
//  Movie.swift
//  Giganet
//
//  Created by Husam Aamer on 4/4/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON


struct Artist : Codable {
    let name : String
    let image : URL?
    
    
    init (json : JSON) {
        name = json["actor_name"].string ?? ""
        image = json["actor_image"].url
    }
}
struct Season:Codable {
    var title:String
    var id : Int
    var episods:[Episod]
    
    init (with id:Int, title:String, episodes:[Episod]) {
        self.id = id
        self.title = title
        self.episods = episodes
    }
    
    init?(from json:JSON) {
        title = json["movie_title"].stringValue
        id = json["series_season"].intValue

        var ep = [Episod]()
        for i in json["series"].arrayValue
        {
            if let episod = Episod(with: i)
            {
                ep.append(episod)
            }
        }
        episods = ep
        
        //Cancel season if it's empty
        if episods.count == 0 {
            return nil
        }
    }
    
}

struct Episod:Codable {
    var series_id:Int
    var title:String
    var resolutions : [CPlayerResolutionSource]
    var srt:URL?
    
    init (with id:Int, title:String, resolutions:[CPlayerResolutionSource], srt:URL?) {
        self.series_id = id
        self.title = title
        self.resolutions = resolutions
        self.srt = srt
    }
    
    init?(with json:JSON) {
        let sources = Show.videoSources(from: json)
        
        #if DEBUG
        print(json)
        print(sources)
        print("===========")
        #endif
        
        guard let series_id = json["series_id"].int ,
            let series_title = json["series_title"].string
            else
        {
            return nil
        }
        
        self.series_id = series_id
        self.title = series_title.replacingOccurrences(of: "الحلقة",
                                                       with: Localize("episodeName"))
        self.resolutions = sources
        
        if let srtStr = json["series_subtitle"].string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            //if srtStr.hasPrefix("http:") {
            //    srtStr = srtStr.replacingOccurrences(of: "http:", with: "https:")
            //}
            
            if let _srt = URL(string: srtStr) {
                self.srt    = _srt
            }
        }
    }
}
