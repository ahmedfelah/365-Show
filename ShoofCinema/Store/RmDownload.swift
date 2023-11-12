//
//  RmDownloadShow.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/6/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

class RDownload:Object, Identifiable {
    
    //Show id
	@Persisted(indexed:true) var show_id:String
	@Persisted var show:RShow?
    
    //enum ShowType raw value
	@Persisted var isSeries:Bool = false
	@Persisted var isSeriesHeader:Bool = false
    //Series id if the show is series
	@Persisted(indexed:true) var episode_id:String?
	@Persisted var series_title:String?
	@Persisted var series_season_title:String?
	@Persisted var series_season_id:String?
    
	@Persisted(primaryKey: true) var video_filename:String = ""
	@Persisted var video_url : String = ""
	@Persisted var subtitle_url : String?
	@Persisted(indexed:true) var subtitle_filename:String?
	@Persisted var subtitle_downloaded:Bool = false

	@Persisted var resolution : String = ""
    //Time in seconds at which movie/episode was left
	@Persisted var status:Int = 0 //in KB
	@Persisted var file_size:Float = 0
	@Persisted var file_unit:String = "KB"
	@Persisted var downloaded_size:Float = 0
	@Persisted var downloaded_unit:String = "KB"
	@Persisted var progress:Float = 0
    
	@Persisted var order:String? = nil
    
    //Creation date
	@Persisted(indexed:true) var creation_date = Date()
    
    var statusEnum:DownloadStatus {
        get {
            return DownloadStatus(rawValue: status) ?? .unknown
        }
    }
    
    var formattedFileSize:String {
        let str = NSString(format: "%@ %@", DownloadsVC.formatter.string(from: NSNumber(value: file_size)) ?? "?", file_unit)
        return str as String
    }
    
    override init() {
        super.init()
    }
    
    init(from rmDownloadShow: RmDownloadShow) {
        super.init()
        
        self.show_id = String(rmDownloadShow.show_id)
        if let rmShow = rmDownloadShow.show {
            self.show = RShow(from: rmShow)
        }
        self.isSeries = rmDownloadShow.isSeries
        self.isSeriesHeader = rmDownloadShow.isSeriesHeader
        if let series_id = rmDownloadShow.series_id.value {
            self.episode_id = String(series_id)
        }
        self.series_title = rmDownloadShow.series_title
        self.series_season_title = rmDownloadShow.series_season_title
        if let seasonID = rmDownloadShow.series_season.value {
            self.series_season_id = String(seasonID)
        }
        self.video_filename = rmDownloadShow.video_filename
        self.video_url = rmDownloadShow.video_url
        self.subtitle_url = rmDownloadShow.subtitle_url
        self.subtitle_filename = rmDownloadShow.subtitle_filename
        self.subtitle_downloaded = rmDownloadShow.subtitle_downloaded
        self.resolution = rmDownloadShow.resolution
        self.status = rmDownloadShow.status
        self.file_size = rmDownloadShow.file_size
        self.file_unit = rmDownloadShow.file_unit
        self.downloaded_size = rmDownloadShow.downloaded_size
        self.downloaded_unit = rmDownloadShow.downloaded_unit
        self.progress = rmDownloadShow.progress
        self.order = rmDownloadShow.order
        self.creation_date = rmDownloadShow.creation_date
    }
}

extension RDownload {
    func asShoofShow() -> ShoofAPI.Show? {
        guard var show = show?.asShoofShow() else {
            return nil
        }
        
//        let fileURL = URL(string: "file://" + MZUtility.baseFilePath + "/\(video_filename)")
//        let resolution = ShoofAPI.Media.Resolution.other("📲 \(resolution)")
//
//		var subtitles = [ShoofAPI.Media.Subtitle]()
//
//        if let subtitleFileName = subtitle_url {
//            let subtitleURL = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitleFileName)")!
//			subtitles.append(.init(type: 1, path: subtitleURL))
//        }
		
		if isSeries {
			
			// Build seasons array
			guard let rItems = realm?.objects(RDownload.self).filter("show.id = %@ and status = %i and isSeriesHeader = false",show_id, DownloadStatus.downloaded.rawValue) else {
				return nil
			}
			
			var seasons = [ShoofAPI.Media.Season]()
			let groups: Dictionary<String, [Results<RDownload>.Element]> = Dictionary(grouping: rItems, by: {
				$0.series_season_id ?? "Any"
			})
			
			for (seasonId, rDownload) in groups {
				let episodes:[ShoofAPI.Media.Episode] = rDownload.compactMap({
					ShoofAPI.Media.Episode.init(
						id:$0.episode_id ?? "any",
						number:Int($0.series_title ?? "1") ?? 1,
						files: [],
						subtitles:[] , skips:[],
						familyModTimelines:[])
				})
				
				guard let seasonTitle = rDownload.first?.series_season_title else {
					continue
				}
				
				let season = ShoofAPI.Media.Season(
					id: seasonId,
					number: Int(seasonTitle) ?? 1,
					description: nil,
					episodes: episodes,
					numberOfEpisodes: episodes.count
				)
				
				seasons.append(season)
			}
			
			show.media = .series(seasons: seasons.sorted(by: {
				$0.number < $1.number
			}))
			
		} else {
			let shoofMovie = ShoofAPI.Media.Movie(files: [], subtitles: [], skips: [], familyModTimelines: [])
			show.media = .movie(shoofMovie)
		}
        return show
    }
    
    /*
    var videoSource : CPlayerResolutionSource? {
        if let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(video_filename)") {
            let localSource = CPlayerResolutionSource(title: "📲 \(resolution)", nil, localUrl)
            return localSource
        }
        return nil
    }
    var srtSource : CPlayerSubtitleSource? {
        if let subtitle_url = subtitle_url,
            let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitle_url)") {
            let localSource = CPlayerSubtitleSource(title: "📲 Arabic", source: localUrl)
            return localSource
        }
        return nil
    }
     */
}

// MARK: - Old RmDownloadShow

class RmDownloadShow:Object {
    
    //Show id
    @objc dynamic var show_id:Int = 0
    @objc dynamic var show:RmShow?
    
    //enum ShowType raw value
    @objc dynamic var isSeries:Bool = false
    @objc dynamic var isSeriesHeader:Bool = false
    //Series id if the show is series
    dynamic var series_id  = RealmProperty<Int?>()
    @objc dynamic var series_title:String?
    @objc dynamic var series_season_title:String?
    dynamic var series_season = RealmProperty<Int?>()
    
    @objc dynamic var video_filename:String = ""
    @objc dynamic var video_url : String = ""
    @objc dynamic var subtitle_url : String?
    @objc dynamic var subtitle_filename:String?
    @objc dynamic var subtitle_downloaded:Bool = false

    @objc dynamic var resolution : String = ""
    //Time in seconds at which movie/episode was left
    @objc dynamic var status:Int = 0 //in KB
    @objc dynamic var file_size:Float = 0
    @objc dynamic var file_unit:String = "KB"
    @objc dynamic var downloaded_size:Float = 0
    @objc dynamic var downloaded_unit:String = "KB"
    @objc dynamic var progress:Float = 0
    
    @objc dynamic var order:String? = nil
    
    //Creation date
    @objc dynamic var creation_date = Date()
    
    override class func primaryKey() -> String? {
        return "video_filename"
    }
    override static func indexedProperties() -> [String] {
        return ["show_id","series_id","creation_date","video_filename","subtitle_filename"]
    }
    
    var statusEnum:DownloadStatus {
        get {
            return DownloadStatus(rawValue: status) ?? .unknown
        }
    }
    
    var formattedFileSize:String {
        let str = NSString(format: "%@ %@", DownloadsVC.formatter.string(from: NSNumber(value: file_size)) ?? "?", file_unit)
        return str as String
    }
}

extension RmDownloadShow {
    var videoSource : CPlayerResolutionSource? {
        if let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(video_filename)") {
            let localSource = CPlayerResolutionSource(title: "📲 \(resolution)", nil, localUrl)
            return localSource
        }
        return nil
    }
    var srtSource : CPlayerSubtitleSource? {
        if let subtitle_url = subtitle_url,
            let localUrl = URL(string: "file://" + MZUtility.baseFilePath + "/\(subtitle_url)") {
            let localSource = CPlayerSubtitleSource(title: "📲 Arabic", source: localUrl)
            return localSource
        }
        return nil
    }
}
