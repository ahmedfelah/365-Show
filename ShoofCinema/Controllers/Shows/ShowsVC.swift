//
//  MoviesVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/21/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class ShowsVC: MasterVC {

    // MARK: - VARS
    var category : Int = 0
//    var actorName : String = ""
//    var sectionID: Int?
//    var actorID: Int?
    
    enum `Type` {
        case section(id: String)
        case actor(id: Int, name: String)
//        case explore(ShoofAPI.Explore)
        case filter(ShoofAPI.Filter)
        case shows([ShoofAPI.Show])
    }
    
    var type: `Type`?
    
    var passedSectionItem : SectionDataCM?
    
    lazy var collectionView = ShowsCollectionView(frame: view.bounds, scrollDirection: .vertical)
    
    let shoofAPI = ShoofAPI.shared
    
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.showsDelegate = self
//        return m
//    }()
    
    // MARK: - LOAD

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView = ShowsCollectionView(frame: view.bounds, scrollDirection: .vertical)
        collectionView.showsDelegate = self
        setupSubViews()
        
        collectionView.showHeader = false
        
        if case .filter(let filter) = type {
            collectionView.filter = filter
            let filterButton = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(handleFilterButtonTap))
            navigationItem.rightBarButtonItem = filterButton
        }
        
        collectionView.startLoading()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)
    }
    
    
    
    @objc func handleFilterButtonTap(sender: UIBarButtonItem) {
        guard case .filter(let filter) = type else {
            return
        }
        
        let vc = FilterViewController(filter: filter)
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        tabBar?.present(vc, animated: false)
    }
    
    // MARK: - PRIVATE
    private func setupSubViews() {
        super.setupViews()
        navigationController?.setNavigationBarHidden(false, animated: true)

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints({
            $0.size.equalToSuperview()
        })
    }

}

extension ShowsVC: FilterViewControllerDelegate {
    func filterViewController(_ filterViewController: FilterViewController, didSelectFilter filter: ShoofAPI.Filter) {
        self.type = .filter(filter)
        collectionView.filter = filter
        collectionView.reloadWithFilter()
        navigationItem.rightBarButtonItem?.tintColor = Theme.current.tintColor
        navigationItem.title = NSLocalizedString("explore", comment: "")
    }
}

extension ShowsVC : ShowsCollectionViewDelegate {
    
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Show]>.Response, Error>) {
        do {
            let response = try result.get()
            let shows = response.body
            
            print("Loaded page \(response.currentPage) of \(response.numberOfPages).")
            
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.view.hideNoContentView()
                self.collectionView.loadShows(shows: shows, isLastPage: response.isOnLastPage)
            }
        } catch is URLError {
            DispatchQueue.main.async {
                self.tabBar?.alert.genericError()
            }
        } catch {
            DispatchQueue.main.async {
                self.collectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
            }
        }
    }
    
    func showsCollectionView(_ colelctionView: ShowsCollectionView, shouldLoadPage pageNumber: Int, withFilter filter: ShoofAPI.Filter) {
//        if showsType == .category {
//            networkManager.getShows(category: category ?? self.category, page: page, sorting: sort, sortingType: sortType , year: year, genre: genre)
//        } else if showsType == .actor {
//            networkManager.getShowsByActor(actorName: actorName, page: page, sorting: sort, sortingType: sortType, year: year, genre: genre)
//        } else if showsType == .tag {
//            networkManager.getHomeShows(tag: self.tag, page: page)
//        } else if showsType == .tabId {
//            networkManager.getShowsByTagID(tagId: self.tagId, page: page, sorting: sort, sortingType: sortType, year: year, genre: genre)
//        }
        switch type {
        case .section(let sectionID):
            shoofAPI.loadMoreShows(forSectionWithID: sectionID, pageNumber: pageNumber) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
            
        case .actor(let actorID, _):
            shoofAPI.loadShows(forActorWithID: actorID, pageNumber: pageNumber) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        case .filter:
            shoofAPI.loadShows(withFilter: filter, pageNumber: pageNumber) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        case .shows(let shows):
            DispatchQueue.main.async { [self] in
                collectionView.isHidden = false
                view.hideNoContentView()
                collectionView.loadShows(shows: shows, isLastPage: true)
            }
        default: break
        }
    }

    func showNoContentView() {
        collectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
    }
}


// MARK: - NETWORK DELEGATE
extension ShowsVC {
    
    func requestEnded() {
        
    }
     
    func failure() {
        tabBar?.alert.genericError()
    }
    
    func noData() {
        collectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
    }
    
    func success(result: ShowsLoadingSuccessResult) {
        collectionView.isHidden = false
        view.hideNoContentView()
//        collectionView.successBlock(result: result)
    }
}

fileprivate extension String {
    static let moviesNavTitle = NSLocalizedString("moviesNavTitle", comment: "")
    static let TVNavTitle = NSLocalizedString("TVNavTitle", comment: "")
}


