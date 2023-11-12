//
//  VideoPlayerViewController.swift
//  ShoofCinema
//
//  Created by mac on 8/19/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift


class VideoPlayerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    lazy var sheet = ActionSheet(on: self)
    lazy var alert = Alert(on: self)
    var playingRmContinue:RContinueShow?
    var detailsChild : UIViewController?
    var seasonsVC: SeasonsVC?
    var episodesModelSheetDelegate: EpisodesModelSheet?
    
    var currentMovie: ShoofAPI.Media.Movie?
    var seasonsView: SeasonsTV?
    
    var layer = CAShapeLayer()
    var show: ShoofAPI.Show?
    
    var homeIndicatorShouldBeHidden = false
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    var statusBarShouldBeHidden = false {
        didSet {
            UIView.animate(withDuration: 0.4) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        if let show = show {
//            play(show: show)
//        }
        
    }
    

    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    var lockOrientation: UIInterfaceOrientationMask = .portrait
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return lockOrientation
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        AppDelegate.orientationLock = .landscape
    }
    
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if ChiefsPlayer.isInitiated {
            ChiefsPlayer.shared.viewWillTransition(to: size, with: coordinator)
        }
    }
    
}

// MARK:- Screen Orientaion



// MARK: - CHIEFS PLAYER
extension VideoPlayerViewController : ChiefsPlayerDelegate {
    
    func chiefsPlayer(_ player: ChiefsPlayer, didEnterTimeline timeline: Timeline) -> CControlsManager.Action? {
        if ShoofAPI.Settings.shared.isFamilyModOn {
            if let familyModTimelines = currentMovie?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.endTime))
            } else if let familyModTimelines = seasonsView?.currentEpisode?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.endTime))
            }
        }
        
        if let skips = currentMovie?.skips, skips.contains(where: { $0.id == timeline.id }) {
            return .showButton(withTitle: NSLocalizedString("skip", comment: ""), action: .seekTo(Int(timeline.endTime)))
        } else if let skips = seasonsView?.currentEpisode?.skips, skips.contains(where: { $0.id == timeline.id }) {
            return .showButton(withTitle: NSLocalizedString("skip", comment: ""), action: .seekTo(Int(timeline.endTime)))
        }
        
        return nil
    }
    
    func chiefsPlayer(_ player: ChiefsPlayer, didExitTimeline timeline: Timeline) -> CControlsManager.Action? {
        return .hideButton
    }
    
    func chiefsplayerDebugLog (_ string:String) {
        FABLog(event: string)
    }
    
    func chiefsplayer(isCastingTo castingService: CastingService?) {
        let service = castingService == nil ? "Not casting" : "\(castingService!)"
        FABLog(event: "Casting to : \(service)")
        
        if castingService == .airplay {
            FIRSet(userProperty: "1", name: .hasAppleTV)
        } else if castingService == .chromecast {
            FIRSet(userProperty: "1", name: .hasChromecast)
        }
    }
    
    func chiefsplayerWillStartCasting(from source: CPlayerSource) -> CPlayerSource? {
        var source = source
        
        //Because chromecast only supports webvtt and doesn't support srt
        ///This should not affect using of m3u8 because `subtitles` will be nil
        let webvttSubs = source.subtitles?.compactMap({ (sub) -> CPlayerSubtitleSource? in
            if let webvttUrl = URL(string: sub.source.absoluteString.replacingOccurrences(of: "srt", with: "vtt")) {
                return CPlayerSubtitleSource(title: sub.title, source: webvttUrl)
            }
            return nil
        })
        
        source.subtitles = webvttSubs
        return source
    }
    
    func chiefsplayerStatusBarShouldBe(hidden: Bool) {
        statusBarShouldBeHidden = hidden
    }
    
    func chiefsplayerWillStop(playing item: CPlayerItem) {
        
    }
    
    func chiefsplayerShowEpisodes() {
        if #available(iOS 15, *) {
            if let sheet = seasonsVC!.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
            present(seasonsVC!, animated: true, completion: nil)
        }
        
    }
    
    func chiefsplayerReadyToPlay(_ item: CPlayerItem, resolution: CPlayerResolutionSource, from source: CPlayerSource) {
        
        guard let playingRmContinue = playingRmContinue else {return}
        
        if playingRmContinue.left_at_percentage < 0.98 {
            let cmTime = CMTime(seconds: Double(playingRmContinue.left_at), preferredTimescale: 1)
            item.seek(to: cmTime, completionHandler: nil)
        }
    }
    
    func chiefsplayer(isPlaying item: CPlayerItem, at second: Float, of totalSeconds: Float) {
        guard let rm = playingRmContinue else {
            return
        }
        let perc = second / totalSeconds
        RealmManager.updateWatchingProgress(for: rm, leftAt: Int(second), and: perc)
    }
    
    func chiefsplayerAppeared() {
        
    }
    
    func chiefsplayerDismissed() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        AppDelegate.orientationLock = .portrait
        dismiss(animated: true)
        //removeOldChildView()
    }
    
    func chiefsplayerMinimized() {
    }
    
    func chiefsplayerMaximized() {
        
    }
    
    func chiefsplayerNeedsUpdateOfSupportedInterfaceOrientations(to supportedInterfaceOrientation: UIInterfaceOrientationMask) {
        homeIndicatorShouldBeHidden = supportedInterfaceOrientation == .landscape
        
        lockOrientation = supportedInterfaceOrientation
        
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
        
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
        
        //setViewControllers(viewControllers?.filter({$0 != detailsChild}), animated: false)
    }
    
    
    func chiefsplayerBackwardAction(_ willTriggerAction: Bool, timeline: Timeline?) -> SeekAction? {
        guard let timeline = timeline else {
            return .seekBy(-10)
        }
        if ShoofAPI.Settings.shared.isFamilyModOn {
            if let familyModTimelines = currentMovie?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.startTime) - 10)
            } else if let familyModTimelines = seasonsView?.currentEpisode?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.startTime) - 10)
            }
        }
        return .seekBy(-10)
    }
    
    func chiefsplayerForwardAction(_ willTriggerAction: Bool, timeline: Timeline?) -> SeekAction? {
        guard let timeline = timeline else {
            return .seekBy(8)
        }
        if ShoofAPI.Settings.shared.isFamilyModOn {
            if let familyModTimelines = currentMovie?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.endTime) + 8)
            } else if let familyModTimelines = seasonsView?.currentEpisode?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
                return .seekTo(Int(timeline.endTime) + 8)
            }
        }
        return .seekBy(8)
    }
    
    //    func chiefsplayerProgressChanged(timeline: Timeline?) -> SeekAction? {
    //        print("zjcbzhcbjzvbhzvb")
    //        guard let timeline = timeline else {
    //            return nil
    //        }
    //        if ShoofAPI.Settings.shared.isFamilyModOn {
    //            if let familyModTimelines = currentMovie?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
    //                return .seekTo(Int(timeline.endTime))
    //            } else if let familyModTimelines = seasonsView?.currentEpisode?.familyModTimelines, familyModTimelines.contains(where: { $0.id == timeline.id }) {
    //                return .seekTo(Int(timeline.endTime))
    //            }
    //        }
    //        return nil
    //    }
    
    func chiefsplayerNextAction(_ willTriggerAction: Bool) -> SeekAction? {
        guard let show = seasonsView?.show, let nextEpisode = seasonsView?.nextEpisode else {
            return nil
        }
        
        if willTriggerAction {
            seasonsView?.currentEpisode = nextEpisode
            //play(episode: nextEpisode, from: show)
        }
        
        return .custom(nil)
    }
    
    func chiefsplayerPrevAction(_ willTriggerAction: Bool) -> SeekAction? {
        guard let show = seasonsView?.show, let previousEpisode = seasonsView?.previousEpisode else {
            return nil
        }
        
        if willTriggerAction {
            seasonsView?.currentEpisode = previousEpisode
            // play(episode: previousEpisode, from: show)
        }
        
        return .custom(nil)
    }
    
    func play (channel:ShoofAPI.Channel, with detailsView:UIView? = nil) {
        //        playingShowId = nil
        seasonsView = nil
        playingRmContinue = nil
        if let source = channel.asPlayerSource() {
            self.play(from: [source] , and: detailsView)
            CControlsManager.shared.controlsEpisodesHideButtonToggle(to: true)
        }
    }
    
    
    func loadEpisodes(forSeasonWithID seasonID: String, pageNumber: Int = 1, completionHandler: @escaping (Result<ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]>.Response, Error>) -> Void) {
        ShoofAPI.shared.loadEpisodes(forSeasonWithID: seasonID, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
    func play(show: ShoofAPI.Show, completion: (() -> Void)? = nil) {
        guard let media = show.media else {
            completion?()
            return
        }
        
        switch media {
        case .movie(let movie):
            seasonsView = nil
            
            playingRmContinue = RealmManager.watchingStarted(show)
            
            guard let source = CPlayerSource(show: show) else {
                //self.alert.unableToPlay()
                return
            }
            
            if source.resolutions.count == 0 {
                // self.alert.noMovieFiles()
                return
            }
            
            self.currentMovie = movie
            
            //Create new details view for the selected show
            let detailsChild = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: "DetailsVC") as? DetailsVC
            
            //Customize view
            detailsChild?.mode = .underPlayer
            detailsChild?.show = show
            
            //Strong Reference to remove from tabBar controllers att
            self.detailsChild = detailsChild
            
            //Add child [Required for iOS12 and earlier]
            addChild(detailsChild!)
            
            //Add view and Start player
            play(from: [source], and: detailsChild!.view)
            detailsChild?.didMove(toParent: self)
            
            completion?()
            
            if !movie.familyModTimelines.isEmpty {
                CControlsManager.shared.leftButtons = {
                    let familyModeButton = FamilyModeButton()
                    return [familyModeButton]
                }
                
            } else {
                CControlsManager.shared.leftButtons = { [] }
            }
            CControlsManager.shared.controlsEpisodesHideButtonToggle(to: true)
        case .series(let seasons):
            guard !seasons.isEmpty else {
                print("======= Couldn't play series because seasons were not set")
                return
            }
            
            var seasonIndex = 0
            if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
               let seasonID = continueShow.seasonID, let index = seasons.firstIndex(where: { $0.id == seasonID }) {
                seasonIndex = index
            }
            
            let season = seasons[seasonIndex]
            loadEpisodes(forSeasonWithID: season.id) { [weak self] result in
                DispatchQueue.main.async {
                    
                    let response = try? result.get()
                    let episodes : [ShoofAPI.Media.Episode] = response?.body ?? season.episodes ?? []// body or downloaded episodes
                    
                    if episodes.isEmpty {
                        self?.alert.noEpisodes()
                        completion?()
                        return
                    }
                    
                    var episodeIndex = 0
                    
                    if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
                       let episodeID = continueShow.episode_id,
                       let index = episodes.firstIndex(where: { $0.id == episodeID }) {
                        episodeIndex = index
                    }
                    
                    let seasonsView = SeasonsTV(show: show, seasonIndex: seasonIndex, episodeIndex: episodeIndex, episodes: episodes)
                    self?.seasonsView = seasonsView
                    self?.seasonsVC = SeasonsVC(seasonsTV: seasonsView, parentVC: self!)
                    
                    
                    if let currentEpisode = seasonsView.currentEpisode {
                        self?.play(episode: currentEpisode, from: show)
                        //self?.chiefsplayerShowEpisodes()
                        
                        if !currentEpisode.familyModTimelines.isEmpty {
                            CControlsManager.shared.leftButtons = {
                                let familyModeButton = FamilyModeButton()
                                return [familyModeButton]
                            }
                        } else {
                            CControlsManager.shared.leftButtons = { [] }
                        }
                    }
                    
                    completion?()
                }
            }
            //CControlsManager.shared.controlsEpisodesHideButtonToggle(to: false)
        }    }
    
    
    func play(episode: ShoofAPI.Media.Episode, from show: ShoofAPI.Show) {
        if let season = seasonsView?.currentSeason {
            playingRmContinue = RealmManager.watchingStarted(show, with: episode, season: season)
        }
        
        let source = CPlayerSource(episode: episode, in: show)
        play(from: [source], and: UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)))
        CControlsManager.shared.controlsEpisodesHideButtonToggle(to: false)
    }
    
    func playEpisode(show: ShoofAPI.Show, currentEpisode: ShoofAPI.Media.Episode, seasonsView: SeasonsTV, completion: (() -> Void)? = nil) {
        guard let media = show.media else {
            completion?()
            return
        }
        
        self.seasonsView = seasonsView
        self.seasonsVC = SeasonsVC(seasonsTV: seasonsView, parentVC: self)
        
        self.play(episode: currentEpisode, from: show)
        //self?.chiefsplayerShowEpisodes()
        
        if !currentEpisode.familyModTimelines.isEmpty {
            CControlsManager.shared.leftButtons = {
                let familyModeButton = FamilyModeButton()
                return [familyModeButton]
            }
        } else {
            CControlsManager.shared.leftButtons = { [] }
        }
        
        completion?()
    }
    
    func play (from sources:[CPlayerSource], and detailsView:UIView? = nil) {
        //CControlsManager.shared.controlsEpisodesHideButtonToggle(to: true)
        //Playing another series episode without chaning
        if detailsView == nil {
            ChiefsPlayer.shared.play(from: sources, with: nil)
        } else {
            let player = ChiefsPlayer.shared
            player.delegate = self
            
            player.configs.videoRatio       = .widescreen
            player.configs.controlsStyle    = .youtube
            player.configs.appearance       = .dark
            player.configs.tintColor        = Theme.current.tintColor
            player.configs.minimizeBackgroundColor  = Theme.current.tabbarColor
            player.configs.maximizedBackgroundColor = UIColor.black
            player.configs.onMinimizedAdditionalBottomSafeArea = self.view.frame.height - screenSafeInsets.bottom + 2
            
            detailsView?.backgroundColor = Theme.current.backgroundColor
            
            player.play(from: sources, with: detailsView)
            player.present(on: self)
        }
    }
    
    func chiefsplayerPictureInPictureEnabled() -> Bool {
        return true
    }
}
