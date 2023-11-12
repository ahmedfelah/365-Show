//
//  PeekShowVC.swift
//  Giganet
//
//  Created by Husam Aamer on 5/25/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import Kingfisher

class PeekShowVC: UIViewController {
    var show: ShoofAPI.Show!
    var peekedIndexPath:IndexPath!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.current.backgroundColor
        let cachedImage = ImageCache.default.retrieveImageInMemoryCache(forKey: show.posterURL?.absoluteString ?? "")
        image.image = cachedImage
        
        if let description = show.description, !description.isEmpty {
            let titleTextHeight = show.title.heightForLabel(font : UIFont.systemFont(ofSize: 20), labelWidth: 300) + 10
            let storyTextHeight = description.heightForLabel(font : UIFont.systemFont(ofSize: 17), labelWidth: 300) + 20
            preferredContentSize = CGSize(width:300, height: titleTextHeight + storyTextHeight + 60)
        } else {
            preferredContentSize = CGSize(width:300, height: 330)
        }
        
        titleLabel.text = show.title
        storyLabel.text = show.description
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.alpha = 0
        storyLabel.alpha = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.3) {
            UIView.animate(withDuration: 0.5, animations: {
                self.storyLabel.alpha = 1
                self.titleLabel.alpha = 1
            }, completion: nil)
        }
        
    }


}
