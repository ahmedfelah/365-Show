//
//  Movie.swift
//  Giganet
//
//  Created by Husam Aamer on 4/4/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

struct Show : Codable {
    
    var isSeries:Bool
    var id:Int
    var altTitle:String?
    var story:String?
    var stars :[String]?
    var trailer :String?
    var directors :[String]?
    var writers :[String]?
    var imdb_id :String?
    var views:Int = 0
    var token:String
    var categoryStr:String
    var runtime:Int
    var isFaved :Bool = false
    var poster:String?
    public var slider : URL?
    var title:String
    var genres : [String]?
    var mpaa:String?
    var year:Int?
    var rating:Float?
    var seasons:[Season]? = nil
    var actors : [Artist]?
    
    
    public var getTitle : String {
        if Language.isEnglish() {
            return self.title.capitalized
        } else {
            if let arTitle = altTitle,arTitle != "" {
                return  arTitle
            } else {
                return self.title.capitalized
            }
        }
    }
    
    public var getGenres : String {
        if let g = self.genres {
            return g.joined(separator: ", ")
        } else {
            return NSLocalizedString("noGenre", comment: "")
        }
    }
    
    public var getYear : String {
        if let year = self.year {
            return "\(year)"
        } else {
            return NSLocalizedString("na", comment: "")
        }
    }
    
    public var getMapaaRaging : String {
        if let m = self.mpaa , m != "", m != "Not Rated" {
            return m.uppercased()
        } else {
            return NSLocalizedString("na", comment: "")
        }
    }
    
    public var getViews : String {
        return "\(self.views.getFormattedViewsNumber())"
    }
    
    public var getImbdRating : String {
        if let r = rating , r != 0 {
            
            return r.getFormattedIMDBRating()
        } else {
            return NSLocalizedString("na", comment: "")
        }
    }
    
    public var getDirectors : String {
        if let d = self.directors , !d.isEmpty  {
            return d.joined(separator: ", ")
        } else {
            return NSLocalizedString("noContent", comment: "")
        }
    }
    
    public var getWrites : String {
        if let w = self.writers , !w.isEmpty {
            return w.joined(separator: ", ")
        } else {
            return NSLocalizedString("noContent", comment: "")
        }
    }
    
    public var getCast : String {
        if let s = self.stars , !s.isEmpty {
            return s.joined(separator: ", ")
        } else {
            return NSLocalizedString("noContent", comment: "")
        }
    }
    
    public var getPosterUrl : URL? {
        let baseUrl = "//cinema.shoofnetwork.net"
        guard var mString = poster else { return nil }
        mString = mString.components(separatedBy: "?")[0]
        if !mString.contains(baseUrl) {
            mString = baseUrl + mString
        }
        return URL(string: mString)
    }
    
    public var getSliderUrl : URL? {
        return slider
    }


    var resolutions:[CPlayerResolutionSource]?
    
    var srt:URL?
    
    var comments:[Comment]?
    
    
    // MARK: - LOAD
    init?(from json:JSON) {
        if let idInt     = json["movie_id"].int, let _isSeries = json["isSeries"].int {
            id           = idInt
            isSeries     = _isSeries == 1
        } else {
            return nil
        }
    
        if let stringToken = json["movie_token"].string {
            self.token   = stringToken
        } else if let intToken = json["movie_token"].int {
            self.token   = "\(intToken)"
        } else {
            return nil
        }
        
        print(json)
        
        title = json["movie_title"].string ?? ""
        altTitle  = json["movie_alt_title"].string ?? ""
        poster = json["movie_poster"].string
        slider = json["movie_slider"].url
        year  = json["movie_year"].int
        let stringRating = json["movie_rate"].string ?? ""
        rating = (stringRating as NSString).floatValue
        genres = json["movie_genres"].arrayObject?.compactMap({$0 as? String})
        trailer = json["movie_trailer"].string
        runtime = json["movie_runtime"].intValue
        imdb_id  = json["movie_imdb_id"].string
        views = json["movie_watched"].intValue
        mpaa = json["mpaa"]["mpaa_name"].string
        categoryStr = json["category"]["category_name"].string ?? "غير معروف"
        story = json["movie_des"].string
        directors = json["movie_directors"].arrayObject as? [String]
        writers = json["movie_writers"].arrayObject as? [String]
        stars = json["movie_stars"].arrayObject as? [String]

    }
    
    mutating func setDetailsValues (from json:JSON) {
        
        isFaved = json["isFav"].intValue == 1
        //In favorite for example we didn't get category in index request
        categoryStr = json["category"]["category_name"].string ?? "غير معروف"
        
        comments = json["comments"].arrayValue.compactMap({Comment(from:$0)})
        
        if json["isSeries"].boolValue, let seasons = json["seasons"].array {
            self.seasons = seasons.compactMap({Season(from: $0)})//.filter({$0 != nil})
        } else {
            resolutions = Show.videoSources(from: json)
        }
        
        if let cast = json["movie_cast"].array {
            self.actors = cast.compactMap { Artist(json: $0) }
        }
        
        if let srtStr = json["movie_subtitle"].string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            //if srtStr.hasPrefix("http:") {
            //    srtStr = srtStr.replacingOccurrences(of: "http:", with: "https:")
            //}
            
            if let _srt = URL(string: srtStr) {
                self.srt    = _srt
            }
        }
    }
    
    static func videoSources(from json:JSON) -> [CPlayerResolutionSource] {
        var resolutions = [CPlayerResolutionSource]()
        
        /**
         #Example
         "files": [
           {
             "m3u8_url": "http://cinema.supercellnetwork.com:8081/vod/f1a21737-0a5c-4dec-8bca-7bd4b431cb26/SZm0dAKEr9f6HYs/,SZm0dAKEr9f6HYs_1080.mp4,SZm0dAKEr9f6HYs.srt,.urlset/master.m3u8",
             "type": "1080",
             "url": "http://cinema.supercellnetwork.com/f1a21737-0a5c-4dec-8bca-7bd4b431cb26/SZm0dAKEr9f6HYs/SZm0dAKEr9f6HYs_1080.mp4"
           },
           {
             "m3u8_url": "http://cinema.supercellnetwork.com:8081/vod/f1a21737-0a5c-4dec-8bca-7bd4b431cb26/SZm0dAKEr9f6HYs/,SZm0dAKEr9f6HYs_1080.mp4,SZm0dAKEr9f6HYs.srt,.urlset/master.m3u8",
             "type": "720",
             "url": "http://cinema.supercellnetwork.com/f1a21737-0a5c-4dec-8bca-7bd4b431cb26/SZm0dAKEr9f6HYs/SZm0dAKEr9f6HYs_1080.mp4"
           }
         ],
         */
        if let adaptiveStr = json["video_adaptive"].string?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let adaptiveUrl = URL(string: adaptiveStr) {
            resolutions.append(CPlayerResolutionSource(title: "Auto", adaptiveUrl))
        }
        for fileJson in json["files"].arrayValue {
            let fileTitle = fileJson["type"].string ?? "No title"
            
            var m3u8_url :URL?
            //.replacingOccurrences(of: "http://cinema.supercellnetwork.com", with: "http://93.191.114.6")
            if let urlStr = fileJson["m3u8_url"].string, let url = URL(string: urlStr) {
                m3u8_url = url
            }
            
            var mp4_url :URL?
            //.replacingOccurrences(of: "http://cinema.supercellnetwork.com", with: "http://93.191.114.6")
            if let urlStr = fileJson["url"].string, let url = URL(string: urlStr) {
                mp4_url = url
            }
            
            if m3u8_url == nil && mp4_url == nil {
                continue
            }
            
            resolutions.append(CPlayerResolutionSource(title: fileTitle, m3u8_url, mp4_url))
        }
        
        if isDebugMode {
            resolutions.append(CPlayerResolutionSource(
                title: "test",nil,
                URL(string: "http://mirrors.standaloneinstaller.com/video-sample/small.mp4")))
            resolutions.append(CPlayerResolutionSource(
                title: "test 2",nil,
                URL(string: "http://mirrors.standaloneinstaller.com/video-sample/DLP_PART_2_768k.mp4")))
            resolutions.append(CPlayerResolutionSource(
            title: "fake file",nil,
            URL(string: "http://mirrors.standaloneinstaller.com/fake.mp4")))
        }
        
        //If there are adaptive (Auto) and another url, then keep only the auto url because they are the same resolution
        if resolutions.count == 2 && resolutions.first?.title == "Auto" {
            return [resolutions[1]]
        } else {
            return resolutions
        }
    }
}

extension Timeline {
    init(timeline: ShoofAPI.Media.Timeline) {
        self.init(id: timeline.id, startTime: timeline.startTime, endTime: timeline.endTime)
    }
}

extension ShoofAPI.Media.Movie {
    var allTimelines: [ShoofAPI.Media.Timeline] {
        familyModTimelines + skips
    }
}

extension ShoofAPI.Media.Episode {
    var allTimelines: [ShoofAPI.Media.Timeline] {
        familyModTimelines + skips
    }
}

extension CPlayerSource {
    init?(show: ShoofAPI.Show) {
        guard case .movie(let movie) = show.media else {
            return nil
        }
        
        var sources = movie.files.map { CPlayerResolutionSource(title: $0.resolution.description, $0.url) }
        let metadata = CPlayerMetadata(title: show.title, image: show.posterURL, description: nil)
        var subtitles = movie.subtitles?.map { CPlayerSubtitleSource(title: String($0.type), source: $0.path) }
        let timelines = movie.allTimelines.map(Timeline.init)
        
		// Add Local Sources (Downloaded Show and Subtitle)
		if let rmItem = realm.objects(RDownload.self).filter("show.id = %@ and status = %i",show.id,DownloadStatus.downloaded.rawValue).first {
			
			if let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(rmItem.video_filename)") {
				let localSource = CPlayerResolutionSource(title: "↓ \(rmItem.resolution)", nil, localUrl)
				sources.insert(localSource, at: 0)
			}
			
			if let subtitleFile = rmItem.subtitle_filename,
			   let localSrt = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitleFile)") {
				let localSource = CPlayerSubtitleSource(title: "عربي ↓", source: localSrt)
				subtitles?.insert(localSource, at: 0)
			}
		}
		
        self.init(resolutions: sources, subtitles: subtitles, metadata: metadata, timelines: timelines)
    }
    
    init(episode: ShoofAPI.Media.Episode, in show: ShoofAPI.Show) {
		var sources = episode.files.map { CPlayerResolutionSource(title: $0.resolution.description, $0.url) }
        let metadata = CPlayerMetadata(title: String(episode.number), image: show.posterURL, description: nil)
        var subtitles = episode.subtitles?.map { CPlayerSubtitleSource(title: String($0.type), source: $0.path) }
        let timelines = episode.allTimelines.map(Timeline.init)
		
		// Add Local Sources (Downloaded Episode and Subtitle)
		if let rmItem = realm.objects(RDownload.self)
			.filter("episode_id = %@ and status = %i ", episode.id, DownloadStatus.downloaded.rawValue).first {
			if let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(rmItem.video_filename)") {
				let localSource = CPlayerResolutionSource(title: "↓ \(rmItem.resolution)", nil, localUrl)
				sources.insert(localSource, at: 0)
			}
			
			if let subtitleFile = rmItem.subtitle_filename,
			   let localSrt = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitleFile)") {
				let localSource = CPlayerSubtitleSource(title: "عربي ↓", source: localSrt)
				subtitles?.insert(localSource, at: 0)
			}
		}
		
        self.init(resolutions: sources, subtitles: subtitles, metadata: metadata, timelines: timelines)
    }
}
