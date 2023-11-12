//
//  HomePosterCell.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/27/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher

class VerticalPosterCell: UICollectionViewCell {
    
    
    // MARK: - LINKS
    @IBOutlet weak var posterImageView: UIImageView!
    
    
    
    override func prepareForReuse() {
        posterImageView.image = nil
    }
    // MARK: - LOAD
    override  func awakeFromNib() {
        posterImageView.layer.cornerRadius = 5
        posterImageView.clipsToBounds = true
    }
    
    func cofigure(item: ShoofAPI.Show) {
		self.posterImageView.kf.setImage(with: item.posterURL, placeholder: nil, options: [.transition(.fade(0.4))])
    }
    
    public func cofigure (item : Show) {
        self.posterImageView.kf.setImage(with: item.getPosterUrl, placeholder: nil, options: [.transition(.fade(0.4))])
    }

}
