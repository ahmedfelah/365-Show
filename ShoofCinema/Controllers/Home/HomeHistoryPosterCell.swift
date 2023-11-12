//
//  HomePosterCell.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/27/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher

class HistoryPosterCell: UICollectionViewCell {
    
    var posterView : UIImageView!
    
    var progress: UIWatchProgress!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        posterView = UIImageView(frame: bounds)
        posterView.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 2)
        posterView.layer.cornerRadius = 5
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        addSubview(posterView)
        posterView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        progress = UIWatchProgress()
        addSubview(progress)
        progress.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        posterView.image = nil
    }
    
    public func configure (item : RRecentShow) {
        let show = item.asShoofShow()
        self.posterView.kf.setImage(with: show.coverURL ?? show.posterURL, placeholder: nil, options: [.transition(.fade(0.4))])
        
//        print(show.coverURL)
        
        if let rmContinuePercent = item.rmContinue?.left_at_percentage {
            progress.progress = CGFloat(rmContinuePercent)
        } else {
            // Should never happed
            progress.progress = 0
        }
    }

}
