//
//  Movie.swift
//  Giganet
//
//  Created by Husam Aamer on 4/4/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

struct ChannelSection:Codable {
    var name:String
    var channels:[Channel]
    
    init?(from json:JSON) {
        
        name = json["name"].stringValue
        channels = json["channels"].arrayValue.map({Channel.init(from: $0)}).compactMap({$0})
    }
    
    init ( name : String, channels : [Channel]) {
        self.name = name
        self.channels = channels
    }
    
}
struct Channel:Codable {

    
    var name:String
    var image:URL?
    var streamURL:URL
    
    init?(from json:JSON) {
        name = json["name"].stringValue
        if let imageStr = json["image"].string {
            if imageStr.hasPrefix("http") {
                image = URL(string: imageStr)
            } else {
                let imageUrl = URL(string: Routes.tvURLString + "/" + (imageStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""))
                image = imageUrl
            }
        }
        if let link = json["link"].string ,
            let url = URL(string: link)
        {
            streamURL = url
        } else {
            return nil
        }
    }
    
    internal init(name: String, image: URL? = nil, streamURL: URL) {
        self.name = name
        self.image = image
        self.streamURL = streamURL
    }
}


extension Channel {
    func asPlayerSource () -> CPlayerSource? {
        let url = streamURL
        var resolutions = [CPlayerResolutionSource]()
        resolutions.append(CPlayerResolutionSource(title:"Auto",url))
        let metadata = CPlayerMetadata(title: name, image: image, description: nil)
        return CPlayerSource(resolutions: resolutions, metadata: metadata)
    }
}
