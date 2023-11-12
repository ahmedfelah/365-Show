//
//  HomeSections.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/26/21.
//  Copyright © 2021 AppChief. All rights reserved.
//


import SwiftyJSON
import Foundation

struct HomeData {
    let sections : [HomeSection]
    
    init(json : JSON) {
//        sections = json.array?.compactMap { HomeSection(json: $0)} ?? []
        sections = []
    }
}

public enum SectionStyle : String {
    case defaullt
    case vertical
    case horizontal
    case history
}

enum HomeSectionList {
    case show(ShoofAPI.Show)
    case rmRecentShow(RRecentShow)
    
    var show: ShoofAPI.Show {
        switch self {
            case .show(let show):
                return show
            case .rmRecentShow(let rmRecentShow):
                return rmRecentShow.asShoofShow()
        }
    }
}

struct HomeSection  {
        
    var title : String
    var category : Int
    var tag : String
    var tagID : Int
    var style : SectionStyle
    var showsList : [HomeSectionList]
    //var action: ShoofAPI.Action

//    init (json : JSON) {
//        self.title = json["title"].string ?? json["category_name"].string ?? json["name_ar"].string ?? ""
//        let category = json["category"].string ?? String(json["category_id"].int ?? -1)
//        self.category = Int(category) ?? -1
//        self.tag = json["tag"].string ?? ""
//        self.tagID = json["id"].int ?? 0
//        self.style = SectionStyle(rawValue: json["style"].string ?? "") ?? .defaullt
//        let showsData = json["data"]["data"].array
//        self.showsList = showsData?.compactMap {
//            if let show = Show(from: $0) {
//                return .show(show)
//            }
//            return nil
//        } ?? []
//    }
//    
    init(title: String, category: Int, tag: String, tagID: Int, style: SectionStyle, showsList: [HomeSectionList]) {
        self.title = title
        self.category = category
        self.tag = tag
        self.tagID = tagID
        self.style = style
        self.showsList = showsList
        //self.action = action
    }

}

struct CategoryShowsCM : Codable {
    
    let from : Int
    let to : Int
    let total : Int
    let current_page : Int
    let last_page : Int?
    let per_page: Int
    let first_page_url : String?
    let next_page_url : String?
    let prev_page_url : String?
    let last_page_url : String?
    let path : String?
    let data : [ShowDataCM]
    
}









// MARK: - MovieElement
struct HomeSectionCM: Codable {
    let title, category, tag, style: String
    let data: SectionDataCM
}

// MARK: - DataClass
struct SectionDataCM: Codable {
    let current_page: Int
    let data: [ShowDataCM]
    let first_page_url: String
    let from, last_page: Int
    let last_page_url, next_page_url, path: String
    let per_page: Int
    let prev_page_url: String?
    let to, total: Int

}





//extension Channel {
//    func asPlayerSource () -> CPlayerSource? {
//        let url = streamURL
//        var resolutions = [CPlayerResolutionSource]()
//        resolutions.append(CPlayerResolutionSource(title:"Auto",url))
//        let metadata = CPlayerMetadata(title: name, image: image, description: nil)
//        return CPlayerSource(resolutions: resolutions, metadata: metadata)
//    }
//}
//extension Episod {
//    func asPlayerSource () -> CPlayerSource? {
//
//        var sources = resolutions
//
//        //Prepare subtitles
//        var subs:[CPlayerSubtitleSource]?
//
//        // Srt is not allowed in supercell, because we use m3u8
//        if let srt = srt {
//            subs = [CPlayerSubtitleSource(title: "Arabic", source: srt)]
//        }
//
//        if let rmItem = realm.objects(RmDownloadShow.self).filter("series_id = %i and status = %i ",self.series_id, DownloadStatus.downloaded.rawValue).first {
//            if let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(rmItem.video_filename)") {
//                let localSource = CPlayerResolutionSource(title: "↓ \(rmItem.resolution)", nil, localUrl)
//                sources.insert(localSource, at: 0)
//            }
//
//            if let subtitleFile = rmItem.subtitle_filename,
//                let localSrt = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitleFile)") {
//                let localSource = CPlayerSubtitleSource(title: "عربي ↓", source: localSrt)
//                if subs == nil {subs = []}
//                subs?.insert(localSource, at: 0)
//            }
//        }
//
//        let metadata = CPlayerMetadata(title: title)
//        return CPlayerSource(resolutions: sources, subtitles: subs, metadata: metadata)
//    }
//}


// MARK: - Category
struct CategoryCM: Codable {
    let category_series: Int
    let category_name: String

}

// MARK: - MPAA
struct MPAACM: Codable {
    let mpaa_name: String

}

// MARK: - User
struct UserCM: Codable {
    let user_name: String
    let user_img: String

}


