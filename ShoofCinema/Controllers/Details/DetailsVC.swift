//
//  DetailsVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/2/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON
import NFDownloadButton
import SwiftUI

class DetailsVC : MasterTVC {
    
    public enum DetailsVCMode {
        case loading, loaded, underPlayer
    }
    
    // MARK: - LINKS
    @IBOutlet weak var showsCollection : ShowsCollectionView!
    @IBOutlet weak var actorsCollection : UICollectionView!
    @IBOutlet weak var posterImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var yearLabel : UILabel!
    @IBOutlet weak var imdbRatingLabel : UILabel!
    @IBOutlet weak var mapaaRatingLabel : UILabel!
    @IBOutlet weak var storyLabel : UILabel!
    @IBOutlet weak var directorsLabel : UILabel!
    @IBOutlet weak var writesLabel : UILabel!
    @IBOutlet weak var posterCell : UITableViewCell!
    //@IBOutlet weak var playButton : PlayButton!
    @IBOutlet weak var matchButton : MatchButton!
    @IBOutlet weak var watchButton: MainButton!
    
    @IBOutlet weak var stackView : UIStackView!
	@IBOutlet weak var favoriteBtn: VerticalButton!
	@IBOutlet weak var subscribeBtn: VerticalButton!
	@IBOutlet weak var trailerButton: VerticalButton!
	@IBOutlet weak var shareButton: VerticalButton!
	
    
    @IBOutlet weak var commentsNumberLabel : UILabel!
    @IBOutlet weak var showMoreCommentsButton : MainButton!
    @IBOutlet weak var lastCommentView : LightRoundedView!
    @IBOutlet weak var lastCommentMessageLabel : UILabel!
    @IBOutlet weak var lastCommentUserLabel : UILabel!
    @IBOutlet weak var commentProfileNameView : ProfileNameView!
    @IBOutlet weak var noCommentLabel : UILabel!
    
//    @IBOutlet weak var storyLineTitleLabel: UILabel!
//    @IBOutlet weak var storyLineCell: UITableViewCell!
    @IBOutlet weak var directorsStackView: UIStackView!
    @IBOutlet weak var writersStackView: UIStackView!
    @IBOutlet weak var mpaaRatingView: UIView!
    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet var imdbRatingCollectionImage: [UIImageView]!
    
    let shoofAPI = ShoofAPI.shared
    
    var show: ShoofAPI.Show?
    
    // MARK: - VARS
//    var passedShowItem : Show! {
//        didSet {
//            if passedShowItem.seasons != nil {
//                passedShowType = .series
//            } else {
//                passedShowType = .movie
//            }
//        }
//    }
    
//    var passedShowType : ShowType = .movie
    
    var downloadedItem : Bool = false
    
    let downloadButton = NFDownloadButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40),style: .iOS)
    
    var mode : DetailsVCMode = .loading
    var category : Int = 0
	
    // MARK: - LOAD
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)
        showsCollection.scrollDirection = .horizontal
        showsCollection.showHeader = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.removeStatusBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        showsCollection.showsDelegate = self
		
		tableView.alwaysBounceVertical = true
		
        if show?.media == nil {
            watchButton.showActivityIndicator()
            matchButton.showCustomActivityIndicator()
        }
        
        if show?.isMovie == false {
            subscribeBtn.isHidden = false
		} else {
			subscribeBtn.isHidden = true
		}
        
        setupWatchButton()
        
		// Setup button titles
		subscribeBtn.setTitle("subscribe".localized, for: .normal)
		favoriteBtn.setTitle("favorite".localized, for: .normal)
		shareButton.setTitle("share".localized, for: .normal)
		trailerButton.setTitle("trailer".localized, for: .normal)
		
		// Setup button images
		subscribeBtn.setImage(UIImage(named: "bell.not.fill"), for: .normal)
		subscribeBtn.setImage(UIImage(named: "bell.fill"), for: .selected)
		
		favoriteBtn.setImage(UIImage(named: "heart.not.fill"), for: .normal)
		favoriteBtn.setImage(UIImage(named: "heart.fill"), for: .selected)
		
		shareButton.setImage(UIImage(named: "square.and.arrow.up"), for: .normal)
		trailerButton.setImage(UIImage(named: "ic-details-trailer"), for: .normal)
		
        addDownloadButton()
        setupActorsCollection()

        if !isOutsideDomain {
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
        
        setupWatchButton()
        
        // HandOff 💪🏻
        userActivity = NSUserActivity(activityType: "com.AppChief.Shoof.Browse")
        userActivity?.webpageURL = shareLink
        userActivity?.title = show?.title
        userActivity?.isEligibleForHandoff = true
        userActivity?.becomeCurrent()
    }
    
    private func setupWatchButton() {
        watchButton.setTitle("Watch", for: .normal)
        watchButton.titleLabel?.tintColor = .white
        watchButton.tintColor = .white
        watchButton.titleLabel?.font = Fonts.almaraiBold(17)
        watchButton.backgroundColor = Theme.current.tintColor
        watchButton.layer.cornerRadius = 10
        watchButton.clipsToBounds = true
    }
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.Show>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            HapticFeedback.lightImpact()
            
			if appPublished {
                watchButton.hideActivityIndicator()
			} else {
				matchButton.hideCustomActivityIndicator()
			}
            
            do {
                let response = try result.get()
                let show = response.body
                self.show = show
                handleLoadEpisodes(show: show)
                self.mode = .loaded
                tableView.isScrollEnabled = true
                self.updateViews()
                
                if let relatedShows = show.relatedShows, !relatedShows.isEmpty {
                    self.showsCollection.startLoading()
                }
            } catch {
                if !downloadedItem {
                    tabBar?.alert.genericError()
                }
            }
		}
    }
    
    private func handleLoadEpisodes(show: ShoofAPI.Show) {
        
//        if case .series(let seasons) = show.media {
//            var seasonIndex = 0
//            if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
//               let seasonID = continueShow.seasonID, let index = seasons.firstIndex(where: { $0.id == seasonID }) {
//                seasonIndex = index
//            }
//            
//            guard !seasons.isEmpty else {
//                print("======= Couldn't play series because seasons were not set")
//                return
//            }
//            
//            
//            let season = seasons[seasonIndex]
//            
//            loadEpisodes(forSeasonWithID: season.id) { result in
//                DispatchQueue.main.async {
//                    
//                    let response = try? result.get()
//                    let episodes : [ShoofAPI.Media.Episode] = response?.body ?? season.episodes ?? []// body or downloaded episodes
//                    
//                    if episodes.isEmpty {
//                        self.tabBar?.alert.noEpisodes()
//                        return
//                    }
//                    
//                    var episodeIndex = 0
//                    
//                    if let continueShow = RealmManager.rmContinueForLastLeftShow(with: show.id),
//                       let episodeID = continueShow.episode_id,
//                       let index = episodes.firstIndex(where: { $0.id == episodeID }) {
//                        episodeIndex = index
//                    }
//                    
//                    let seasonsView = SeasonsTV(show: self.show!, seasonIndex: seasonIndex, episodeIndex: episodeIndex, episodes: episodes)
//                    let vc = SeasonsVC(seasonsTV: seasonsView, parentVC: self.tabBar!)
//                    vc.seasonsTV?.isScrollEnabled = true
//                    self.tableView.tableFooterView = vc.view
//                    self.tableView.tableFooterView?.sizeToFit()
//                    self.addChild(vc)
//                    
//                }
//            }
//        }
    }
    

    
    private func loadEpisodes(forSeasonWithID seasonID: String, pageNumber: Int = 1, completionHandler: @escaping
        (Result<ShoofAPI.Endpoint<[ShoofAPI.Media.Episode]>.Response, Error>) -> Void) {
            ShoofAPI.shared.loadEpisodes(forSeasonWithID: seasonID, pageNumber: pageNumber, completionHandler: completionHandler)
    }
    
    func loadDetails(forShow show: ShoofAPI.Show) {
        shoofAPI.loadDetails(for: show) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    func reloadShow() {
        if let show = show {
            loadDetails(forShow: show)
        }
    }
    
    override func setupViews() {    
        super.setupViews()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none

        updateViews()
        
        if let show  = show, mode != .underPlayer  {
            loadDetails(forShow: show)
        }
		
        if mode == .underPlayer {
            self.tableView.contentInset  = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        }

        if isOutsideDomain || downloadedItem {
            downloadButton.isHidden = true
        }

        if isOutsideDomain && !appPublished && !downloadedItem {
            matchButton.isHidden = false
            watchButton.isHidden = true
            matchButton.textLabel.text = getMatchRate()
        } else {
            matchButton.isHidden = true
            watchButton.isHidden = false
        }
    }
    
    
    @objc func showShowFor(actorName : String) {
        
    }
    
    
    deinit {
        print("INIT DETAILS VC")
    }
    
    
    // MARK: - PRIVATE
    private func addDownloadButton () {
        downloadButton.initialColor = .white
        downloadButton.deviceColor = Theme.current.tintColor
        downloadButton.downloadColor = Theme.current.tintColor
        if show?.isMovie == true {
            downloadButton.addTarget(self, action: #selector(startDownload), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
        }
    }
    
    private func setupActorsCollection() {
        actorsCollection.delegate = self
        actorsCollection.dataSource = self
        actorsCollection.backgroundColor = .clear
        actorsCollection.allowsSelection = true
        
        actorsCollection.showsHorizontalScrollIndicator = false
        actorsCollection.showsVerticalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        actorsCollection.collectionViewLayout = layout
        
        actorsCollection.register(UINib(nibName: "ActorCell", bundle: nil), forCellWithReuseIdentifier: "ActorCell")
    }
    
    private func imdRating(number: Float) {
        for index in 0 ... 4 {
            if index < Int(number / 2) {
                UIView.animate(withDuration: 0.5) {
                    //let config = UIImage.SymbolConfiguration(hierarchicalColor: [.systemTeal])
                    self.imdbRatingCollectionImage[index].image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal)
                }
            }
            else {
                UIView.animate(withDuration: 0.5) {
                    self.imdbRatingCollectionImage[index].image = UIImage(systemName: "star")
                }
            }
        }
    }
        
    private func updateViews() {
        self.navigationItem.title = show?.title.uppercased()
        self.titleLabel.text = show?.title
        self.posterImageView.kf.setImage(with: show?.posterURL, options: [.transition(.fade(0.4))])
        self.yearLabel.text = show?.year
        self.imdbRatingLabel.text = show?.rating
        self.storyLabel.text = show?.description
        
        if let rating = show?.rating {
            self.imdRating(number: Float(rating) ?? 0)
        } else {
            self.imdRating(number: 0)
        }
        
        if let category = show?.category {
            self.category = category.id
        }
        
        self.tableView.reloadData()
        
        if let actors = show?.actors, !actors.isEmpty {
            actorsCollection.isHidden = false
            actorsLabel.isHidden = false
            actorsCollection.reloadData()
        } else {
            actorsCollection.isHidden = true
            actorsLabel.isHidden = true
        }
        
        if let writers = show?.writers, !writers.isEmpty {
            self.writersStackView.isHidden = false
            self.writesLabel.text = writers.joined(separator: ", ")
        } else {
            self.writersStackView.isHidden = true
        }
        
        if let directors = show?.directors, !directors.isEmpty {
            self.directorsLabel.isHidden = false
            self.directorsLabel.text = directors.joined(separator: ", ")
        } else {
            self.directorsStackView.isHidden = true
        }
        
        if let rating = show?.ageRating {
            self.mpaaRatingView.isHidden = false
            self.mapaaRatingLabel.text = rating
        } else {
            self.mpaaRatingView.isHidden = true
        }

        if let comments = show?.comments, let lastComment = comments.last {
                showMoreCommentsButton.isHidden = false
                lastCommentView.isHidden = false
                noCommentLabel.isHidden = true
                let numberOfComments = comments.count
                commentsNumberLabel.text = "(\(numberOfComments))"
                lastCommentUserLabel.text = lastComment.userName?.uppercased()
                lastCommentMessageLabel.text = lastComment.message.capitalized
            
            if let profileURL = lastComment.userProfileURL {
                commentProfileNameView.setImage(from: profileURL)
            } else if let name = lastComment.userName {
                commentProfileNameView.setFirstLetter(withName: name)
            }
                
            } else {
                commentsNumberLabel.text = "(0)"
                showMoreCommentsButton.isHidden = true
                lastCommentView.isHidden = true
                noCommentLabel.isHidden = false
            }
            
        if let show = show {
			favoriteBtn.isSelected = show.isInWatchLater == true
			subscribeBtn.isSelected = show.isSubscribed
        }
    }
    
    func handleWatchLaterAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.WatchLaterShow>.Response, Error>) {
        DispatchQueue.main.async { [self] in
			favoriteBtn.stopLoading()
            
            do {
                let _ = try result.get()
                show?.isInWatchLater.toggle()
				favoriteBtn.isSelected = show?.isInWatchLater == true
                HapticFeedback.lightImpact()
            } catch {
                tabBar?.alert.genericError()
            }
        }
    }
    
    private func toggleFav () {
        guard let show = show else {
            return
        }
        
        guard ShoofAPI.User.current != nil else {
			let loginVC = LoginViewController()
			if let tabBar = tabBar {
				tabBar.alert.loginFirstToFav { [weak self] in
					if let nav = self?.navigationController {
						nav.pushViewController(loginVC, animated: true)
						
						// when details is under player
					} else if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? RoundedTabBar {
						if let nav = tabBar.viewControllers?[tabBar.selectedIndex] as? UINavigationController {
							ChiefsPlayer.shared.minimize()
							nav.pushViewController(loginVC, animated: true)
						}
					}
				}
			} else {
				// If player presented
				if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? RoundedTabBar {
					if let nav = tabBar.viewControllers?[tabBar.selectedIndex] as? UINavigationController {
						ChiefsPlayer.shared.minimize()
						nav.pushViewController(loginVC, animated: true)
					}
				}
			}
            return
        }
		
		favoriteBtn.startLoading()
        
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
    
    private func getCategoryID (){
//        if let category = show?.details?.category.id {
//            self.category = category
//        }
//        self.category = show?.details?.category.id
//        let index = fullCategoriesData.map { $0.title }.firstIndex { $0 == passedShowItem.categoryStr }
//        let category = fullCategoriesData[Int(index ?? 0)]
//        self.category =  category.id
    }
    
    private func getMatchRate () -> String {
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
    
    // MARK: - NVAGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToComments" {
            if let destVC = segue.destination as? CommentsVC {
                destVC.passedComments = show?.comments ?? []
            }
        } else if segue.identifier == "segueToWriteComment" {
            if let destVC = segue.destination as? WriteCommentVC {
                destVC.show = self.show
            }
        }
    }
    
    // MARK: - ACTION
    @IBAction func payTapped() {
        guard ShoofAPI.shared.isInNetwork || downloadedItem else {
            tabBar?.alert.unableToPlay()
            return
        }
        
        guard let show = show else {
            return
        }
        
        watchButton.showActivityIndicator()
        tabBar?.play(show: show) { [weak self] in
            self?.watchButton.hideActivityIndicator()
        }
    }
    
    /// Website link of this show
    private var shareLink : URL? {
        get {
            return URL(string: "http://cn.shoof.show/ar/details?id=\(show?.id ?? "")")
        }
    }
    
    @IBAction func shareTapped (_ sender : VerticalButton) {
		guard let shareLink = shareLink else {
			return
		}
		
        let actitiviyController = UIActivityViewController(activityItems: [shareLink], applicationActivities:nil)
        actitiviyController.excludedActivityTypes = []
        actitiviyController.popoverPresentationController?.sourceView = sender
        actitiviyController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        actitiviyController.popoverPresentationController?.permittedArrowDirections = []
        self.present(actitiviyController, animated: true)
    }
    
    func handleSubscriptionAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.SubscribeShow>.Response, Error>?) {
        DispatchQueue.main.async { [self] in
            subscribeBtn.stopLoading()
            
			do {
                let result = try result?.get()
                show?.isSubscribed.toggle()
				subscribeBtn.isSelected = show?.isSubscribed == true
                HapticFeedback.lightImpact()
            } catch {
                print(error)
                tabBar?.alert.genericError()
            }
        }
    }
    
    @IBAction func handleSubscribe(sender: VerticalButton) {
        guard let show = show else {
            return
        }
        
        guard ShoofAPI.User.current != nil else {
            tabBar?.alert.loginToContinue { [weak self] in
                let loginVC = LoginViewController()
                self?.navigationController?.pushViewController(loginVC, animated: true)
            }
            
            return
        }
                
		subscribeBtn.startLoading()
		
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
    
    @IBAction func showTrailerTapped() {
        
        if !OpenURL.youtube(id: show?.youtubeID ?? "") {
            tabBar?.alert.genericError()
        }
        
    }
    
    @IBAction func addToFavTapped() {
        toggleFav()
    }
    
    @IBAction func writeComment () {
        guard ShoofAPI.User.current != nil else {
            tabBar?.alert.loginFirstToFav { [weak self] in
                let loginVC = LoginViewController()
                self?.navigationController?.pushViewController(loginVC, animated: true)
            }
            
            return
        }
        
        let commentsVC = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: "WriteCommentVC") as! WriteCommentVC
        commentsVC.show = show
        navigationController?.pushViewController(commentsVC, animated: true)
    }
	
	/// Download for movie only
    @objc func startDownload() {
        if downloadButton.downloadState != .toDownload {
            return
        }
        
        guard let show = show, let media = show.media, case .movie(let movie) = media else {
			return
		}

        let resolutions = movie.files.map { CPlayerResolutionSource(title: $0.resolution.description, nil, $0.url) }
        
		guard !resolutions.isEmpty else {
			tabBar?.alert.genericError()
			return
		}
		
        self.tabBar?.sheet.chooseDownloadResolution(sources: resolutions, selectedResolutionAction: { (selected) in
            self.startDownloading(selected, from: show)
        })
        
    }
    
	func startDownloading(_ source:CPlayerResolutionSource, from show: ShoofAPI.Show) {
        if downloadButton.downloadState == .toDownload {
            downloadButton.downloadState = .willDownload
            _ = DownloadManager.shared.download(show: show, source: source)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    var castEmpty: Bool {
        show?.directors?.isEmpty == true && show?.writers?.isEmpty == true && show?.actors?.isEmpty == true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return mode == .underPlayer ? 0 : UIDevice.current.userInterfaceIdiom == .pad ? 800 : 500 // Player cell
//        case 1: return tableView.estimatedRowHeight // Title Cell
        case 2: return mode == .loading ? 0 : tableView.estimatedRowHeight // Functions stack view (Favorite, Subscribe, etc).
        case 3: return show?.description == nil ? 0 : tableView.estimatedRowHeight // Story cell
        case 4:
            if mode == .loading {
                return 0
            }
            
            var rowHeight: CGFloat = 0
            if let actors = show?.actors, !actors.isEmpty {
                rowHeight += 240
            }
            
            if let writes = show?.writers, !writes.isEmpty {
                rowHeight += 50
            }
            
            if let directors = show?.directors, !directors.isEmpty {
                rowHeight += 50
            }
            return rowHeight
            
        case 5: return mode == .loaded ? tableView.estimatedRowHeight : 0 // Comments
        case 6: return  show?.relatedShows?.isEmpty ?? false ? 0 : tableView.estimatedRowHeight
        default: break
        }
        
        return tableView.estimatedRowHeight
    }
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let vw = UIView()
//        vw.backgroundColor = UIColor.clear
//        let titleLabel = UILabel(frame: CGRect(x:10,y: 5 ,width:350,height:150))
//        titleLabel.numberOfLines = 0;
//        titleLabel.lineBreakMode = .byWordWrapping
//        titleLabel.backgroundColor = UIColor.clear
//        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
//        titleLabel.text  = "Footer text here"
//        vw.addSubview(titleLabel)
//        return vw
//    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = SeasonsTVC()
//        
//
//        return cell
//    }
}

// MARK: - SHOWS COLLECTION DELEGATE
extension DetailsVC : ShowsCollectionViewDelegate {
    func showsCollectionView(_ colelctionView: ShowsCollectionView, shouldLoadPage pageNumber: Int, withFilter filter: ShoofAPI.Filter) {
        //
        
        if let relatedShows = show?.relatedShows {
            colelctionView.loadShows(shows: relatedShows, isLastPage: true)
        }
    }
    
    
    func showsCollectionView(_ collectionView: ShowsCollectionView, shouldLoadPage page: Int, genre: ShoofAPI.Genre?, year: String?, sortType: SortType?) {
        //
    }
    
    func showNoContentView() {
    }
}

// MARK: - NETWORK DELEGATE ( shows )
extension DetailsVC {
    
    func requestEnded() {
        
    }
    
    func failure() { }
    
    func noData() { }
    
    func success(result: ShowsLoadingSuccessResult) {
        showsCollection.isHidden = false
        view.hideNoContentView()
//        showsCollection.successBlock(result: result)
    }
}



extension DetailsVC {

    func detailsRequestEnded() {
        watchButton.hideActivityIndicator()
        matchButton.hideCustomActivityIndicator()
    }
    
    func detailsFailure() {
        if !downloadedItem {
            tabBar?.alert.genericError()
        }
    }
    
    func successWith(result: JSON) {
        HapticFeedback.lightImpact()
//        self.passedShowItem.setDetailsValues(from: result)
        actorsCollection.reloadData()
        mode = .loaded
        tableView.isScrollEnabled = true
        updateViews()
    }

}

// MARK: - NETWORK DELEGATE ( favorite )
extension DetailsVC {
    
    func favoriteEnded() {
		favoriteBtn.stopLoading()
    }
    
    func favoriteFailure() {
		favoriteBtn.stopLoading()
        tabBar?.alert.genericError()
    }
    
    func successfullyAdded() {
        HapticFeedback.lightImpact()
		favoriteBtn.isSelected = true
    }
    
    func successfullyRemoved() {
        HapticFeedback.lightImpact()
		favoriteBtn.isSelected = false
    }
    
}


// MARK: - ACTORS COLLECTION
extension DetailsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // ROWS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return show?.actors?.count ?? 0
    }
    
    // CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActorCell", for: indexPath) as! ActorCell
        if let indexedActor = show?.actors?[indexPath.row] {
            cell.configure(item: indexedActor)
        }
        return cell
    }
    
    // SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 90, height: actorsCollection.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let actor = show?.actors?[indexPath.row] {
            if let showsVC = UIStoryboard(name: "HomeSB", bundle: nil)
                .instantiateViewController(withIdentifier: String(describing: ShowsVC.self)) as? ShowsVC {
                showsVC.title = actor.name.uppercased()
                showsVC.type = .actor(id: actor.id, name: actor.name)
                
                if let nav = navigationController {
                    nav.pushViewController(showsVC, animated: true)
                }
				
                // If details view is under player
                else if let tabBar = UIApplication.shared.keyWindow?.rootViewController as? RoundedTabBar,
                          let vcs = tabBar.viewControllers
                {
                    ChiefsPlayer.shared.minimize()
                    if tabBar.selectedIndex < vcs.count {
                        let selVC = vcs[tabBar.selectedIndex]
                        
                        if let nav = selVC as? UINavigationController {
							nav.pushViewController(showsVC, animated: true)
                        }
                    }
                }
            }
        }
    }
}

class ActorCell : UICollectionViewCell {
    
    
    @IBOutlet weak var actorFrame: UIView!
    @IBOutlet weak var actorImage: UIImageView!
    @IBOutlet var nameLabel : UILabel!
    
    override func awakeFromNib() {
        self.actorImage.layer.cornerRadius = 25
        self.actorImage.clipsToBounds = true
    }

//    func configure(item: String) {
//        nameLabel.text = item.capitalized
//    }
    
    public func configure(item : ShoofAPI.Actor) {
        actorFrame.layer.cornerRadius = CGFloat(25)
        actorFrame.layer.borderWidth = 1
        actorFrame.layer.borderColor = UIColor(red: 0.712, green: 0.012, blue: 0.012, alpha: 1).cgColor
        actorFrame.clipsToBounds = true
        nameLabel.text = item.name.capitalized
        self.actorImage.kf.setImage(with: item.imageURL, options: [.transition(.fade(0.4))])
    }
}



extension DetailsVC: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
//        if !item.isInvalidated {
//            if item.show_id == show?.id {
//                self.downloadButton.downloadPercent = CGFloat(downloadModel.progress)
//            }
//        }
        
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {

    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        if let key = primaryKey as? String, let movie_id = show?.id {
            if key.contains("\(movie_id)") {
                self.downloadButton.downloadState = .toDownload
            }
        }
    }
}
