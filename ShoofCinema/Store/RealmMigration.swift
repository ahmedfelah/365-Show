//
//  RealmMigration.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 4/8/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

extension RealmManager {
	static func migrateRmDownloadsToRDownloads () throws {
		let rmObjects = realm.objects(RmDownloadShow.self).sorted(by: ["order"])
		
		var prevSeriesHeader:RmDownloadShow?
		for rmObj in rmObjects {
			// Cache series header for next loops
			if rmObj.isSeriesHeader {
				prevSeriesHeader = rmObj
				continue
			}
			
			
			switch rmObj.statusEnum {
			case .downloaded:
				
				let rDownload = RDownload()
				if let show = rmObj.show {
					
					// Migrate Show
					let existedShow = realm.object(ofType: RShow.self, forPrimaryKey: String(describing: show.id))
					if existedShow != nil {
						rDownload.show = existedShow
					} else {
						let rShow = RShow.init(from: show)
						try realm.write {
							realm.add(rShow)
							rDownload.show = rShow
						}
					}
					
					rDownload.show_id = String(describing: rmObj.show_id)
					
					rDownload.isSeries            = rmObj.isSeries
					rDownload.isSeriesHeader      = rmObj.isSeriesHeader
					rDownload.episode_id          = String(describing       : rmObj.series_id)
					rDownload.series_title        = rmObj.series_title
					rDownload.series_season_title = rmObj.series_season_title
					rDownload.series_season_id    = String(describing : rmObj.series_season)
					rDownload.video_filename      = rmObj.video_filename
					rDownload.video_url           = rmObj.video_url
					rDownload.subtitle_url        = rmObj.subtitle_url
					rDownload.subtitle_filename   = rmObj.subtitle_filename
					rDownload.subtitle_downloaded = rmObj.subtitle_downloaded
					rDownload.resolution          = rmObj.resolution
					rDownload.status              = rmObj.status
					rDownload.file_size           = rmObj.file_size
					rDownload.file_unit           = rmObj.file_unit
					rDownload.downloaded_size     = rmObj.downloaded_size
					rDownload.downloaded_unit     = rmObj.downloaded_unit
					rDownload.progress            = rmObj.progress
					rDownload.order               = rmObj.order
					
					
					try realm.write {
						
						// Check if object will be saved then sereis
						// header should also be saved
						if let header = prevSeriesHeader {
							let rDownloadHeader = RDownload()
							rDownloadHeader.video_filename = header.video_filename
							rDownloadHeader.show_id = rDownload.show_id
							rDownloadHeader.show = rDownload.show
							rDownloadHeader.isSeriesHeader = header.isSeriesHeader
							rDownloadHeader.isSeries = header.isSeries
							rDownloadHeader.status = header.status
							rDownloadHeader.file_size = header.file_size
							rDownloadHeader.file_unit = header.file_unit
							rDownloadHeader.downloaded_size = header.downloaded_size
							rDownloadHeader.downloaded_unit = header.downloaded_unit
							rDownloadHeader.progress = header.progress
							rDownloadHeader.order = header.order
							rDownloadHeader.creation_date = header.creation_date
							realm.add(rDownloadHeader)
							realm.delete(header)
							// Ok don't add it again in the next loop
							prevSeriesHeader = nil
						}
						
						realm.add(rDownload)
						
						realm.delete(rmObj)
					}
				}
				
			default:
				continue
			}
		}
		
		try realm.write {
			realm.delete(rmObjects)
		}
	}
}
