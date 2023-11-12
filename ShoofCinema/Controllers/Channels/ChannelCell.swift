//
//  ChannelCollectionViewCell.swift
//  Giganet
//
//  Created by Husam Aamer on 4/29/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import Kingfisher
@objc class ChannelCell: UICollectionViewCell {
        
    // MARK: - LINKS
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - LOAD
    override func awakeFromNib() {
        super.awakeFromNib()
        customize ()
      
    }
    
    private func customize () {
        self.backView.layer.borderColor = Theme.current.tintColor.cgColor
        self.backView.layer.cornerRadius = 20
        self.backView.clipsToBounds = true
    }

    // MARK: - CONFIG
    public func config (channel: ShoofAPI.Channel) {
        self.name.text = channel.name
		imageView.kf.setImage( with: channel.imageURL, placeholder: nil, options: [.transition(.fade(0.4))])
    }

    // MARK: - SELECTED
    override var isSelected: Bool {
        didSet {
            self.backView.layer.borderWidth = self.isSelected ? 1 : 0
        }
    }
    

}



