//
//  RmShow.swift
//  Giganet
//
//  Created by Husam Aamer on 5/6/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

class RRecentShow: RShow {
    
    @objc dynamic var rmContinue:RContinueShow?
    
    override init() {
        super.init()
    }
    
    init(with show: ShoofAPI.Show, rmContinueObject :RContinueShow) {
        super.init(from: show)
        self.rmContinue = rmContinueObject
    }
}

// MARK: - Old RmRecentShow

class RmRecentShow: RmShow {
    
    @objc dynamic var rmContinue:RContinueShow?
    
    override init() {
        super.init()
    }
    
    init(with show: Show, rmContinueObject:RContinueShow) {
        super.init(with: show)
        self.rmContinue = rmContinueObject
    }
}
