//
//  WatchedViewModel.swift
//  ShoofCinema
//
//  Created by mac on 8/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

class WatchedViewModel: ObservableObject {
    @Published var shows: Results<RRecentShow>
    
    init() {
        self.shows = RealmManager.recentShowsList()!
    }
    
    func updateRecentShows() {
        self.shows = RealmManager.recentShowsList()!
    }
}
