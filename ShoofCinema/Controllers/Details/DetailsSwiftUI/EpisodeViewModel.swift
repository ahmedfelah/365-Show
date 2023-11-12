//
//  EpisodeViewModel.swift
//  ShoofCinema
//
//  Created by mac on 5/4/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit


class EpisodeViewModel: ObservableObject {
    
    
    @Published var progress: Float = 0.0
    @Published var downloadStatus = DownloadStatus.unknown
    
    let episodeId: String
    
    init(episodeId: String, progress: Float = 0.0, downloadStatus: DownloadStatus = .unknown) {
        self.episodeId = episodeId
        self.progress = progress
        self.downloadStatus = downloadStatus
        
        if !isOutsideDomain {
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
    }
    
    
    
}


extension EpisodeViewModel: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        
        if let episodeId = item.episode_id, episodeId == self.episodeId {
            
            self.progress = downloadModel.progress
        }
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        if let episodeId = item.episode_id, episodeId == self.episodeId   {
            self.downloadStatus = .unknown
        }
    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
        if let episodeId = item.episode_id, episodeId == self.episodeId  {
            self.downloadStatus = .unknown
        }
        
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        /// Update cell and refresh `downloadingIndexes` order
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        if let episodeId = item.episode_id, episodeId == self.episodeId  {
            self.downloadStatus = item.statusEnum
            print("status download :", item.statusEnum)
        }
    }
}
