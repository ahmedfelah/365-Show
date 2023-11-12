//
//  Realm.swift
//  Giganet
//
//  Created by Husam Aamer on 5/6/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

let realm = try! Realm()
struct RealmManager {
    static func isBookmarked (_ show:Show) -> Bool {
        return realm.objects(RmShow.self).filter("id = %@",show.id).count > 0
    }
    static func bookmarked (_ show:Show) -> RmShow? {
        return realm.objects(RmShow.self).filter("id = %@",show.id).first
    }
    static func countBookmarks () -> Int {
        return realm.objects(RmShow.self).count
    }
    /// Call to delete downloaded object from db and storage
    /// - Parameter rmItem: RmDownloadShow to be deleted
    static func deleteDownloadObject (_ rmItem:RDownload) throws -> Void {
        if let subtitleFile = rmItem.subtitle_filename {
            let subtitlePath = MZUtility.baseFilePath + "/\(subtitleFile)"
            if FileManager.default.fileExists(atPath: subtitlePath) {
                try FileManager.default.removeItem(atPath: subtitlePath)
            }
        }
        let videoPath = MZUtility.baseFilePath + "/\(rmItem.video_filename)"
        if FileManager.default.fileExists(atPath: videoPath) {
            try FileManager.default.removeItem(atPath: videoPath)
        }
        
        
        try realm.write {
            var shouldRemoveShow:RShow?
            
            if rmItem.isSeries {
                //Delete header if this is the last series episod
                //Delete show if this is the last series episod
                let relatedObjects = realm.objects(RDownload.self)
					.filter("show_id = %i",rmItem.show_id)
				
                if relatedObjects.count == 2 {
                    shouldRemoveShow = rmItem.show
                    realm.delete(relatedObjects)
                } else {
                    realm.delete(rmItem)
                }
            } else {
                shouldRemoveShow = rmItem.show
                realm.delete(rmItem)
            }
            
            //TODO: Delete files from disk
            if let show = shouldRemoveShow {
                realm.delete(show)
            }
        }
    }
	static func createDownloadObjectFor (_ show:ShoofAPI.Show,
										 and episode:ShoofAPI.Media.Episode? = nil ,
										 in season:ShoofAPI.Media.Season? = nil,
										 from source:CPlayerResolutionSource) throws -> RDownload {
        
        guard let videoUrlStr = source.source_file?.absoluteString else {
            throw RError(localizedTitle: "Error", localizedDescription: "لا يمكن تحميل هذا الملف بسبب صيغة المصدر", code: 500)
        }
        
        
        do {
            let dl = RDownload()
            
            try realm.write {
                
                //Add or Update if exist for sime reason
                let rShow = RShow(from: show)
                realm.add(rShow, update: .all)
                
                
                //Check if series header exist
                if let episode = episode {
                    let seriesHeaderExist = realm.objects(RDownload.self)
                    .filter("isSeriesHeader = true and show_id = %i",show.id).count != 0
                    if !seriesHeaderExist {
                        let rmSeriesHeader = RDownload()
                        rmSeriesHeader.video_filename = "fake_\(show.id)"
                        rmSeriesHeader.show_id        = show.id
                        rmSeriesHeader.isSeriesHeader = true
                        rmSeriesHeader.isSeries       = true
                        rmSeriesHeader.show           = rShow
                        rmSeriesHeader.order          = sortColumn(show,
																   and : episode,
																   in : season,
																   isSeariesHeader : true)
                        rmSeriesHeader.status         = DownloadStatus.downloaded.rawValue
                        realm.add(rmSeriesHeader)
                    }
                }
                
                //Download object
                dl.show = rShow
                dl.show_id = rShow.id
                dl.resolution = source.title
                
                var videoFileName = ["vid"]
                videoFileName.append("\(rShow.id)")
                if let series_id = episode?.id {
                    videoFileName.append("\(series_id)")
                }
                
                if let episode = episode {
                    dl.episode_id = episode.id
                    dl.series_title = "\(episode.number)"
                    dl.isSeries = true
					dl.series_season_title = "\(season?.number ?? 0)"
                    dl.series_season_id = season?.id
                } else {
                    dl.isSeries = false
                }
                
                dl.video_filename = videoFileName.joined(separator: "_") + ".mp4"
                dl.video_url = videoUrlStr
                
				var subtitleUrl:URL?
				var subtitle_filename:String?
				
				if let media = show.media {
					
					// If series
					if let episode = episode, let subtitle = episode.subtitles?.first?.path {
						
						subtitleUrl       = subtitle
						subtitle_filename = "sub_\(episode.id).srt"
						
					} else if case ShoofAPI.Media.movie(let movie) = media {
						subtitleUrl       = movie.subtitles?.first?.path
						subtitle_filename = "sub_\(rShow.id).srt"
					}
					
					dl.subtitle_url      = subtitleUrl?.absoluteString
					dl.subtitle_filename = subtitle_filename
					
				}
				
                dl.order = sortColumn(show, and: episode, in: season, isSeariesHeader: false)
                realm.add(dl, update: .all)
            }
            return dl
        } catch {
            //fatalError("Realm write error _ reason: \(error)")
            throw(error)
        }
    }
	fileprivate static func sortColumn (_ show:ShoofAPI.Show,
										and episode:ShoofAPI.Media.Episode? = nil,
										in season:ShoofAPI.Media.Season? = nil,
										isSeariesHeader:Bool? = nil) -> String {
        var str = "\(show.id)"
        if let episode = episode,
            let season = season,
            let isSeariesHeader = isSeariesHeader {
            str += isSeariesHeader ? "_0" : "_1"
			str += "_\(season.number)_\(episode.id)"
        }
        return str
    }
    
}

extension RealmManager {
    //////////////////////////////////////////////
    // Write to database
    //////////////////////////////////////////////
	static func watchingStarted (_ movie:ShoofAPI.Show) -> RContinueShow {
        return userStartedWatching(movie, with: nil)
    }
    static func watchingStarted (_ series:ShoofAPI.Show,
                                 with episode:ShoofAPI.Media.Episode, season: ShoofAPI.Media.Season) -> RContinueShow
    {
		return userStartedWatching(series, with: episode, season: season)
    }
    fileprivate static func userStartedWatching (_ show:ShoofAPI.Show,  with episode:ShoofAPI.Media.Episode? = nil, season: ShoofAPI.Media.Season? = nil) -> RContinueShow
    {
        do {
            
            if let rm = rmContinueForPlayingShow(with: show.id, with: episode) {
                try realm.write {
                    rm.setPlayingDate()
                }
				
				try registerRmRecent(for: show, with: rm)
				
                return rm
            }
			
            let rm              = RContinueShow()
            rm.id               = show.id
            rm.episode_id	 	= episode?.id
            rm.seasonID = season?.id
            
			try realm.write({
				realm.add(rm)
			})
			
            try registerRmRecent(for: show, with: rm)
            
			
            return rm
        } catch {
            fatalError("Realm write error _ reason: \(error)")
        }
    }

	fileprivate static func registerRmRecent(for show:ShoofAPI.Show, with rmContinueShow:RContinueShow) throws {
        let rmRecentShow = RRecentShow(with: show, rmContinueObject: rmContinueShow)
        try realm.write {
            realm.add(rmRecentShow, update: .modified)
        }
        NotificationCenter.default.post(name: Notification.Name("reloadHistoryLocalData"),
                                        object: nil)
    }
    
    static func updateWatchingProgress (for continueShow:RContinueShow,
                                      leftAt time:Int,
                                      and percentage:Float)
    {
        do {
            try realm.write {
                continueShow.left_at = time
                continueShow.left_at_percentage = percentage
            }
        } catch {
            fatalError("Realm write error _ reason: \(error)")
            //Crashlytics.sharedInstance().recordCustomExceptionName("Realm write error", reason: "\(error)", frameArray: [])
        }
    }
    //////////////////////////////////////////
    // Read from database
    //////////////////////////////////////////
    static func rmContinueForPlayingShow(
        with showId:String,
		with episode:ShoofAPI.Media.Episode? = nil) -> RContinueShow?
    {
        //let type = show.type
        var result = realm
            .objects(RContinueShow.self)
            .where {
			$0.id.equals(showId)
		}
		
		if let episode = episode {
			result = result.where({
				$0.episode_id.equals(episode.id)
			})
		}
		
        return result.sorted(byKeyPath: "playing_date", ascending: false)
            .first
    }
    static func rmContinueForLastLeftShow(
        with show_id:String) -> RContinueShow?
    {
        //let type = show.type
        return realm
            .objects(RContinueShow.self)
            .filter("id = %@",show_id)
            .sorted(byKeyPath: "playing_date", ascending: false)
            .first
    }
    
    static func recentShowsList() -> Results<RRecentShow>?
    {
        //let type = show.type
        return realm
            .objects(RRecentShow.self)
            .sorted(byKeyPath: "rmContinue.playing_date", ascending: false)
    }
    
    static func deleteRecentShowObject (for movieId: String? = nil) throws -> Void {
        try realm.write {
            if let id = movieId {
                let objectsToDelete = realm.objects(RRecentShow.self).filter { $0.id == id }
               realm.delete(objectsToDelete)
           } else {
                let objectsToDelete = realm.objects(RRecentShow.self)
                realm.delete(objectsToDelete)
            }
        }
    }
    
    static func deleteRecentShowObject (_ object: RRecentShow) throws -> Void {
        try realm.write {
            realm.delete(object)
        }
    }
}
