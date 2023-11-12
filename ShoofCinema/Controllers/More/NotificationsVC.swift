//
//  MoreViewController.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
class NotificationsVC: MasterTVC {
    
    // MARK: - LINKS
    @IBOutlet weak var indicator: NVActivityIndicatorView!
    
    // MARK: - VARS
    lazy var list:[JSON] = []
    
    private var notifications: [ShoofAPI.Notification] = []
    
    var currentPage = 0
    var hasNextPage = true {
        didSet {
            if hasNextPage == false {
                
            }
        }
    }
    var isLoading = false {
        didSet {
            if isLoading {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
            
        }
    }
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = SCRefreshControl(target: self, selector: #selector(refresh))
        }
        setupTable()
        loadPage()
    }
    
    private func setupTable () {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
    }
    
    override func setupViews() {
        super.setupViews()
        indicator.type = .ballPulse
        indicator.tintColor = Theme.current.tintColor
    }

    // MARK: - PRIVATE
    var loadingView : UIViewController?
    
    @objc func refresh () {
        isLoading = false
        currentPage = 0
        hasNextPage = true
        notifications.removeAll()
        tableView.reloadData()
        loadPage()
    }
    
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Notification]>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            tableView.refreshControl?.endRefreshing()
            isLoading = false
            
            do {
                let response = try result.get()
                let notifications = response.body.filter { $0.targetID != nil }
                
                self.currentPage += 1
                self.hasNextPage = !response.isOnLastPage
                self.notifications.append(contentsOf: notifications)
                self.tableView.reloadData()
				self.tableView.showNoContentView(with: "", "notificaitons.noContentAvailable".localized, and: UIImage(), actionButtonTitle: nil)
            } catch {
                print(error)
            }
        }
    }
    
    func loadPage () {
        if !hasNextPage {
            return
        }
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.beginRefreshing()
        }
        
		isLoading = true
		self.tableView.hideNoContentView()
        
        ShoofAPI.shared.loadAllNotifications(pageNumber: currentPage + 1) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
    }
    
    func append(data:[JSON]) {
        tableView.setContentOffset(tableView.contentOffset, animated: false)
        if data.count == 0 {
            return
        }
        var paths = [IndexPath]()
        let startFrom = list.count
        print(data.count)
        for i in 0...data.count-1
        {
            paths.append(IndexPath(row: startFrom + i, section: 0))
        }
        list.append(contentsOf: data)
        UIView.performWithoutAnimation {
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates({
                    self.tableView.insertRows(at: paths, with: .none)
                }) { (finished) in
                }
            } else {
                tableView.beginUpdates()
                tableView.insertRows(at: paths, with: .none)
                tableView.endUpdates()
            }            
        }
    }
}


extension NotificationsVC  {
    
    // ROWS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    // CELL
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        cell.configure(with: notifications[indexPath.row])
        return cell
    }
    
    // WILL DISPLAY
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == notifications.count - 2 {
            loadPage()
        }
    }
    
    // Select Action
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        loadingView = loadingAlert(title: Localize("loadingNotification"))
        present(loadingView!, animated: true, completion: nil)
        
        tabBar?.openNotification(notification)
        
//        tabBar?.performNotifiactionTarget(
//            title, body,
//            target_type,
//            target_id,
//            shouldAlertBeforePush: false,
//            loadingCompleted: { error in
//            //guard let `self` = self else {return}
//
//                //self.loadingView is dismissed before pushing new controller automatically in NotificationsHandler
//
//        })
    }
}
