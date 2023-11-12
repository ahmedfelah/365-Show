//
//  ChannelsVC.swift
//  SuperCell
//
//  Created by Husam Aamer on 4/1/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

class ChannelsVC: MasterVC {
    
    // MARK: - VARS
    var channelsCollection : ChannelsCollectionView!

    // MARK: - LOAD
    init(with section: ShoofAPI.TVSection) {
        super.init(nibName: nil, bundle: nil)
        channelsCollection = ChannelsCollectionView(with: UIScreen.main.bounds, list: section.channels)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        channelsCollection.listDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)    }

    override func setupViews() {
        super.setupViews()
        view.addSubview(channelsCollection)
        channelsCollection.snp.makeConstraints({$0.edges.equalToSuperview()})
    }
}


// MARK: - CHANNELS COLLECTION DID SELECT DELEGATE
extension ChannelsVC : ChannelsCollectionViewDelegate {
    func channels(_ collectionView: ChannelsCollectionView, didSelectItemAt indexPath: IndexPath, channel: ShoofAPI.Channel, shouldSelectCell: (Bool)->()) {
        if collectionView.tag == 1 {
            if let source = channel.asPlayerSource() {
                ChiefsPlayer.shared.play(from: [source], with: nil)
                shouldSelectCell(true)
            }
        } else {
            let frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            let detailsView = ChannelsCollectionView(with:frame, list: collectionView.channelsList, selectedChannelIdx: indexPath.row)
            detailsView.tag = 1
            detailsView.listDelegate = self
            tabBar?.play(channel: channel, with: detailsView)
        }
    }
}
 
