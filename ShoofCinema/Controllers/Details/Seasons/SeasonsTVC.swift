//
//  SeasonsTVC.swift
//  ShoofCinema
//
//  Created by mac on 4/21/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit
import SwiftUI

class SeasonsTVC: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 16.0, *) {
            contentConfiguration = UIHostingConfiguration {
                // For demo purposes the SwiftUI code below isn't in a separate file/view
                HStack {
                    Image(systemName: "star")
                        .foregroundColor(.purple)
                    Text("Favorites")
                    Spacer() // A spacer to left align the 2 views above
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
