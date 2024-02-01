//
//  ShowDetailsViewModel.swift
//  ShoofCinema
//
//  Created by mac on 7/9/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import SwiftUI

class ShowDetailsViewModel: ObservableObject {
    
    @Published var show: ShoofAPI.Show
    @Published var status: ResponseStatus = .none
    @Published var downloadStatus: DownloadStatus = .unknown
    @Published var showingLoginAlert = false
    @Published var showingLogin = false
    
    
    let shoofAPI = ShoofAPI.shared
    
    let videoPlayerViewController = VideoPlayerViewController()
    
    var sources: [CPlayerResolutionSource] {
        guard let media = show.media, case .movie(let movie) = media else {
            return[]
        }
        
        let resolutions = movie.files.map { CPlayerResolutionSource(title: $0.resolution.description, nil, $0.url) }

        return resolutions
    }
    
    init(show: ShoofAPI.Show) {
        self.show = show
    }
    
    func loadDetails() {
        self.status = .loading
        
        shoofAPI.loadDetails(for: show) { [weak self] result in
            DispatchQueue.main.async { [self] in
                do {
                    let response = try result.get()
                    self?.show = response.body
                    self?.status = .loaded
                    HapticFeedback.lightImpact()
                } catch {
                    //self?.tabbar?.alert.genericError()
                }
            }
        }
    }
    
    
    
    
    func download(source: CPlayerResolutionSource) {
        _ = DownloadManager.shared.download(show: show, source: source)
    }
    
    func handleWatchLaterAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.WatchLaterShow>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            do {
                let _ = try result.get()
                show.isInWatchLater.toggle()
                HapticFeedback.lightImpact()
            } catch {
                //tabbar?.alert.genericError()
            }
        }
    }
    
    func toggleWatchLater () {
        guard ShoofAPI.User.current != nil else {
            self.showingLoginAlert.toggle()
            return
        }
        
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
    
    func fakeShow() -> ShoofAPI.Show {
        var fakeShow = show
        
        switch show.media {
        case .movie:
            fakeShow.media = .movie(.init(files: [.init(id: "123498ghdgj", url: URL(string: "https://cdn.shabakaty.com/mp420-480/8E34C600-22B5-F216-47B0-561C9A726FD9_video.mp4"), resolution: .hd1080)], subtitles: nil, skips: [], familyModTimelines: []))
            
        case .series(let season):
            fakeShow.media = .series(seasons: season)
            
        case .none:
            print("none")
        }
        
        return fakeShow
    }
    
    private func handleSubscriptionAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.SubscribeShow>.Response, Error>?) {
        DispatchQueue.main.async { [self] in
            do {
                let result = try result?.get()
                show.isSubscribed.toggle()
                HapticFeedback.lightImpact()
            } catch {
                //tabbar?.alert.genericError()
            }
        }
    }
    
    
    
    func toggleSubscribe() {
        guard ShoofAPI.User.current != nil else {
            return
        }
        
        show.isSubscribed.toggle()
        
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
    
}

extension ShowDetailsViewModel: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        if !item.isInvalidated {
            if item.show_id == show.id {
                //self.downloadButton.downloadPercent = CGFloat(downloadModel.progress)
            }
        }
        
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        if !item.isInvalidated {
            if item.show_id == show.id {
                self.downloadStatus = item.statusEnum
            }
        }
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        if let key = primaryKey as? String {
            if key.contains("\(show.id)") {
                self.downloadStatus = .unknown
            }
        }
    }
}
