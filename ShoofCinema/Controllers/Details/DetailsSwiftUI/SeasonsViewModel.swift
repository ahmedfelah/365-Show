//
//  SeasonsViewModel.swift
//  ShoofCinema
//
//  Created by mac on 4/27/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import RealmSwift


class SeasonsViewModel: ObservableObject {
    var show: ShoofAPI.Show
    
    var parentVC: RoundedTabBar?
    let tabbar: RoundedTabBar?
    
    var seasons: [ShoofAPI.Media.Season] {
        switch show.media {
        case .series(seasons: let seasons): return seasons
        default: return []
        }
    }
    
    @Published var episodes: [ShoofAPI.Media.Episode] = []
    @Published var seasonIndexSelected = 0
    @Published var episodeIndexSelected = 0
    @Published var hasNextPage: Bool = false
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    
    private var currentEpisodePage: Int = 1
    
    
    typealias EpisodeDownload = (EpisodeId: String, Progress: Float, Status: DownloadStatus)
    
    var rmEpisodes:Results<RDownload>!
    @Published var  downloading:[String : EpisodeDownload] = [:]
    
    let mockEpisode = ShoofAPI.Media.Episode(id: "", number: 1, files: [], subtitles: nil, skips: [], familyModTimelines: [])
    
    init(show: ShoofAPI.Show, tabbar: RoundedTabBar) {
        self.show = show
        self.tabbar = tabbar
        
        rmEpisodes = realm.objects(RDownload.self).filter("show_id = %i and isSeriesHeader = false", show.id)
        
        for  (_, episode) in rmEpisodes.enumerated() {
            downloading[episode.episode_id!] = (episode.episode_id!, episode.progress, episode.statusEnum)
        }
        
        CurrentSeasonWithEpisode()
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
    
    func fetchEpisodes() {
        self.isLoading = true
        loadEpisodes(forSeasonWithID: seasons[seasonIndexSelected].id, pageNumber: currentEpisodePage) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                let response = try? result.get()
                let episodes : [ShoofAPI.Media.Episode] = response?.body ?? self?.seasons[self?.seasonIndexSelected ?? 0].episodes ?? []// body or downloaded episodes
                self?.episodes = episodes
                
                if let response = response {
                    self?.hasNextPage = !response.isOnLastPage
                } else {
                    self?.hasNextPage = false
                }
            }
        }
    }
    func fetchNextPage() {
        
        isLoadingMore = true
        
        loadEpisodes(forSeasonWithID: seasons[seasonIndexSelected].id, pageNumber: currentEpisodePage + 1) {[weak self]  result in
            DispatchQueue.main.async {
                do {
                    let response = try result.get()
                    self?.hasNextPage = !response.isOnLastPage
                    self?.currentEpisodePage += 1
                    DispatchQueue.main.async {
                        self?.episodes.append(contentsOf: response.body)

                    }
                } catch {
                    
                }
                
                self?.isLoadingMore = false
            }
        }
    }
    
    private func loadEpisodes(forSeasonWithID seasonID: String, pageNumber:  Int, completionHandler: @escaping
        (Result<ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]>.Response, Error>) -> Void) {
            ShoofAPI.shared.loadEpisodes(forSeasonWithID: seasonID, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
    func playEpisode(index: Int) {
        guard ShoofAPI.shared.isInNetwork else {
            parentVC?.alert.unableToPlay()
            return
        }
        
        
        if index < episodes.count {
            self.episodeIndexSelected = index
            let seasonsView = SeasonsTV(show: show, seasonIndex: seasonIndexSelected, episodeIndex: episodeIndexSelected, episodes: episodes)
            tabbar?.playEpisode(show: show, currentEpisode: episodes[index], seasonsView: seasonsView) {
                
            }

        }
    }
    
    func Download(episode: ShoofAPI.Media.Episode) {
        if let parentVC = tabbar {
            guard ShoofAPI.shared.isInNetwork else {
                tabbar?.alert.unableToPlay()
                return
            }
            
            let sources = episode.files.map { file in
                CPlayerResolutionSource(title: file.resolution.description, nil, file.url)
            }
            
            var actions = [UIAlertAction]()
            
            for source in sources.filter({$0.source_file != nil}) {
                let action = UIAlertAction(title: source.title, style: .default, handler: { _ in
                    self.startDownloading(source, from: episode, in: self.seasons[self.seasonIndexSelected])
                })
                actions.append(action)
            }
            
            var title = NSLocalizedString("downloadResolutionSheetTitle", comment: "")
            if actions.count == 0 {
                title = NSLocalizedString("noContentMessage", comment: "")
            }
            
            actions.append(UIAlertAction(title: NSLocalizedString("cancelAlertButton", comment: ""), style: .cancel, handler: nil))
            let alert = UIAlertController(title: title,
                                          message: nil,
                                          preferredStyle: .actionSheet)
            alert.view.tintColor = Theme.current.tintColor
            actions.forEach({alert.addAction($0)})
            parentVC.dismiss(animated: true)
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
    
    private func startDownloading(_ source:CPlayerResolutionSource, from episode: ShoofAPI.Media.Episode, in season: ShoofAPI.Media.Season) {
        ///Append this indexPath after successfully adding new rmDownloadShow
        ///This will trigger realm observer in this class
        
    
        self.downloading[episode.id] = (episode.id, 0.0 , .downloading)
        let isAdded = DownloadManager.shared.download(episode,in: season, show: self.show, source: source) != nil
        if !isAdded {
            self.downloading.removeValue(forKey: episode.id)
        }
    }
    
}

