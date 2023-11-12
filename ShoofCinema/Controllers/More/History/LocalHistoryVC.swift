//
//  LocalHistoryVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/18/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RealmSwift

class LocalHistoryVC: MasterVC {
    
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
    var isAppeared = false
    
    //    var showsList : Results<RmRecentShow>!
    lazy var recentShows = RealmManager.recentShowsList()!
    
    var observerToken:NotificationToken?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppeared = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppeared = false
    }
    
    private func loadPage () {
        
        // Get Lazy Realm List
//        showsList = RealmManager.recentShowsList()
        
        // Update UI
        listDidUpdate()
        
        // Observe List Changes
        observerToken = recentShows.observe { [weak self] change in
            
            guard let `self` = self else {return}
            
            switch change {
            case .initial(_):
                break
            case .update(_, deletions: let deletions,
                         insertions: let insertions,
                         modifications: _):
                
                if !self.isAppeared {
                    self.tableView.reloadData()
                    return
                }
                
                if deletions.count > 0 {
                    let paths = deletions.compactMap({
                        return IndexPath(row: $0, section: 0)
                    })
                    self.tableView.deleteRows(at: paths, with: .automatic)
                }
                
                if insertions.count > 0 {
                    let paths = insertions.compactMap({
                        return IndexPath(row: $0, section: 0)
                    })
                    self.tableView.insertRows(at: paths, with: .automatic)
                }
                
                /*
                if modifications.count > 0 {
                    let paths = modifications.compactMap({
                        return IndexPath(row: $0, section: 0)
                    })
                    self.tableView.reloadRows(at: paths, with: .automatic)
                }*/
                
                
                break
            case .error(_):
                break
            }
            
            // Update UI
            self.listDidUpdate()
        }
    }
    
    
    
    /// Called when ever the list is updated to update UI as needed
    private func listDidUpdate () {
        let noHistoryTitle = NSLocalizedString("historyNoDataViewTitle", comment: "")
        let noHistoryBody = NSLocalizedString("historyNoDataViewBody", comment: "")

        if recentShows.isEmpty {
            tableView.isHidden = true
            view.showNoContentView(with: noHistoryTitle, noHistoryBody,
                                   and: UIImage(named: "ic-no-history-icon")!,
                                   actionButtonTitle: nil)
        } else {
            if !ShoofAPI.User.ramadanTheme {
                tableView.isHidden = false
                view.hideNoContentView()
            }
            else {
                tableView.isHidden = true
                view.showNoContentView(with: noHistoryTitle, noHistoryBody,
                                       and: UIImage(named: "ic-no-history-icon")!,
                                       actionButtonTitle: nil)
            }
        }
    }
    
    deinit {
        observerToken?.invalidate()
        observerToken = nil
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
                // Clear realm data here
                self?.clearLocalHistory()
            }
        })
    }

}

// MARK: - Data Handling (history)
extension LocalHistoryVC  {
    
    func clearLocalHistory(for movieId: String? = nil) {
        do {
            if let movieId = movieId {
                try RealmManager.deleteRecentShowObject(for: movieId)
            } else {
                try RealmManager.deleteRecentShowObject()
            }
            
            self.moreNavItem.hideActivityIndicator()
            
        } catch {
            actionFailed(with: error)
        }
    }
    
    func actionFailed(with error:Error?) {
        if let error = error {
            tabBar?.alert.backendAPIError(message: error.localizedDescription)
        } else {
            tabBar?.alert.genericError()
        }
    }

}

// MARK: - TABLE
extension  LocalHistoryVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentShows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        cell.configure(show: recentShows[indexPath.row].asShoofShow())
        if indexPath.row == recentShows.count - 1 {
            loadPage()
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let show = recentShows[indexPath.row]
        if editingStyle == .delete {
            clearLocalHistory(for: show.id)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailsSwiftUIViewController()
        vc.show = recentShows[indexPath.row].asShoofShow()
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
