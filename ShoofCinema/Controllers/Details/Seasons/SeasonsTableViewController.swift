//
//  SeasonsTableViewController.swift
//  
//
//  Created by Husam Aamer on 5/1/18.
//

import UIKit
import RealmSwift

class SeasonsTV: UITableView {
    // MARK: - VARS
    var show: ShoofAPI.Show
    
    var parentVC: VideoPlayerViewController?
    
    var seasons: [ShoofAPI.Media.Season] {
        switch show.media {
        case .series(seasons: let seasons): return seasons
        default: return []
        }
    }
    
    private(set) var episodes: [ShoofAPI.Media.Episode] = []
    
    private var selectedSeasonIndex: Int = 0
    private var selectedEpisodeIndex: Int = 0
	private var selectedEpisodeId: String = ""
	
    private var currentEpisodesPage: Int = 1
    private var hasNextPage: Bool = true
    private var isLoading: Bool = false
    
    var currentSeason: ShoofAPI.Media.Season? {
        guard seasons.indices.contains(selectedSeasonIndex) else {
            return nil
        }
        
        return seasons[selectedSeasonIndex]
    }
    
    var currentEpisode: ShoofAPI.Media.Episode? {
        get {
            guard episodes.indices.contains(selectedEpisodeIndex) else {
                return nil
            }
            
            return episodes[selectedEpisodeIndex]
        }
        
        set {
            guard let newValue = newValue, let episodeIndex = episodes.firstIndex(of: newValue) else {
                return
            }
            
            selectedEpisodeIndex = episodeIndex
			selectedEpisodeId = episodes[episodeIndex].id
			
            reloadData()
        }
    }
    
    var nextEpisode: ShoofAPI.Media.Episode? {
        let episodeIndex = selectedEpisodeIndex + 1
        
        guard episodes.indices.contains(episodeIndex) else {
            return nil
        }
        
        return episodes[episodeIndex]
    }
    
    var previousEpisode: ShoofAPI.Media.Episode? {
        let episodeIndex = selectedEpisodeIndex - 1
        
        guard episodes.indices.contains(episodeIndex) else {
            return nil
        }
        
        return episodes[episodeIndex]
    }
    
    var hasNextEpisode: Bool {
        episodes.indices.contains(selectedEpisodeIndex + 1)
    }
    
    var hasPreviousEpisode: Bool {
        episodes.indices.contains(selectedEpisodeIndex - 1)
    }
    
    var rmEpisodes:Results<RDownload>!
    
    
	typealias EpisodeLocation = (RmEpisodeIndex:Int,EpisodeSeasonId: String? ,EpisodeIndex:IndexPath?)
    typealias EpisodeId = String
    var downloadingIndexes:[EpisodeId:EpisodeLocation] = [:]
    public var isDeletingEpisdoe: EpisodeId?
        
    // MARK: - INIT
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init from storyboard is not allowed")
    }
    
    init(show: ShoofAPI.Show, seasonIndex: Int = 0, episodeIndex: Int = 0, episodes: [ShoofAPI.Media.Episode]) {
        self.show = show
        self.selectedSeasonIndex = seasonIndex
        self.selectedEpisodeIndex = episodeIndex
		if episodes.indices.contains(episodeIndex) {
			self.selectedEpisodeId = episodes[episodeIndex].id
		}
        self.episodes = episodes
        
        super.init(frame: .zero, style: .plain)
        setupTableView()
        
        rmEpisodes = realm.objects(RDownload.self).filter("show_id = %i and isSeriesHeader = false", show.id)
        
        for (index, episode) in rmEpisodes.enumerated() {
            downloadingIndexes[episode.episode_id!] = (index, nil, nil)
        }
        
        if !isOutsideDomain {
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
    }
    
    func setupTableView () {
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = Theme.current.backgroundColor
        register(UINib(nibName: "EpisodeCell", bundle: nil), forCellReuseIdentifier: "EpisodeCell")
        register(UINib(nibName: "SeasonsHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "SeasonsHeader")
    }
    
    // MARK: - PRIVATE
    private func didSelectDownloadButton(at indexPath: IndexPath, for episode: ShoofAPI.Media.Episode, in season: ShoofAPI.Media.Season) {
        if let parentVC = parentVC {
            let sources = episode.files.map { file in
                CPlayerResolutionSource(title: file.resolution.description, nil, file.url)
            }
            
            var actions = [UIAlertAction]()
            
            #if DEBUG
            let source = CPlayerResolutionSource(title: "Test", nil, URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/dash/BigBuckBunnyAudio.mp4"))
            let action = UIAlertAction(title: source.title, style: .default, handler: { _ in
                self.startDownloading(source, from: episode, in: season, at: indexPath)
            })
            actions.append(action)
            #endif
            
            
            for source in sources.filter({$0.source_file != nil}) {
                let action = UIAlertAction(title: source.title, style: .default, handler: { _ in
                    self.startDownloading(source, from: episode, in: season, at: indexPath)
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
            
            alert.popoverPresentationController?.sourceView = self
            alert.popoverPresentationController?.sourceRect = rectForRow(at: indexPath)
            actions.forEach({alert.addAction($0)})
            parentVC.dismiss(animated: true)
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
    
    private func startDownloading(_ source:CPlayerResolutionSource, from episode: ShoofAPI.Media.Episode, in season: ShoofAPI.Media.Season, at indexPath:IndexPath) {
        ///Append this indexPath after successfully adding new rmDownloadShow
        ///This will trigger realm observer in this class
        
        let cell = cellForRow(at: indexPath) as? EpisodeCell
        cell?.downloadButton.isHidden = true
        cell?.downloadProgress.isHidden = false
        
        let rmEpisodeFutureIndexIfAdded = self.rmEpisodes.count
		self.downloadingIndexes[episode.id] = (rmEpisodeFutureIndexIfAdded, currentSeason?.id ?? "Any", indexPath)
        let isAdded = DownloadManager.shared.download(episode,in: season, show: self.show, source: source) != nil
        if !isAdded {
            self.downloadingIndexes.removeValue(forKey: episode.id)
        }
    }
    
}

// MARK: - Table view data source
extension SeasonsTV :  UITableViewDelegate, UITableViewDataSource {
    
    // SECTIONS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // ROWS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (episodes.count - 1) {
            loadNextPage()
        }
    }
    
    // CELL
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        cell.actionDelegate = self
//        let season = seasons[selectedSeasonIndex]
        let episode = episodes[indexPath.row]
//        cell.episodeNumberLabel.text = episode.number.description
        
//        let progress: Float = 0
        
//        cell.configure(episode: episode, index: indexPath.row, progress: progress, downloadProgress: progress, downloadStatus: downloadStatus)
//
        var progress : Float = 0.0
        if let rm = RealmManager.rmContinueForPlayingShow(with: show.id, with: episode) {
            progress = Float(rm.left_at_percentage)
        }

        downloadingIndexes[episode.id]?.EpisodeIndex = indexPath
//
//
//        /// Update download button to current episode status
        var downloadProgress : CGFloat = 0
        var downloadStatus : DownloadStatus = .failed
        if let rmIndex = downloadingIndexes[episode.id] {
            if rmIndex.RmEpisodeIndex < rmEpisodes.count {
                let rm = rmEpisodes[rmIndex.RmEpisodeIndex]
                downloadProgress = CGFloat(rm.progress)
                downloadStatus = rm.statusEnum

            }
        }
        
        cell.configure(episode: episode,
                       index: indexPath.row,
                       progress: progress,
                       isSelected: tableView.indexPathForSelectedRow == indexPath,
                       downloadProgress: downloadProgress,
                       downloadStatus: downloadStatus)
        		
		if selectedEpisodeId == episode.id {
			tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    // HEIGHT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    // HEADER
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let seasonsHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SeasonsHeader") as? SeasonTableHeaderView
        seasonsHeader?.seasons = seasons
        seasonsHeader?.seasonCollection.delegate = self
        seasonsHeader?.seasonCollection.dataSource = self
        seasonsHeader?.seasonCollection.selectItemAt(row: selectedSeasonIndex, scrollPosition: .centeredHorizontally)
        return seasonsHeader
    }

    // HEADER HEIGHT
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 175
    }
    
    // WILL SELECT
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let t = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [t], with: .none)
        }
        return indexPath
    }
    
    // DID SELECT
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEpisodeIndex = indexPath.row
        
        if let currentEpisode = currentEpisode, let vc = parentVC {
			self.selectedEpisodeId = currentEpisode.id
            vc.play(episode: currentEpisode, from: show)
            

        }
    }
    
    func loadEpisodes(forSeasonWithID seasonID: String) {
        guard let vc = parentVC else {
            return
        }
                
        isLoading = true
        
        vc.loadEpisodes(forSeasonWithID: seasonID, pageNumber: currentEpisodesPage + 1) { [weak self] result in
            DispatchQueue.main.async {
                
				guard let `self` = self else {return}
				
				let response = try? result.get()
				let episodes : [ShoofAPI.Media.Episode] = response?.body ?? self.seasons.first(where: {$0.id == seasonID})?.episodes ?? []// body or downloaded episodes
				
				
				if let response = response {
					self.hasNextPage = !response.isOnLastPage
				} else {
					self.hasNextPage = false
				}
				self.currentEpisodesPage += 1
				
				DispatchQueue.main.async {
					self.episodes = episodes
					if self.currentSeason?.id == seasonID {
						self.reloadData()
					}
				}
                
                self.isLoading = false
            }
        }
    }
    
    func loadNextPage() {
        guard let currentSeason = currentSeason else {
            return
        }
        
        guard let vc = parentVC else {
            return
        }
        
        guard hasNextPage, !isLoading else {
            return
        }
        
        isLoading = true
        
        vc.loadEpisodes(forSeasonWithID: currentSeason.id, pageNumber: currentEpisodesPage + 1) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let response = try result.get()
                    self?.hasNextPage = !response.isOnLastPage
                    self?.currentEpisodesPage += 1
                    DispatchQueue.main.async {
                        self?.episodes.append(contentsOf: response.body)
                        self?.reloadData()
                    }
                } catch {
                    
                }
                
                self?.isLoading = false
            }
        }
//        loadEpisodes(forSeasonWithID: currentSeason.id)
    }
}

extension SeasonsTV : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    /// ROWS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seasons.count
    }
    
    /// CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonCell",for : indexPath) as! SeasonCell
        cell.configure(index: indexPath.row)
        
        if episodes.isEmpty, indexPath.row == selectedSeasonIndex, let currentSeason = currentSeason {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            loadEpisodes(forSeasonWithID: currentSeason.id)
        }
        
        return cell
    }
    
    /// SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 50)
    }
    
    /// SELECT
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSeasonIndex = indexPath.row
        currentEpisodesPage = 0
        episodes.removeAll()
        reloadData()
        
        if let currentSeason = currentSeason {
            loadEpisodes(forSeasonWithID: currentSeason.id)
        }
    }
}

// MARK: - EPISODE CELL ACTION DELEGATE
extension SeasonsTV : EpisodeCellActionDelegate {
    func didTapDownloadButton(for episode: ShoofAPI.Media.Episode, at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        didSelectDownloadButton(at: indexPath,
								for: episode,
								in: self.seasons[selectedSeasonIndex])
    }
}


// MARK: - DOWNLOAD MANAGER ACTION DELEGATE
extension SeasonsTV: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
		
        if let episodeID = item.episode_id {
			guard let seasonId = downloadingIndexes[episodeID]?.EpisodeSeasonId,
				  let currentSeason = currentSeason,
				  seasonId == currentSeason.id else {
				return
			}
			
            guard let indexPath = downloadingIndexes[episodeID]?.EpisodeIndex else {
                return
            }
            
            
            guard let cell = cellForRow(at: indexPath) as? EpisodeCell else {
                return
            }
            
            let progress = CGFloat(downloadModel.progress)
            
            cell.configureDownloadStatus(progress: progress, status: .downloading)
        }
    }

    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {

    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
        guard let episodeId = item.episode_id else {
            return
        }

        isDeletingEpisdoe = episodeId
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        /// Update cell and refresh `downloadingIndexes` order
        guard let episodeId = isDeletingEpisdoe,
            let path = downloadingIndexes[episodeId]?.EpisodeIndex else
        {
            return
        }
        
        if let cell = self.cellForRow(at: path) as? EpisodeCell
        {
            cell.downloadButton.isHidden = false
            cell.downloadProgress.isHidden = true
            
        }
        
        // Remove keys from global dictionary
        downloadingIndexes.removeValue(forKey: episodeId)
        
        //Reset catched indexes
        for (newIndex,rm) in rmEpisodes.enumerated() {
            self.downloadingIndexes[rm.episode_id!]?.RmEpisodeIndex = newIndex
        }
        
        ///Ok we don't need it any more
        isDeletingEpisdoe = nil
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        guard let episodeId = item.episode_id,
            let path = downloadingIndexes[episodeId]?.EpisodeIndex else
        {
            return
        }
        
        if let cell = self.cellForRow(at: path) as? EpisodeCell {
            cell.configureDownloadStatus(progress: 0.0, status: item.statusEnum)
        }
    }
}
