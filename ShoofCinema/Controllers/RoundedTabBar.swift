//
//  RoundedTabBar.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/21/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift
import StoreKit

class RoundedTabBar: UITabBarController {

    // MARK: - VARS
    lazy var alert = Alert(on: self)
    lazy var sheet = ActionSheet(on: self)
    var playingRmContinue:RContinueShow?
    var detailsChild : UIViewController?
    var seasonsVC: SeasonsVC?
    var episodesModelSheetDelegate: EpisodesModelSheet?
    
    var currentMovie: ShoofAPI.Media.Movie?
    var seasonsView: SeasonsTV?
    
    var layer = CAShapeLayer()
    
    //Download observation vars
    var rmDownloading:Results<RDownload>?
    var token:NotificationToken?
    lazy var hasDownloads = realm.objects(RDownload.self)
        .filter { $0.status != DownloadStatus.downloaded.rawValue }.count > 0
    
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
    
    var homeIndicatorShouldBeHidden = false

    
    var result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>?
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setViewControllers(super.viewControllers, animated: false)
        
        
        //Respond to didRecieveRemoteNotification when app was in background
        NotificationCenter.default
            .addObserver(self, selector: #selector(handle(notification:)),
                         name: NSNotification.Name(rawValue: gnNotification.didRecieveRemoteNotification),
                         object: nil)
        
        //Respond to didOpenFromLink (Safari banner or schemURL) when app was in background
        NotificationCenter.default
            .addObserver(self, selector: #selector(handleLink(notification:)),
                         name: NSNotification.Name(rawValue: gnNotification.didOpenFromLink),
                         object: nil)
        

        
        var t = "";
        //Handle queued operations in app launch if exist
        if let app = UIApplication.shared.delegate as? AppDelegate,
            let objectsToBeHandled = app.objectsToBeHandled {
            t += "1"
            for (key,notifcation) in objectsToBeHandled {
                t += "2"
                if key == gnNotification.didOpenFromLink {
                    t += "3"
                    delay(1) {
                        self.handleLink(notification: notifcation)
                    }
                } else if key == gnNotification.didRecieveRemoteNotification {
                    t += "4"
                    delay(1) {
                        self.handle(notification: notifcation)
                    }
                }
            }
        }
        
        // Check and observe downloads
        checkDownloads()
        
        showReviewDialog()
        showWalkthrough ()
		handleAPIResponse(result: result)
    }
    
    // TAB BAR ANIMATION
    @available(iOS 10.0, *)
    private func animate(_ item : UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }

        let timeInterval: TimeInterval = 0.3
        let propertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.5) {
            barItemView.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
        }
        propertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
        propertyAnimator.startAnimation()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if #available(iOS 10.0, *) {
            HapticFeedback.veryLightImpact()
            animate(item)
        }
    }
    
	@available(iOS 13.0, *)
	private func inReviewTabs () {

        var vcs = viewControllers
		
		let koloda = KolodaVC(nibName: nil, bundle: nil)
		let pagerNC = NewMainNavigationController(rootViewController: koloda)
		koloda.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic-tabbar-cards"), selectedImage: nil)
		vcs?.insert(pagerNC, at: 0)
		
		// Remove channels
		if let channelsVCIndex = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is ChannelPagesVC}) {
			vcs?.remove(at: channelsVCIndex)
		}
		
		// Remove explore
		if let channelsVCIndex = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is ExploreViewController}) {
			vcs?.remove(at: channelsVCIndex)
		}
		
        setViewControllers(vcs, animated: false)
		selectedIndex = 0
    }
    
	private func outsideNetworkTabs () {
        var vcs = viewControllers
        
        // DOWNLOADS TAB
        let downloadsVC = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: String(describing: DownloadsVC.self)) as? DownloadsVC
        let downloadsNC = NewMainNavigationController(rootViewController: downloadsVC!)
        downloadsNC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic-tabbar-downloads"), selectedImage: nil)
		
        vcs?.insert(downloadsNC, at: 0)
		
		// Remove explore
		if let vc = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is ExploreViewController}) {
			vcs?.remove(at: vc)
		}
		
		// Remove home
		if let vc = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is HomeVC}) {
			vcs?.remove(at: vc)
		}
		
		// Remove channels
		if let vc = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is ChannelPagesVC}) {
			vcs?.remove(at: vc)
		}
		
		// Remove Search
		if let vc = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is FavoriteVC}) {
			vcs?.remove(at: vc)
		}
		
        setViewControllers(vcs, animated: false)
		selectedIndex = 0
    }
    
    private func insideRamadanModeTabs () {
        var vcs = viewControllers
        
        // Remove explore
        if let vc = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is ExploreViewController}) {
            vcs?.remove(at: vc)
        }
        
        setViewControllers(vcs, animated: false)
        selectedIndex = 0
    }
    
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>?) {
		
		// HOME TAB
		let homeVC = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeVC.self)) as? HomeVC
		let homeNC = NewMainNavigationController(rootViewController: homeVC!)
		homeVC?.result = result
		homeNC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic-tabbar-home"), selectedImage: nil)
		
		// Replace current home vc
		var vcs = viewControllers
		if let channelsVCIndex = vcs?.firstIndex(where: { ($0 as? NewMainNavigationController)?.viewControllers.first is HomeVC}) {
			vcs?.remove(at: channelsVCIndex)
			vcs?.insert(homeNC, at: channelsVCIndex)
			viewControllers = vcs
		}
        
        if ShoofAPI.User.ramadanTheme {
            insideRamadanModeTabs()
        }
        
		
		if isOutsideDomain {
			if !appPublished && !hasDownloads, #available(iOS 13.0, *) {
				inReviewTabs()
			} else {
				if hasDownloads {
					ChiefsPlayer.initializeChromecastDiscovery()
					
				}
			}
		} else {
			ChiefsPlayer.initializeChromecastDiscovery()
		}
    }
    
    private func showWalkthrough () {
        if !appPublished, !hasDownloads, isOutsideDomain, RPref.walkthroghSeen != true {
            delay(2) {
                let wt = WalkthroghPagerVC()
                wt.modalPresentationStyle = .fullScreen
                self.present(wt, animated: true, completion: nil)
            }
        }
    }
    
    private func showReviewDialog () {
        if !isOutsideDomain &&  RPref.showReview == false {
            RPref.openCount += 1
            if RPref.openCount == 3 {
                delay(2) {
                    RPref.showReview = true
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    }
                }
            }
        }
    }
    
    deinit {
        token = nil
    }
    
    private func removeOldChildView () {
        if let oldDetailsChild = detailsChild {
            oldDetailsChild.willMove(toParent: nil)
            oldDetailsChild.removeFromParent()
        }
    }
    
	// MARK:- Screen Orientaion
	var lockOrientation: UIInterfaceOrientationMask = .portrait
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		lockOrientation
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		if ChiefsPlayer.isInitiated {
			ChiefsPlayer.shared.viewWillTransition(to: size, with: coordinator)
		}
	}
}

extension RoundedTabBar: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false
        }

        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.15, options: [.transitionCrossDissolve], completion: nil)
        }

        return true
    }
}



// MARK: - Download Observation
extension RoundedTabBar {
    func checkDownloads () {
        if !isOutsideDomain {
            //Continue downloads and verify db objects
            DownloadManager.shared.continueAvailableDownloads()
            
            observeDownloadChanges()
        }
        
        //Remove favorite and TV outside domain
        if isOutsideDomain {
            
            // A boolean to indicate: User has downloaded content and ready to play offline
            hasDownloads = realm.objects(RDownload.self).filter("status = %i && isSeriesHeader = false",DownloadStatus.downloaded.rawValue).count > 0
        }
    }
    
    /// Observe download changes to update app UI
    func observeDownloadChanges () {
        rmDownloading = realm
            .objects(RDownload.self)
            .filter("status = %i or status = %i or status = %i and isSeriesHeader = false",
                    DownloadStatus.downloading.rawValue,
                    DownloadStatus.downloading_sub.rawValue,
                    DownloadStatus.failed.rawValue)
        
        token = rmDownloading?.observe { [weak self](changes) in
            switch changes {
            case .initial(let objects):
                self?.setMore(from:objects)
                break
            case .update(let objects, _, _,_):
                self?.setMore(from:objects)
                break
            default:
                break
            }
        }
    }
    
    /// Update tab bar more icon to represent count of failed or in progress downloads
    /// - Parameter data: List of failed and downloading objects
    func setMore (from data:Results<RDownload>) {
        var failedCount:Int = 0
        var inProgressCount:Int = 0
        data.forEach({
            let status = $0.statusEnum
            if status == .failed {
                failedCount += 1
            } else {
                inProgressCount += 1
            }
        })
        var badgeColor : UIColor?
        var badgeValue : String?
        if inProgressCount > 0 {
            badgeColor = Theme.current.tintColor
            badgeValue = "\(inProgressCount)"
        } else if failedCount > 0 {
            badgeColor = Theme.current.captionsDarkerColor
            badgeValue = "\(failedCount)"
        }
        
        if #available(iOS 10.0, *) {
            tabBar.items?.last?.badgeColor = badgeColor
        }
        tabBar.items?.last?.badgeValue = badgeValue
    }
}

// MARK: - CHIEFS PLAYER
extension RoundedTabBar : ChiefsPlayerDelegate {
    
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
        removeOldChildView()
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
		
		setViewControllers(viewControllers?.filter({$0 != detailsChild}), animated: false)
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
            play(episode: nextEpisode, from: show)
        }
        
        return .custom(nil)
    }
    
    func chiefsplayerPrevAction(_ willTriggerAction: Bool) -> SeekAction? {
        guard let show = seasonsView?.show, let previousEpisode = seasonsView?.previousEpisode else {
            return nil
        }
        
        if willTriggerAction {
            seasonsView?.currentEpisode = previousEpisode
            play(episode: previousEpisode, from: show)
        }
        
        return .custom(nil)
    }
    
    func play (channel:ShoofAPI.Channel, with detailsView:UIView? = nil) {
//        playingShowId = nil
        seasonsView = nil
        playingRmContinue = nil
        if let source = channel.asPlayerSource() {
            play(from: [source] , and: detailsView)
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
                self.alert.unableToPlay()
                return
            }
			
			if source.resolutions.count == 0 {
				self.alert.noMovieFiles()
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
            
//            var seasonIndex = 0
//            if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
//               let seasonID = continueShow.seasonID, let index = seasons.firstIndex(where: { $0.id == seasonID }) {
//                seasonIndex = index
//            }
//
//			let season = seasons[seasonIndex]
//			loadEpisodes(forSeasonWithID: season.id) { [weak self] result in
//                DispatchQueue.main.async {
//
//					let response = try? result.get()
//					let episodes : [ShoofAPI.Media.Episode] = response?.body ?? season.episodes ?? []// body or downloaded episodes
//
//					if episodes.isEmpty {
//						self?.alert.noEpisodes()
//						completion?()
//						return
//					}
//
//					var episodeIndex = 0
//
//					if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
//					   let episodeID = continueShow.episode_id,
//					   let index = episodes.firstIndex(where: { $0.id == episodeID }) {
//						episodeIndex = index
//					}
//
//					let seasonsView = SeasonsTV(show: show, seasonIndex: seasonIndex, episodeIndex: episodeIndex, episodes: episodes)
//					self?.seasonsView = seasonsView
//                    self?.seasonsVC = SeasonsVC(seasonsTV: seasonsView, parentVC: self!)
//
//
//					if let currentEpisode = seasonsView.currentEpisode {
//						self?.play(episode: currentEpisode, from: show)
//                        //self?.chiefsplayerShowEpisodes()
//
//						if !currentEpisode.familyModTimelines.isEmpty {
//							CControlsManager.shared.leftButtons = {
//								let familyModeButton = FamilyModeButton()
//								return [familyModeButton]
//							}
//						} else {
//							CControlsManager.shared.leftButtons = { [] }
//						}
//					}
//
//                    completion?()
//                }
//            }
            //CControlsManager.shared.controlsEpisodesHideButtonToggle(to: false)
        }
    }
    
    func playEpisode(show: ShoofAPI.Show, currentEpisode: ShoofAPI.Media.Episode, seasonsView: SeasonsTV, completion: (() -> Void)? = nil) {
        guard let media = show.media else {
            completion?()
            return
        }
        
        //self.seasonsView = seasonsView
        //self.seasonsVC = SeasonsVC(seasonsTV: seasonsView, parentVC: self)
        
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
	
    func play(episode: ShoofAPI.Media.Episode, from show: ShoofAPI.Show) {
        if let season = seasonsView?.currentSeason {
            playingRmContinue = RealmManager.watchingStarted(show, with: episode, season: season)
        }
        
        let source = CPlayerSource(episode: episode, in: show)
        play(from: [source], and: UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)))
        CControlsManager.shared.controlsEpisodesHideButtonToggle(to: false)
        self.episodesModelSheetDelegate?.dismiss()
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
            player.configs.onMinimizedAdditionalBottomSafeArea = tabBar.frame.height - screenSafeInsets.bottom + 2
            
            detailsView?.backgroundColor = Theme.current.backgroundColor
            
            player.play(from: sources, with: detailsView)
            player.present(on: self)
        }
    }
    
    func chiefsplayerPictureInPictureEnabled() -> Bool {
        return true
    }
}
