//
//  HomeVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/20/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import FSPagerView
import RealmSwift

class HomeVC: MasterVC {
    
    // MARK: - LINKS
    @IBOutlet weak var sectionsCollection : UICollectionView!
    
    typealias Page =  ShoofAPI.Endpoint<[ShoofAPI.Section]>.Target
    
    var headerSection : HomeSection?
    
    /// All home sections loaded by the API, including the 'Featured' section.
    var homeSections: [ShoofAPI.Section] = []
    var moviesSections: [ShoofAPI.Section] = []
    var seriesSections: [ShoofAPI.Section] = []
    
    /// 'Featured' section to be displayed in the header area
    var featuredSection: ShoofAPI.Section? {
        sections.first(where: { $0.style == .featured && !$0.shows.isEmpty })
    }
        
    /// Sections excluding the 'Featured' section.
    var displayedSections: [ShoofAPI.Section] {
        sections.filter { $0.style != .featured && !$0.shows.isEmpty} 
    }
    
    lazy var historySection: ShoofAPI.Section = {
        return ShoofAPI.Section(id: "History-Section", title: NSLocalizedString("WatchHistory", comment: ""), style: .history, shows: recentShows?.map { $0.asShoofShow() } ?? [], actions: nil)
    }()
    
    // MARK: - VARS
    
    var homePage = 1
    var moviesPage = 1
    var showsPage = 1
    var hasHomeNextPage = true
    var hasMoviesNextPage = true
    var hasSeriesNextPage = true
    
    lazy var recentShows = RealmManager.recentShowsList()
    var recentShowsObserver : NotificationToken?
    
    /// Displayed sections according to selected page (Home, Movies, TV Shows)
    var sections: [ShoofAPI.Section] {
        get {
            switch selectedPage {
            case .home:
                if !historySection.shows.isEmpty, !homeSections.isEmpty, !ShoofAPI.User.ramadanTheme {
                    var sections = homeSections
                    sections.insert(historySection, at: 1)
                    return sections
                } else {
                    return homeSections
                }
            case .movies: return moviesSections
            case .shows: return seriesSections
            }
        }
        
        set {
            switch selectedPage {
            case .home: homeSections = newValue
            case .movies: moviesSections = newValue
            case .shows: seriesSections = newValue
            }
        }
    }
    
    var nextPage: Int {
        get {
            switch selectedPage {
            case .home: return homePage
            case .movies: return moviesPage
            case .shows: return showsPage
            }
        }
        
        set {
            switch selectedPage {
            case .home: homePage = newValue
            case .movies: moviesPage = newValue
            case .shows: showsPage = newValue
            }
        }
    }
    
    var hasNextPage: Bool {
        get {
            switch selectedPage {
            case .home: return hasHomeNextPage
            case .movies: return hasMoviesNextPage
            case .shows: return hasSeriesNextPage
            }
        }
        
        set {
            switch selectedPage {
            case .home: hasHomeNextPage = newValue
            case .movies: hasMoviesNextPage = newValue
            case .shows: hasSeriesNextPage = newValue
            }
        }
    }
    
    var isLoadingNextPage  = false {
        didSet {
            if isLoadingNextPage {
                footerView?.showIndicator()
            } else {
                footerView?.hideIndicator()
            }
        }
    }
    
    var cachedPosition = Dictionary<IndexPath,CGPoint>()
    
    var headerView : HomeHeaderView?
    var footerView : HomeFooter?
    
    var selectedPage : Page = .home
    
    let shoofAPI = ShoofAPI.shared
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupMainCollection()
        
        if let result = result {
            handleAPIResponse(result: result)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] (_) in
                self?.sectionsCollection.collectionViewLayout.invalidateLayout()
            }
        }
        
        recentShowsObserver = recentShows?.observe(on: .main) { [weak self] change in
            switch change {
            case .initial(let shows):
                self?.historySection.shows = shows.sorted(by: { $0.creationDate > $1.creationDate }).map { $0.asShoofShow() }
            case .update(let shows, deletions: _, insertions: _, modifications: _):
                self?.historySection.shows = shows.sorted(by: { $0.creationDate > $1.creationDate }).map { $0.asShoofShow() }
            default: break
            }
            
            self?.sectionsCollection.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.removeStatusBar()
        super.viewWillAppear(animated)
        
    }
    
    
    override func setupViews() {
        super.setupViews()
        addGradientNav()
    }
    
    private func setupMainCollection () {
        sectionsCollection.delegate = self
        sectionsCollection.dataSource = self
        sectionsCollection.backgroundColor = Theme.current.backgroundColor
        sectionsCollection.showsVerticalScrollIndicator = false
        sectionsCollection.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            sectionsCollection.contentInsetAdjustmentBehavior = .never
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 30
        sectionsCollection.collectionViewLayout = layout
        sectionsCollection.register(UINib(nibName: .sectionCellNibName, bundle: nil), forCellWithReuseIdentifier: .sectionCellID)
        sectionsCollection.register(UINib(nibName: .headerNibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader ,withReuseIdentifier: .headerID)
        sectionsCollection.register(UINib(nibName: .footerNibName, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter ,withReuseIdentifier: .footerID)
    }

    override func didReceiveMemoryWarning() {
        #if DEBUG
            sectionsCollection.reloadData()
        #endif
        
    }
    
    private func showFilterActionSheet() {
        let filter = UIAlertController(title: NSLocalizedString("filter", comment: ""), message: nil, preferredStyle: .actionSheet)
        filter.addAction(UIAlertAction(title: NSLocalizedString("home", comment: ""), style: .default) {_ in
            self.setHomePage(.home)
        })
        filter.addAction(UIAlertAction(title: NSLocalizedString("movies", comment: ""), style: .default) {_ in
            self.setHomePage(.movies)
        })
        filter.addAction(UIAlertAction(title: NSLocalizedString("series", comment: ""), style: .default) {_ in
            self.setHomePage(.shows)
        })
        filter.addAction(UIAlertAction(title: NSLocalizedString("cancelAlertButton", comment: ""), style: .cancel))
        
        present(filter, animated: true)
    }
    
    @IBAction func handleHeaderPageButton(_ sender: UIButton) {
        if let showsVC = UIStoryboard(name: "HomeSB", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: ShowsVC.self)) as? ShowsVC {
            showsVC.type = .filter(ShoofAPI.Filter(categoryID: nil, tagID: nil, rate: nil, mediaType: .all))
            showsVC.navigationItem.title = NSLocalizedString("explore", comment: "")
            navigationController?.pushViewController(showsVC, animated: true)
        }
    }

    @IBAction func handleMoreButtonTap(_ sender: UIButton) {
        if let showsVC = UIStoryboard(name: "HomeSB", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: ShowsVC.self)) as? ShowsVC {
            
            let section = displayedSections[sender.tag]
            showsVC.title = section.title
            
            if section == historySection {
                showsVC.type = .shows(section.shows)
            } else {
                if let actions = section.actions {
                    showsVC.type = .filter(ShoofAPI.Filter(genreID: actions.genreId, categoryID: actions.categoryId, tagID: actions.tagId, rate: ShoofAPI.Filter.convertToString(from: actions.rate), year: ShoofAPI.Filter.convertToString(from: actions.year), mediaType: actions.isMovie ?? .all, sortType: actions.sortType))
                } else {
                    showsVC.type = .section(id: section.id)
                }
            }
            
            navigationController?.pushViewController(showsVC, animated: true)
        }
    }
    
    @IBAction func handleMoonButton(_ sender: Any) {
        tabBar?.alert.changeMode { [weak self] in
            // change mode
            let viewController = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoadingVC.self)) as! LoadingVC
    
            ShoofAPI.User.ramadanTheme = !ShoofAPI.User.ramadanTheme
            Theme.current = ShoofAPI.User.ramadanTheme ? LightTheme() : DarkTheme()
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
            
        }
    }
    
    func loadNextPage () {
        guard hasNextPage, !isLoadingNextPage else {
            return
        }
        
        isLoadingNextPage = true
                
        shoofAPI.loadSections(withTarget: selectedPage, pageNumber: nextPage) { [weak self] result in
            do {
                let response = try result.get()
                self?.hasNextPage = !response.isOnLastPage
                self?.nextPage += 1
                DispatchQueue.main.async {
                    self?.sections.append(contentsOf: response.body)
                    self?.sectionsCollection.reloadData()
                }
            } catch {
                print("ERROR!", error)
            }
            
            DispatchQueue.main.async {
                self?.isLoadingNextPage = false
            }
        }
    }
    
    private func fadeAnimation () {
        view.layer.opacity = 0
        UIView.animate(withDuration: 0.7, animations: {
            self.view.layer.opacity = 1
        })
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let showsType = sender as? ShowsType else {return}
//        if segue.identifier == "segueToShows" {
//            if let destVC = segue.destination as? ShowsVC {
//                destVC.showsType = showsType
//            }
//        }
    }
    
    func setHomePage(_ page: Page) {
        cachedPosition = [:]
        self.selectedPage = page
        
        fadeAnimation()
        
        guard sections.isEmpty else {
            sectionsCollection.reloadData()
            return
        }
        
        sectionsCollection.isHidden = true
        view.hideNoContentView()
        showHUD()
        
//        if let result = result {
//            handleAPIResponse(result: result)
//        }
//
        shoofAPI.loadSections(withTarget: page, pageNumber: nextPage, completionHandler: handleAPIResponse)
    }
    
    var result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>?
}

extension HomeVC {
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>) {
        do {
            let response = try result.get()

            self.hasNextPage = !response.isOnLastPage
            self.nextPage += 1
            let sections = response.body

            DispatchQueue.main.async { [self] in
                self.sections = sections
                self.sectionsCollection.isHidden = false
                self.sectionsCollection.reloadData()
                self.hideHUD()
            }
        } catch {
            print("ERROR!", error)
        }
    }
}

extension HomeVC : SectionCellActionDelegate {
    
    func moreTapped(section : HomeSection) {
        
        if let showsVC = UIStoryboard(name: "HomeSB", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: ShowsVC.self)) as? ShowsVC {
            if section.tag != "" {
//                showsVC.showsType = .tag
                showsVC.title = section.title
//                showsVC.tag = section.tag
            } else if section.category != 0 {
//                showsVC.showsType = .category
                showsVC.category = section.category
                showsVC.title = section.title
            } else if section.tagID != 0 {
//                showsVC.showsType = .tabId
//                showsVC.tagId = section.tagID
                showsVC.title = section.title
            }
            navigationController?.pushViewController(showsVC, animated: true)
        }
    }
}

fileprivate extension String {
    static let sectionCellNibName = "SectionCell"
    static let sectionCellID = "sectionCellID"
    static let headerNibName = "HomeHeader"
    static let headerID = "headerID"
    static let footerNibName = "HomeFooter"
    static let footerID = "footerID"
}
