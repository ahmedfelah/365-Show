//
//  ShowRequestTVC.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON
/*

{
    "request_user" : 984,
    "user" : {
        "user_name" : "Nabeel",
        "user_id" : 984
    },
    "request_id" : 471,
    "request_time" : "2019-07-05 11:06:12",
    "request_txt" : "السلام عليكم<br \/>ممكن ترفعون فلم MR.DESTINY لعام 1990",
    "request_view" : 1,
    "reply" : [
    {
        "reply_request_id" : 471,
        "reply_txt" : "عليكم السلام  للاسف \nالفيلم لا يتوفر ",
        "reply_view" : 1,
        "reply_id" : 498,
        "user" : {
            "user_id" : 720,
            "user_name" : "Admin_Karrar"
        },
        "reply_user" : 720,
        "reply_time" : "2019-07-06 09:38:31"
    },
    {
    "reply_user" : 984,
    "reply_request_id" : 471,
    "reply_view" : 1,
    "reply_txt" : "شعجب",
    "reply_time" : "2019-07-06 13:28:59",
    "user" : {
    "user_id" : 984,
    "user_name" : "Nabeel"
    },
    "reply_id" : 500
    }
    ]
}

*/


struct RequestMessage:Codable {
    var message:String
    var id:Int
    var username:String
    var user_id:Int
    var date:String
    
    init? (fromReply replyJson:JSON){
        
        guard
            let _message    = replyJson["reply_txt"].string,
            let _id         = replyJson["reply_id"].int,
            let _username   = replyJson["user"]["user_name"].string,
            let _user_id    = replyJson["user"]["user_id"].int,
            let _date       = replyJson["reply_time"].string
            else {
            return nil
        }
        
        message     = _message
        id          = _id
        username    = _username
        user_id     = _user_id
        date        = _date
    }
    init? (fromRequest requestJson:JSON){
        
        guard
            let _message    = requestJson["request_txt"].string,
            let _id         = requestJson["request_id"].int,
            let _username   = requestJson["user"]["user_name"].string,
            let _user_id    = requestJson["user"]["user_id"].int,
            let _date       = requestJson["request_time"].string
            else {
                return nil
        }
        
        message     = _message
        id          = _id
        username    = _username
        user_id     = _user_id
        date        = _date
    }
    init (id:Int,message:String, username:String, user_id:Int, date:String) {
        self.id = id
        self.message = message
        self.username = username
        self.user_id = user_id
        self.date = date
    }
}

class ShowRequestVC: MasterVC,UITableViewDelegate,UITableViewDataSource {
    var data:JSON?
    
    var comments:[RequestMessage] = []
    var request_id : Int?
    
    var fieldView:MessageFieldView!
    var keyboardGuide : KeyboardLayoutGuide!
    @IBOutlet weak var tableView:UITableView!
    
    lazy var df = DateFormatter()
    lazy var dateFormatter = DateFormatter()
    
    var owner_id : Int {
        return comments.first?.user_id ?? Int(Account.shared.info?.id ?? "0")!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = data, let firstComment = RequestMessage(fromRequest: data), let _request_id = data["request_id"].int {
            comments = [firstComment]
            comments.append(contentsOf: data["reply"].arrayValue.compactMap({RequestMessage(fromReply: $0)}))
            request_id = _request_id
            title = firstComment.username
        } else {
            title = "إنشاء طلب جديد"
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = Theme.current.backgroundColor
        tableView.contentInset.bottom = 100
        tableView.alpha = 0
        view.backgroundColor = Theme.current.backgroundColor
        
        
        keyboardGuide = KeyboardLayoutGuide(parentView:view)
        
        fieldView = .init(frame: .zero)
        fieldView.sendAction = { [weak self] text, completed in
            self?.send(message: text, completion: completed)
        }
        
        view.addSubview(fieldView)
        fieldView.isHidden = Account.shared.token == nil
        
        fieldView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.keyboardGuide.topGuide.snp.bottom).priority(.high)
            if #available(iOS 11.0, *) {
                $0.bottom.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.bottom).priority(.required)
            }
        })
        
        
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        
        if #available(iOS 11.0, *) {
            if UIApplication.shared.keyWindow!.safeAreaInsets.bottom > 0 {
                let bottomSafeAreaBG = UIView(frame: .zero)
                bottomSafeAreaBG.backgroundColor = Theme.current.tabbarColor
                view.addSubview(bottomSafeAreaBG)
                bottomSafeAreaBG.snp.makeConstraints({
                    $0.height.equalTo(UIApplication.shared.keyWindow!.safeAreaInsets.bottom)
                    $0.leading.equalToSuperview()
                    $0.trailing.equalToSuperview()
                    $0.bottom.equalToSuperview()
                })
            }
        }
        
    }
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            UIView.animate(withDuration: 0.2) {
                self.tableView.alpha = 1
            }
            if comments.count > 0 {
                let ip = IndexPath(row: comments.count - 1, section: 0)
                tableView.scrollToRow(at: ip, at: .bottom, animated: false)
            }
            
            firstAppear = false
        }
    }

    // MARK: - Table view data source


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = comments[indexPath.row]
        var textColor = UIColor.white
        let id : String = {
            if indexPath.row == 0 {
                return "rightCell"
            }
            if item.user_id == owner_id {
                return "rightCell"
            }
            textColor = .black
            return "leftCell"
        }()
        let c = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MessageTableViewCell
        
        c.bodyLabel.attributedText = item.message.html2Attributed(with: textColor)
 
        //Set pretty date
        if let date = df.date(from: item.date) {
            let pretty = dateFormatter.string(from: date)
            c.dateLabel.text = pretty
        } else {
            c.dateLabel.text = nil
        }
        
        //Set user name
        c.username?.text = item.username
        
        return c
    }
    
    func htmlToAttributedString (_ string:String) -> NSAttributedString? {
        let data = Data(string.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [
            .documentType: NSAttributedString.DocumentType.html
            ], documentAttributes: nil) {
            return  attributedString
        }
        return nil
    }
    func send (message:String, completion:@escaping (Bool)->()) {
        if request_id != nil {
            sendAsReplyToOldRequest(with: message, on: completion)
        } else {
            sendAsNewRequest(with: message, on: completion)
        }
        
    }
    
    private func sendAsReplyToOldRequest (with message:String,on completion:@escaping (Bool)->()) {
        RRequests.replyRequest(
            with: String(request_id!),
            replyText: message) { [weak self, message] (json, err) in
                guard let `self` = self else {
                    return
                }
                if err == nil {
                    completion(true)
                    
                    let newComment = RequestMessage(id: 0,
                                             message: message,
                                             username: Account.shared.info?.name ?? "Me",
                                             user_id: Int(Account.shared.info?.id ?? "0") ?? 0,
                                             date: self.df.string(from: Date()))
                    self.addCommentAndUpdateTable(newComment)
                    
                } else {
                    let a = alert(title: "Error", body: err?.localizedDescription, cancel: "حسناً")
                    self.present(a, animated: true, completion: nil)
                    completion(false)
                }
        }
    }
    private func sendAsNewRequest (with message:String,on completion:@escaping (Bool)->()) {
        RRequests.createRequest(
        with: message) {[weak self] (json, error) in
            guard let `self` = self else {return}
            if error == nil {
                if let request_id = json?["id"].int {
                    completion(true)
                    self.request_id = request_id
                    let newComment = RequestMessage(id: 0,
                                             message: message,
                                             username: Account.shared.info?.name ?? "Me",
                                             user_id: Int(Account.shared.info?.id ?? "0") ?? 0,
                                             date: self.df.string(from: Date()))
                    self.addCommentAndUpdateTable(newComment)
                } else {
                    let a = alert(title: "Error", body: "رد الخادم غير مكتمل ، يرجى التبلغ عن المشكلة في حال تكررها", cancel: "حسناً")
                    self.present(a, animated: true, completion: nil)
                    completion(false)
                }
                
            } else {
                let a = alert(title: "Error", body: error?.localizedDescription, cancel: "حسناً")
                self.present(a, animated: true, completion: nil)
                completion(false)
            }
        }
    }
    func addCommentAndUpdateTable(_ newComment:RequestMessage) {
        self.comments.append(newComment)
        let ip = IndexPath(row: self.comments.count - 1, section: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [ip], with: .fade)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: ip, at: .bottom, animated: true)
    }
    
}
extension String {
    func html2Attributed(with color:UIColor) -> NSAttributedString? {
        guard let attr = html2Attributed else {
            return nil
        }
        
        //Change writing direction
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.baseWritingDirection = .rightToLeft
        
        attr.addAttributes([
            NSAttributedString.Key.foregroundColor : color,
            NSAttributedString.Key.font : Fonts.almaraiLight(17),
            NSAttributedString.Key.paragraphStyle : paragraphStyle
            ], range: NSRange(location: 0, length: attr.length))
        
        return attr
    }
    var html2Attributed: NSMutableAttributedString? {
        do {
            let str = self
            guard let data = str.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSMutableAttributedString(
                data: data,
                options:[
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    var html2String: String {
        do {
            let str = self
            guard let data = str.data(using: String.Encoding.utf8) else {
                return self
            }
            
            return try NSMutableAttributedString(
                data: data,
                options:[
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],documentAttributes: nil).string
        } catch {
            return self
        }
    }
}

