//
//  SubmitRequestVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 4/26/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class SubmitRequestVC: MasterVC {
    
    
    @IBOutlet weak var commentTextView : CommentTextView!
    @IBOutlet weak var postButtonItem : MainNavBarItem!
    
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.networkVD = self
//        return m
//    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommentTextField()
    }
    
    
    override func setupViews() {
        super.setupViews()
    }
    
    private func setupCommentTextField () {
        self.commentTextView.keyboardAppearance = .dark
        self.commentTextView.becomeFirstResponder()
    }
    
    
    @IBAction func postComment () {
        
        guard let requestText = commentTextView.text , requestText.count != 0 else {
            return
        }
        
        
        view.endEditing(true)
        postButtonItem.showActivityIndicator()
        
        ShoofAPI.shared.addRequest(withTitle: "Zaid Request 1", details: requestText) { [weak self] result in
            self?.handleAPIResponse(result: result)
        }
//        networkManager.submitNewRequest(message: requestText)
    }

    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<ShoofAPI.Request>.Response, Error>) {
        DispatchQueue.main.async { [self] in
            postButtonItem.hideActivityIndicator()
            do {
                let _ = try result.get()
                navigationController?.popViewController(animated: true)
            } catch {
                tabBar?.alert.backendAPIError(message: error.localizedDescription)
            }
        }
    }
}


// MARK: - NETWORK
extension SubmitRequestVC {
    
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

