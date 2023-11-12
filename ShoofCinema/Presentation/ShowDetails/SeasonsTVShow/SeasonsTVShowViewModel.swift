//
//  SeasonsTVShowViewModel.swift
//  ShoofCinema
//
//  Created by mac on 8/23/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

class SeasonsTVShowViewModel: ObservableObject {
    
    @Published var episodes: [ShoofAPI.Media.Episode] = []
    @Published var seasonIndexSelected = 0
    @Published var episodeIndexSelected = 0
    @Published var hasNextPage: Bool = false
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    
    let videoPlayerViewController = VideoPlayerViewController()
    
    private var currentEpisodePage: Int = 1
    
    typealias EpisodeDownload = (EpisodeSeasonId: String, Progress: Float, Status: DownloadStatus)
    
    var rmEpisodes:Results<RDownload>!
    
    @Published var  downloading:[String : EpisodeDownload] = [:]

    
    var seasons: [ShoofAPI.Media.Season] {
        switch show.media {
        case .series(seasons: let seasons): return seasons
        default: return []
        }
    }
    
    var  limitEpisodes: [ShoofAPI.Media.Episode] {
        var limitEpisodes: [ShoofAPI.Media.Episode] = []
        var minIndex = episodeIndexSelected - 2
        minIndex = minIndex >= 0 ? minIndex : 0
    
        for index in minIndex ..< episodes.count {
            if index >= episodes.startIndex && index <= episodes.endIndex {
                limitEpisodes.append(episodes[index])
            }
            
            if limitEpisodes.count >= 5 {
                break
            }
        }
        
        
        return limitEpisodes
    }
    
    let show: ShoofAPI.Show
    
    
    init(show: ShoofAPI.Show) {
        self.show = show
        rmEpisodes = realm.objects(RDownload.self).filter("show_id = %i and isSeriesHeader = false", show.id)
        
        for  (_, episode) in rmEpisodes.enumerated() {
            downloading[episode.episode_id!] = (episode.series_season_id!, episode.progress, episode.statusEnum)
        }
        
        CurrentSeasonWithEpisode()
        
        if !isOutsideDomain {
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
    }
    
    func playEpisode(index: Int) {
        if index < episodes.count {
            self.episodeIndexSelected = index
            let seasonsView = SeasonsTV(show: show, seasonIndex: seasonIndexSelected, episodeIndex: episodeIndexSelected, episodes: episodes)
            videoPlayerViewController.playEpisode(show: show, currentEpisode: episodes[index], seasonsView: seasonsView) {
                
            }
        }
    }
    
    
    func fetchEpisodes() {
        guard !show.isMovie else {
            return
        }
        
        self.isLoading = true
        self.episodes = Array(repeating: ShoofAPI.Media.Episode.mock, count: 10)
        
        loadEpisodes(forSeasonWithID: seasons[seasonIndexSelected].id, pageNumber: 1) { [weak self] result in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                let response = try? result.get()
                let episodes : [ShoofAPI.Media.Episode] = response?.body ?? self.seasons[self.seasonIndexSelected].episodes ?? []// body or downloaded episodes
                self.episodeIndexSelected = 0
                
                if let continueShow = RealmManager.rmContinueForLastLeftShow(with: self.show.id),
                   let episodeID = continueShow.episode_id,
                   let index = episodes.firstIndex(where: { $0.id == episodeID }) {
                    self.episodeIndexSelected = index
                }
                
                self.episodes = episodes
                self.isLoading = false
                
            }
        }
    }
    
//    func playEpisode(index: Int) {
////        guard ShoofAPI.shared.isInNetwork else {
////            parentVC?.alert.unableToPlay()
////            return
////        }
//        
//        
//        if index < episodes.count {
//            self.episodeIndexSelected = index
//            let seasonsView = SeasonsTV(show: show, seasonIndex: seasonIndexSelected, episodeIndex: episodeIndexSelected, episodes: episodes)
//            tabbar?.playEpisode(show: show, currentEpisode: episodes[index], seasonsView: seasonsView) {
//                
//            }
//
//        }
//    }
    
    
    private func loadEpisodes(forSeasonWithID seasonID: String, pageNumber:  Int, completionHandler: @escaping
        (Result<ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]>.Response, Error>) -> Void) {
            ShoofAPI.shared.loadEpisodes(forSeasonWithID: seasonID, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
    func sources(episode: ShoofAPI.Media.Episode) -> [CPlayerResolutionSource] {
        let sources = episode.files.map { file in
            CPlayerResolutionSource(title: file.resolution.description, nil, file.url)
        }
        return sources.filter({$0.source_file != nil})
    }
    
    func download(episode: ShoofAPI.Media.Episode, source: CPlayerResolutionSource) {
        self.downloading[episode.id] = (episode.id, 0.0 , .downloading)
        let isAdded = DownloadManager.shared.download(episode, in: seasons[seasonIndexSelected], show: self.show, source: source) != nil
        if !isAdded {
            self.downloading.removeValue(forKey: episode.id)
        }
    }
    
    private func CurrentSeasonWithEpisode() {
        if case .series(let seasons) = show.media {
            if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
               let seasonID = continueShow.seasonID, let index = seasons.firstIndex(where: { $0.id == seasonID }) {
                seasonIndexSelected = index
                
                if let episodeID = continueShow.episode_id, let index = episodes.firstIndex(where: { $0.id == episodeID }) {
                    episodeIndexSelected = index
                }
            }
        }
    }
}

extension SeasonsTVShowViewModel: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        if let episodeID = item.episode_id {
            guard let seasonId = downloading[episodeID]?.EpisodeSeasonId,
                  seasonId == seasons[seasonIndexSelected].id else {
                return
            }
            
            guard let _ = downloading[episodeID] else {
                return
            }
            
            downloading[episodeID]? = (seasonId, downloadModel.progress, .downloading)
            
        }
    }

    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {

    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
        
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
       
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        guard let episodeId = item.episode_id,
              let status = downloading[episodeId]?.Status else
        {
            return
        }
        
        downloading[episodeId]?.Status = status
    }
}


extension ShoofAPI.Media.Episode {
    static let mock = ShoofAPI.Media.Episode(id: UUID().uuidString, number: 1, files: [], subtitles: nil, skips: [], familyModTimelines: [])
}
