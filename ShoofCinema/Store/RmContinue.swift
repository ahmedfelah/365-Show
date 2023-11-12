//
//  RmShow.swift
//  Giganet
//
//  Created by Husam Aamer on 5/6/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import Foundation
import RealmSwift

class RContinueShow:Object {
    //Show id
	@Persisted var id:String = ""
    
    //enum ShowType raw value
	@Persisted var type:Int = 0
    
    
    //Only for series
    @Persisted var seasonID: String?
	@Persisted var episode_id: String?
	
    //Time in seconds at which movie/episode was left
	@Persisted var left_at:Int = 0
    
    //% (Time in seconds at which movie/episode was left) / (full duration of movie)
	@Persisted var left_at_percentage:Float = 0.0
    
    //Creation date
	@Persisted var creation_date = Date()
    
	@Persisted(indexed: true) var playing_date = Date()
	
    func setPlayingDate () {
        playing_date = Date()
    }
	
	override static func indexedProperties() -> [String] {
		return ["id","episode_id","playing_date"]
	}
}

// MARK: - Old RmContinueShow

class RmContinueShow:Object {
    
    //Show id
    @objc dynamic var id:Int = 0
    
    //enum ShowType raw value
    @objc dynamic var type:Int = 0
    
    //Only for series
    let episode_id  = RealmProperty<Int?>()
    
    //Time in seconds at which movie/episode was left
    @objc dynamic var left_at:Int = 0
    
    //% (Time in seconds at which movie/episode was left) / (full duration of movie)
    @objc dynamic var left_at_percentage:Float = 0.0
    
    //Creation date
    @objc dynamic var creation_date = Date()
    
    @objc dynamic var playing_date = Date()
    
    override static func indexedProperties() -> [String] {
        return ["id","season_index","episode_index","playing_date"]
    }
    func setPlayingDate () {
        playing_date = Date()
    }
}
