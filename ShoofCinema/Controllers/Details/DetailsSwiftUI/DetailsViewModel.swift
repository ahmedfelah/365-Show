//
//  DetailsViewModel.swift
//  ShoofCinema
//
//  Created by mac on 4/27/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftUI




class DetailsViewModel: ObservableObject {
    
    
    

    
    @Published var show: ShoofAPI.Show?
    @Published var state: ResponseStatus = .loading
    @Published var downloadStatus: DownloadStatus = .unknown
    @Published var isFavLoading: Bool = false
    @Published var isSubLoading: Bool = false
    @Published var isWatchLoading: Bool = false
    @Published var downloadingProgress: Float = 0.0
    
    let shoofAPI = ShoofAPI.shared
    let tabbar: RoundedTabBar?
    let parentVC: UIViewController?
    
    var downloadedItem: Bool = false
    
    
    init(show: ShoofAPI.Show?, tabbar: RoundedTabBar?, parentVC: UIViewController?) {
        self.show = show
        self.tabbar = tabbar
        self.parentVC = parentVC
        
        if !isOutsideDomain {
            DownloadManager.shared.observeAllDownloads(observer: self)
            if let showId = show?.id {
                let rmDownload = realm.objects(RDownload.self).first(where: {$0.show_id == showId})
                self.downloadingProgress = rmDownload?.progress ?? 0
                self.downloadStatus = rmDownload?.statusEnum ?? .unknown
                
            }
        }
        
    }
    
    func loadDetails() {
        if let show = show {
            shoofAPI.loadDetails(for: show) { [weak self] result in
                DispatchQueue.main.async { [self] in
                    do {
                        let response = try result.get()
                        self?.show = response.body
                        self?.state = .loaded
                        HapticFeedback.lightImpact()
                    } catch {
                        self?.tabbar?.alert.genericError()
                    }
                }
            }
        }
    }
    
    private func handleLoadEpisodes(show: ShoofAPI.Show) {
        
        if case .series(let seasons) = show.media {
            var seasonIndex = 0
            if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
               let seasonID = continueShow.seasonID, let index = seasons.firstIndex(where: { $0.id == seasonID }) {
                seasonIndex = index
            }
            
            guard !seasons.isEmpty else {
                print("======= Couldn't play series because seasons were not set")
                return
            }
            
            
            let season = seasons[seasonIndex]
            loadEpisodes(forSeasonWithID: season.id) { result in
                DispatchQueue.main.async {
                    
                    let response = try? result.get()
                    let episodes : [ShoofAPI.Media.Episode] = response?.body ?? season.episodes ?? []// body or downloaded episodes
                    self.state = .loaded
                    
                    if episodes.isEmpty {
                        self.tabbar?.alert.noEpisodes()
                        return
                    }
                    
                    var episodeIndex = 0
                    
                    if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
                       let episodeID = continueShow.episode_id,
                       let index = episodes.firstIndex(where: { $0.id == episodeID }) {
                        episodeIndex = index
                    }
                    
                    //let seasonsView = SeasonsTV(show: self.show!, seasonIndex: seasonIndex, episodeIndex: episodeIndex, episodes: episodes)
                    
                }
            }
        }
    }
    
    private func loadEpisodes(forSeasonWithID seasonID: String, pageNumber: Int = 1, completionHandler: @escaping
                              (Result<ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]>.Response, Error>) -> Void) {
        ShoofAPI.shared.loadEpisodes(forSeasonWithID: seasonID, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
    func startDownload() {
        if downloadStatus != .unknown {
            return
        }
        
        guard ShoofAPI.shared.isInNetwork || downloadedItem else {
            tabbar?.alert.unableToPlay()
            return
        }
        
        guard let show = show, let media = show.media, case .movie(let movie) = media else {
            return
        }
        
        let resolutions = movie.files.map { CPlayerResolutionSource(title: $0.resolution.description, nil, $0.url) }
        
        guard !resolutions.isEmpty else {
            tabbar?.alert.genericError()
            return
        }
        
        self.tabbar?.sheet.chooseDownloadResolution(sources: resolutions, selectedResolutionAction: { (selected) in
            self.startDownloading(selected, from: show)
        })
        
    }
    
    private func startDownloading(_ source:CPlayerResolutionSource, from show: ShoofAPI.Show) {
        if downloadStatus == .unknown {
            downloadStatus = .loading
            _ = DownloadManager.shared.download(show: show, source: source)
        }
    }
    
    func handleWatchLaterAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.WatchLaterShow>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            isFavLoading = false
            
            do {
                let _ = try result.get()
                show?.isInWatchLater.toggle()
                HapticFeedback.lightImpact()
            } catch {
                tabbar?.alert.genericError()
            }
        }
    }
    
    func toggleFav () {
        guard let show = show else {
            return
        }
        
        guard ShoofAPI.User.current != nil else {
            let loginVC = LoginViewController()
            if let tabbar = tabbar {
                tabbar.alert.loginFirstToFav {
                    self.parentVC?.navigationController?.pushViewController(loginVC, animated: true)
                }
            }
            return
        }
        
        isFavLoading = true
        
        if show.isInWatchLater {
            shoofAPI.removeShowFromWatchLater(show) { [weak self] result in
                self?.handleWatchLaterAPIResponse(result: result)
            }
        } else {
            shoofAPI.addShowToWatchLater(show) { [weak self] result in
                self?.handleWatchLaterAPIResponse(result: result)
            }
        }
    }
    
    func handleSubscriptionAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.SubscribeShow>.Response, Error>?) {
        DispatchQueue.main.async { [self] in
            isSubLoading = true
            
            do {
                let result = try result?.get()
                show?.isSubscribed.toggle()
                HapticFeedback.lightImpact()
            } catch {
                print(error)
                tabbar?.alert.genericError()
            }
        }
    }
    
    func watch() {
        guard ShoofAPI.shared.isInNetwork || downloadedItem else {
            tabbar?.alert.unableToPlay()
            return
        }
        
        guard let show = show else {
            return
        }
        
        isWatchLoading.toggle()
        tabbar?.play(show: show) { [weak self] in
            self?.isWatchLoading.toggle()
        }
    }
    
    func handleSubscribe() {
        guard let show = show else {
            return
        }
        
        guard ShoofAPI.User.current != nil else {
            tabbar?.alert.loginToContinue { [weak self] in
                let loginVC = LoginViewController()
                self?.parentVC?.navigationController?.pushViewController(loginVC, animated: true)
            }
            
            return
        }
        
        isSubLoading = false
        
        if show.isSubscribed {
            shoofAPI.unsubscrible(from: show) { [weak self] result in
                self?.handleSubscriptionAPIResponse(result: nil)
            }
        } else {
            shoofAPI.subcribe(to: show) { [weak self] result in
                self?.handleSubscriptionAPIResponse(result: result)
            }
        }
    }
    
    private var shareLink : URL? {
        get {
            return URL(string: "http://cn.shoof.show/ar/details?id=\(show?.id ?? "")")
        }
    }
    
    func shareTapped () {
        guard let shareLink = shareLink else {
            return
        }
        
        let actitiviyController = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
        actitiviyController.excludedActivityTypes = []
        actitiviyController.popoverPresentationController?.sourceRect = CGRect(x: parentVC!.view.bounds.midX, y: parentVC!.view.bounds.midY, width: 0, height: 0)
        actitiviyController.popoverPresentationController?.permittedArrowDirections = []
        parentVC!.present(actitiviyController, animated: true)
    }
    
    func writeComment () {
        guard ShoofAPI.User.current != nil else {
            tabbar?.alert.loginFirstToFav { [weak self] in
                let loginVC = LoginViewController()
                self?.parentVC?.navigationController?.pushViewController(loginVC, animated: true)
            }
            
            return
        }
        
        let commentsVC = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: "WriteCommentVC") as! WriteCommentVC
        commentsVC.show = show
        self.parentVC?.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func moreComment () {
        if let showId = show?.id {
            let commentsVC = UIHostingController(rootView: AllCommentsView(viewModel: CommentViewModel(showId: showId)))
            self.parentVC?.navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
    
    func getMatchRate () -> String {
        guard let show = show else {
            return "matchRate"
        }

        if let matchRate = matchValues[show.id] {
            return matchRate
        } else {
            let randomValue = "\(Int(arc4random_uniform(20)) + 63)%"
            matchValues[show.id] = randomValue
            return randomValue
        }
        
//        guard let matchRate = matchValues?[self.passedShowItem.id] else {
//            let randValue = "\(Int(arc4random_uniform(20)) + 63)%"
//            matchValues?[self.passedShowItem.id] = randValue
//            return randValue
//        }
//
//        return matchRate
    }
    
}

extension DetailsViewModel: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        if !item.isInvalidated {
            if item.show_id == show?.id {
                self.downloadingProgress = downloadModel.progress
            }
        }
        
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        if item.show_id == show?.id {
            self.downloadStatus = .unknown
        }
    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
        if item.show_id == show?.id {
            downloadStatus = .unknown
        }
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        /// Update cell and refresh `downloadingIndexes` order
        
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        if item.show_id == show?.id {
            downloadStatus = item.statusEnum
        }
        
    }
}
