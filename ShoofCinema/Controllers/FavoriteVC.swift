//
//  FavoriateVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/24/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NotificationCenter
class FavoriteVC: MasterVC {
    
    var showsCollectionView : ShowsCollectionView!
    let refreshControl : UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Theme.current.tintColor
        return rc
    }()
    
    var isLoggedIn : Bool {
        return Account.shared.token != nil
    }
    
    /// Changed after user login state change and view is disappeared
    var shouldReloadDataOnAppear : Bool = false
    var isAppeared : Bool = false
    
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.showsDelegate = self
//        return m
//    }()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload after appear, because reloading disappeared collection view causes a crash
        if shouldReloadDataOnAppear {
            reloadData()
            shouldReloadDataOnAppear = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppeared = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppeared = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
                
        showsCollectionView = ShowsCollectionView(frame: view.bounds, scrollDirection: .vertical)
        showsCollectionView.showsDelegate = self
        showsCollectionView.showHeader = false
        
        setupSubViews()
        showsCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
         
        NotificationCenter.default.addObserver(forName: .userDidChange, object: nil, queue: nil) { [weak self] (_) in
            
            if self?.isAppeared == true {
                self?.reloadData()
            } else {
                self?.shouldReloadDataOnAppear = true
            }
        }
        
        reloadData()
    }
    
    func setupSubViews() {
        view.addSubview(showsCollectionView)
        showsCollectionView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
    }
    
    @objc private func reloadData() {
        showsCollectionView.reloadWithFilter()
    }
    
    private func segueToLogin() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }

}



extension FavoriteVC : ShowsCollectionViewDelegate {
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.WatchLaterShow]>.Response, Error>) {
        do {
            let response = try result.get()
            let shows = response.body.compactMap(\.show)
            
            print("Loaded page \(response.currentPage) of \(response.numberOfPages).")
            
            DispatchQueue.main.async { [self] in
                showsCollectionView.isHidden = false
                showsCollectionView.hideNoContentView()
//                let isLastPage = response.isOnLastPage || (response.currentPage == 0 && response.numberOfPages == 1)
                showsCollectionView.loadShows(shows: shows, isLastPage: response.isOnLastPage)
            }
        } catch let error as URLError {
            DispatchQueue.main.async { [self] in
                if error.code == .userAuthenticationRequired {
                    showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentNotLoggedInMessage, imageName: "ic-no-fav-icon", actionButtonTitle: .loginButtonTitle, action: segueToLogin)
                } else {
                    tabBar?.alert.genericError()
                 }
            }
        } catch {
            DispatchQueue.main.async { [self] in
                showsCollectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .noMatchesMessage, imageName: .sadFaceIcon, actionButtonTitle: nil, action: nil)
            }
        }
        
        DispatchQueue.main.async { [self] in
            refreshControl.endRefreshing()
        }
    }
    
    func showsCollectionView(_ colelctionView: ShowsCollectionView, shouldLoadPage pageNumber: Int, withFilter filter: ShoofAPI.Filter) {
        guard ShoofAPI.User.current != nil else {
            showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentNotLoggedInMessage, imageName: "ic-no-fav-icon", action: {})
            return
        }
        
        ShoofAPI.shared.loadWatchLaterShows(pageNumber: pageNumber) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    func showNoContentView() {
        showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentMessage, imageName: "ic-no-fav-icon", actionButtonTitle: nil, action: nil)
    }
}

// MARK: - NETWORK DELEGATE
extension FavoriteVC {
    
    func requestEnded() {
        refreshControl.endRefreshing()
    }
     
    func failure() {
        showsCollectionView.showCollectionNoContentView(title: .genericErrorTitle, message: .genericErrorMessage, imageName: .sadFaceIcon, actionButtonTitle: .tryAgainButtonTitle, action: reloadData)
    }
    
    func noData() {
        if isLoggedIn {
            showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentMessage, imageName: "ic-no-fav-icon", actionButtonTitle: .reloadButtonTitle, action: reloadData)
        } else {
            showsCollectionView.showCollectionNoContentView(title: .favoriteNoContentTitle, message: .favoriteNoContentNotLoggedInMessage, imageName: "ic-no-fav-icon", actionButtonTitle: .loginButtonTitle, action: segueToLogin)
        }
    }
    
    func success(result: ShowsLoadingSuccessResult) {
        showsCollectionView.hideNoContentView()
//        showsCollectionView.successBlock(result: result)
    }
}



fileprivate extension String {
    static let reloadButtonTitle = NSLocalizedString("reloadButtonTitle", comment: "")

    static let loginButtonTitle = NSLocalizedString("loginButtonTitle", comment: "")
    static let favoriteNoContentTitle = NSLocalizedString("favoriteNoContentTitle", comment: "")
    static let favoriteNoContentMessage = NSLocalizedString("favoriteNoContentMessage", comment: "")
    static let favoriteNoContentNotLoggedInMessage = NSLocalizedString("favoriteNoContentNotLoggedInMessage", comment: "")
}



