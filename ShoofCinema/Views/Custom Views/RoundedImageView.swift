//
//  RoundedImageView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 4/3/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }
}

class LightRoundedImageView: UIImageView {
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}
