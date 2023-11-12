//
//  HistoryTVCell.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 7/11/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher

// MARK: - TABLE CELL
class HistoryCell : UITableViewCell {
    
    
    // MARK: - LINKS
    @IBOutlet weak var posterImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var genreLabel : UILabel!
    @IBOutlet weak var rattingLabel : UILabel!
    @IBOutlet weak var viewsLabel : UILabel!
    
    override func awakeFromNib() {
        self.selectionStyle = .none
        posterImageView.layer.cornerRadius = 5
    }

    override func prepareForReuse() {
        posterImageView.image = nil
    }
    
    // MARK: - PUBLIC
    public func configure (show : ShoofAPI.Show) {
        self.titleLabel.text = show.title
        self.genreLabel.text = show.formattedGenres
        self.rattingLabel.text = show.rating
        self.viewsLabel.text = show.numberOfViews.description
		self.posterImageView.kf.setImage(with: show.posterURL, placeholder: nil, options: [.transition(.fade(0.4))])
    }
}
