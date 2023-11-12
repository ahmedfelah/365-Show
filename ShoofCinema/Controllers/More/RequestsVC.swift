//
//  MoreViewController.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

class RequestsVC: MasterTVC {
    
    // MARK: - LINKS
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var segment: UISegmentedControl!
//    @IBOutlet weak var addRequestItem : MainNavBarItem!
    
    // MARK: - VARS
    var requests: [ShoofAPI.Request] = []
    
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
        
        setupTable()

//        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    override func setupViews() {
        
        super.setupViews()
        
//        segment.isHidden = true
        
        if ShoofAPI.User.current != nil {
            let button = UIBarButtonItem(image: UIImage(named: "ic-add-request"), style: .plain, target: self, action: #selector(addRequest))
            navigationItem.rightBarButtonItem = button
        } else {
            segment.isHidden = true
        }
        
//        segment.tintColor = Colors.tint
//        if ShoofAPI.User.current == nil {
//            segment.isHidden = true
//            navigationItem.rightBarButtonItem = nil
//
//        }       
        segment.setTitleTextAttributes([
            NSAttributedString.Key.font:Fonts.almarai(15),
            NSAttributedString.Key.foregroundColor:UIColor.white
        ], for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.font:Fonts.almaraiLight(15),
            NSAttributedString.Key.foregroundColor:UIColor.black
        ], for: .selected)
//
//
    }
    
    private func setupTable () {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = SCRefreshControl(target: self, selector: #selector(refresh))
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
    }
    
    // MARK: - PRIVATE
    @objc func refresh () {
        isLoading = false
        currentPage = 0
        hasNextPage = true
        loadNextPage()
    }
    
    
    @objc func addRequest(sender: UIBarButtonItem) {
        let vc = SubmitRequestViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadNextPage () {
        guard hasNextPage && !isLoading else {
            return
        }
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.beginRefreshing()
        }
        
        isLoading = true
        
        if segment.selectedSegmentIndex == 0 {
            ShoofAPI.shared.loadRequests(pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        } else {
            ShoofAPI.shared.loadUserRequests(pageNumber: currentPage + 1) { [weak self] result in
                self?.handleAPIResponse(result: result)
            }
        }
    }
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Request]>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            tableView.refreshControl?.endRefreshing()
            
            do {
                let response = try result.get()
                requests = requests + response.body
                hasNextPage = !response.isOnLastPage
                currentPage += 1
                tableView.reloadData()
//                view.showNoContentView(with: "NONE", .noContentMessage, and: UIImage(named: "ic-no-fav-icon")!, actionButtonTitle: "DWDD", reloadButtonAction: {})
            }   catch {
                tabBar?.alert.genericError()
                print(error)
            }
            
            isLoading = false
        }
    }
    
    /*
    private func handleResponse (for segment:Int, json:JSON?, error:Error?) {
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        }
        
        tableView.setContentOffset(tableView.contentOffset, animated: false)
            if self.segment.selectedSegmentIndex != segment {
            return
        }
        
        self.isLoading = false
        if error != nil {
            tabBar?.alert.genericError()
        }
        
        guard let json = json else {
            return
        }
        self.currentPage += 1
        self.hasNextPage = json["next_page_url"] != JSON.null
        self.append(data: json["data"].arrayValue)
    }
    
    private func append(data:[JSON]) {
        if data.count == 0 {
            return
        }
        
        if list.count == 0 {
            list = data
            tableView.reloadData()
            return
        }
            
        var paths = [IndexPath]()
        let startFrom = list.count
        for i in 0...data.count-1 {
            paths.append(IndexPath(row: startFrom + i, section: 0))
        }
        list.append(contentsOf: data)
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.insertRows(at: paths, with: .none)
            tableView.endUpdates()
        }
    }
    */
    
    // MARK: - ACTIONS
    @IBAction func segmentValueChanged(_ sender: Any? = nil) {
        refresh()
    }
    
    // MARK: - NAVIGATION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let show = segue.destination as? ShowRequestVC ,
//            let row = tableView.indexPathForSelectedRow?.row {
//            show.data = list[row]
//        }
    }
    
}

// MARK: - TABLE
extension RequestsVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        let request = requests[indexPath.row]
        cell.configure(with: request)
        if indexPath.row == requests.count - 1 {
            loadNextPage()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "segueToRequestDetails", sender: nil)
    }
}
