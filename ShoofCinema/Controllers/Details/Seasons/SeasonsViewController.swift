//
//  SeasonsViewController.swift
//  ShoofCinema
//
//  Created by mac on 2/22/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import UIKit



protocol EpisodesModelSheet: NSObjectProtocol {
    func dismiss()
}

class SeasonsVC: UIViewController, EpisodesModelSheet {
    
    var seasonsTV: SeasonsTV?
    var parentVC: VideoPlayerViewController?
    
    init(seasonsTV: SeasonsTV, parentVC: VideoPlayerViewController) {
        self.seasonsTV = seasonsTV
        self.parentVC = parentVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let seasonsTV = seasonsTV {
            parentVC?.episodesModelSheetDelegate = self
            seasonsTV.parentVC = parentVC
            seasonsTV.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(seasonsTV)
            NSLayoutConstraint.activate([
                    seasonsTV.topAnchor.constraint(equalTo: self.view.topAnchor),
                    seasonsTV.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    seasonsTV.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                    seasonsTV.leftAnchor.constraint(equalTo: self.view.leftAnchor)
                ])
        }
    }
    
    
}
