//
//  Account.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

struct AccountInfo:Codable {
    var name : String
    var id : String
    var img : String? = nil
    var fname : String? = nil
    var email : String
    var date : String
}

class Account {
    static let shared = Account()
    
    var info:AccountInfo? = RPref.account_info {
        didSet {RPref.account_info = info}
    }
    var token:String? = RPref.token {
        didSet {
            RPref.token = token
            NotificationCenter.default.post(name: Notification.Name(rawValue: gnNotification.didChangeLoginState), object: nil)
        }
    }
}
