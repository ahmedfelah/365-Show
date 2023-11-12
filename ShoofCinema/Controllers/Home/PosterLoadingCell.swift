//
//  PosterCell.swift
//  TestAVPlayer
//
//  Created by Husam Aamer on 4/3/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import Kingfisher
class PosterLoadingCell: UICollectionViewCell {
    
    @IBOutlet weak var shimmeringView: FBShimmeringView2!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }
}
