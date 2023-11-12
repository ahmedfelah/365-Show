//
//  WriteCommentVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/14/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

extension UINavigationController {
    var previousViewController: UIViewController? { viewControllers.last { $0 != topViewController } }
}

class WriteCommentVC: MasterVC {
    
    // MARK: - LINKS
    @IBOutlet weak var commentTextView : CommentTextView!
    @IBOutlet weak var postButtonItem : MainNavBarItem!
    
    // MARK: - VARS
    var show: ShoofAPI.Show?

//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.networkVD = self
//        return m
//    }()
    

    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommentTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.removeStatusBar()
    }
    
    // MARK: - PRIVATE
    private func setupCommentTextField () {
        self.commentTextView.keyboardAppearance = .dark
        self.commentTextView.becomeFirstResponder()
    }
    
    // MARK: - ACTIONS
    @IBAction func postComment () {
        view.endEditing(true)
        
        guard let commentText = commentTextView.text , !commentText.isEmpty else {
            return
        }
        
        postButtonItem.showActivityIndicator()
        ShoofAPI.shared.addComment(commentText, showID: show!.id) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
//        let showId = "\(show.id)"
        
//        postButtonItem.showActivityIndicator()
//        networkManager.writeComment(movieId: showId, comment: commentText)
    }
    
    func handleAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.Comment>.Response, Error>) {
        do {
            let _ = try result.get()
            
            DispatchQueue.main.async {
                self.tabBar?.alert.commentPosted { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.tabBar?.alert.backendAPIError(message: error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async { [self] in
            postButtonItem.hideActivityIndicator()
        }
    }

}

// MARK: - NETWORK
extension WriteCommentVC {
    
    func requestEnded() {
        postButtonItem.hideActivityIndicator()
    }
    
    func failure() {
        tabBar?.alert.genericError()
    }

    func failureMessage(data: String) {
        tabBar?.alert.backendAPIError(message: data)
    }
    
    func success() {
        tabBar?.alert.commentPosted { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    
}
