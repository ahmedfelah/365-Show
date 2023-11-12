//
//  CommentsVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/8/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentsVC: MasterTVC {
    
    
    // MARK: - VARS
    var passedComments = [ShoofAPI.Comment]()
    
    
    // MARK: - LOAD
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.removeStatusBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    // MARK: - PRIVARE
    private func setupTable () {
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
    }

    
    // MARK: - TABLE DATA SOURCE
    
    // SECTIONS
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // ROWS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passedComments.count
    }
    
    // CELL
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        cell.configure(item: passedComments[indexPath.row])
        return cell
    }


}


// MARK: - CELL
class CommentsCell : UITableViewCell {
    
    //MARK: - LINKS
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var userProfileView : ProfileNameView!
    
    override  func awakeFromNib() {
        selectionStyle = .none
    }
    
    //MARK: - PUBLIC
    public func configure(item: ShoofAPI.Comment) {
        dateLabel.isHidden = true
        userNameLabel.text =  item.userName?.uppercased()
        
        if let profileURL = item.userProfileURL {
            userProfileView.setImage(from: profileURL)
        } else if let name = item.userName {
            userProfileView.setFirstLetter(withName: name)
        }
        
        messageLabel.text = item.message.capitalized
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        dateLabel.text = item.date.getFormattedDate(fromFormate: "YYYY-MM-dd HH:mm:ss")
    }
    
    func configure(with request: ShoofAPI.Request) {
        userNameLabel.text = request.userName
        messageLabel.text = request.details
        let dateFormatter = DateFormatter()
        dateLabel.text = request.creationDate.getFormattedDate(fromFormate: "YYYY-MM-dd HH:mm:ss")
        
        if let imageURL = request.userImage {
            userProfileView.setImage(from: imageURL)
        } else if let name = request.userName {
            userProfileView.setFirstLetter(withName: name)
        }
    }
    
    public func configure (requestJson : JSON) {
        let userName = requestJson["user"]["user_name"].stringValue
        let body = requestJson["request_txt"].stringValue
        let date = requestJson["request_time"].stringValue
        userNameLabel.text = userName
        messageLabel.text = body
        dateLabel.text = date.getFormattedDate(fromFormate: "YYYY-MM-dd HH:mm:ss")
        userProfileView.setFirstLetter(withName: userName)
        
    }
    
    public func configure (notificationJson : JSON) {
        let title = notificationJson["notify_title"].stringValue
        let body = notificationJson["notify_body"].stringValue
        let date = notificationJson["notify_created"].stringValue
        userNameLabel.text = title
        messageLabel.text = body
        dateLabel.text = date.getFormattedDate(fromFormate: "YYYY-MM-dd HH:mm:ss")
        userProfileView.isHidden = true
        
    }
    
    func configure(with notification: ShoofAPI.Notification) {
        userNameLabel.text = notification.aps?.alert?.title
        messageLabel.text = notification.aps?.alert?.body
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: notification.creationDate ?? Date())
        userProfileView.isHidden = true
    }
}
