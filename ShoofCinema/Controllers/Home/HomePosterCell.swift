//
//  HomePosterCell.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/27/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher

class HomePosterCell: UICollectionViewCell {
    
    
    // MARK: - LINKS
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var views: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    
    // MARK: - LOAD
    override  func awakeFromNib() {
        posterImageView.layer.cornerRadius = 5
        posterImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        posterImageView.image = nil
    }
    
    func configure(item: ShoofAPI.Show) {
        self.title.text = item.title
        self.views.text = String(item.numberOfViews)
        self.rating.text = item.rating
        self.year.text = item.year
        self.posterImageView.kf.setImage(with: item.posterURL, placeholder: nil, options: [.transition(.fade(0.4))], progressBlock: nil)
    }
    
    public func configure (item : Show) {
        self.title.text = item.title
        self.views.text = item.getViews
        self.rating.text = item.getImbdRating
        self.year.text = item.getYear
		self.posterImageView.kf.setImage(with: item.getPosterUrl, placeholder: nil, options: [.transition(.fade(0.4))])
    }
}
