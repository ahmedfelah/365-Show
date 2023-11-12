//
//  HistoryVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/18/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RemoteHistoryVC: MasterVC {
    
    // MARK: - LINKS
    @IBOutlet weak var indicator : NVActivityIndicatorView!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var moreNavItem : MainNavBarItem!
    let refreshControl : UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = Theme.current.tintColor
        return rc
    }()
    
    // MARK: - VARS
    var showsList = [HomeSectionList]() {
        didSet {
            if showsList.isEmpty && !isLoading {
                tableView.isHidden = true
                let noHistoryTitle = NSLocalizedString("historyNoDataViewTitle", comment: "")
                let noHistoryBody = NSLocalizedString("historyNoDataViewBody", comment: "")
                
                view.showNoContentView(with: noHistoryTitle, noHistoryBody,
                                       and: UIImage(named: "ic-no-history-icon")!,
                                       actionButtonTitle: nil)
            } else {
                tableView.isHidden = false
                view.hideNoContentView()
            }
        }
    }
    var currentPage = 1
    var isLastPage = false
    var isLoading : Bool = false  {
        didSet {
            if isLoading {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }
    
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.historyVD = self
//        m.showsDelegate = self
//        return m
//    }()

    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        loadPage()
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    override func setupViews() {
        super.setupViews()
        indicator.type = .ballPulse
        indicator.tintColor = Theme.current.tintColor
    }
    
    private func loadPage () {
        if isLastPage || isLoading {
            return
        }

        isLoading = true
//        networkManager.getMyHistory(page: currentPage)
    }
    
    // MARK: - PRIVATE
    private func appendData (shows : [HomeSectionList]) {
        
        if isLoading { return }
        if shows.count == 0 {
            self.showsList = []
            return 
        }
        
        if self.showsList.count == 0 {
            showsList = shows
            tableView.reloadData()
            return
        }
    
        showsList.append(contentsOf: shows)
        tableView.reloadData()
    }

    private func setupTableView () {
        tableView.backgroundColor = .clear

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "HistoryCell", bundle: nil ), forCellReuseIdentifier: "HistoryCell")
    }
    
    @objc private func reloadData() {
        loadPage()
        refreshControl.endRefreshing()
    }

    // MARK: - ACTIONS
    @IBAction func moreItemTapped() {
        tabBar?.sheet.clearHistory(clearAction: { [weak self] in
            self?.tabBar?.alert.clearHistory { [weak self] in
                self?.moreNavItem.showActivityIndicator()
//                self?.networkManager.clearHistory()
            }
        })
    }

}

// MARK: - NETWORK (history)
extension RemoteHistoryVC  {
    
    func clearHistorySuccess() {
        showsList = []
        clearLocalHistory()
    }
    
    func clearHistorySuccess(for movieId: String) {
        clearLocalHistory(for: movieId)
    }
    
    func clearLocalHistory(for movieId: String? = nil) {
        do {
            if let movieId = movieId {
                try RealmManager.deleteRecentShowObject(for: movieId)
            } else {
                try RealmManager.deleteRecentShowObject()
            }
            NotificationCenter.default.post(name: Notification.Name("reloadHistoryLocalData"), object: nil)
        } catch {
            tabBar?.alert.genericError()
        }
    }
    
    func historyRequestEnded() {
        moreNavItem.hideActivityIndicator()
    }
    
    func historyRequestFailure() {
        tabBar?.alert.genericError()
    }

}

// MARK: - NETWORK (shows)
extension RemoteHistoryVC {
    
    func requestEnded() {
        isLoading = false
    }
    
    func failure() {
        
    }
    
    func noData() {
        
    }
    
    func success(result: ShowsLoadingSuccessResult) {
        currentPage += 1
        isLastPage = result.isLastPage
        appendData(shows: result.shows.compactMap({HomeSectionList.show($0)}))
    }
}

// MARK: - TABLE
extension  RemoteHistoryVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        cell.configure(show: showsList[indexPath.row].show)
        if indexPath.row == showsList.count - 1 {
            loadPage()
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            print(indexPath.row)
//            networkManager.removeShowFromHistory(movieId: showsList[indexPath.row].show.id)
//            showsList.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let detailsVC = UIStoryboard(name: "HomeSB", bundle: nil)
//            .instantiateViewController(withIdentifier: String(describing: DetailsVC.self)) as? DetailsVC {
//            detailsVC.passedShowItem = showsList[indexPath.row]
//            navigationController?.pushViewController(detailsVC, animated: true)
//        }
    }
}
