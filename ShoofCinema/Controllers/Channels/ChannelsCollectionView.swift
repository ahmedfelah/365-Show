//
//  ChannelsCollectionView.swift
//  Giganet
//
//  Created by Husam Aamer on 4/29/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit

protocol ChannelsCollectionViewDelegate : AnyObject {
    func channels(_ collectionView: ChannelsCollectionView,
                  didSelectItemAt indexPath: IndexPath,
                  channel:ShoofAPI.Channel,
                  shouldSelectCell: (Bool) -> ())
}


class ChannelsCollectionView: UICollectionView {
    
    // MARK: - VARS
    var channelsList: [ShoofAPI.Channel] = []
    var selectedChannelIdx : Int?

    
    weak var listDelegate : ChannelsCollectionViewDelegate?
    
    // MARK: - LOAD
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
        
    }
    
    init(with frame:CGRect, list:[ShoofAPI.Channel], selectedChannelIdx : Int? = nil) {
        let flow = UICollectionViewFlowLayout()
        self.channelsList = list
        self.selectedChannelIdx = selectedChannelIdx
        super.init(frame: frame, collectionViewLayout: flow)
        setupCollectionView()
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCollectionView()
    }

    override func awakeFromNib() {
        self.performBatchUpdates (nil) { _ in
            self.selectItem(at: IndexPath(row: 0, section: 1), animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    private func setupCollectionView () {
        dataSource = self
        delegate = self
        allowsMultipleSelection = false
        allowsSelection = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        backgroundColor = Theme.current.backgroundColor
        register(UINib(nibName: .channelCellNibName, bundle: nil), forCellWithReuseIdentifier: .cellID)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 5, right: 16)
        collectionViewLayout = layout
        

        
    }
    
}


extension ChannelsCollectionView : UICollectionViewDelegateFlowLayout,UICollectionViewDelegate , UICollectionViewDataSource {
    
    // SECTIONS
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // ITEMS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channelsList.count;
    }
    
    // ITME SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns : CGFloat = Device.IS_IPAD ? 6 : 2
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let insets = flowLayout.sectionInset
        let space = flowLayout.minimumInteritemSpacing
        let contentW = collectionView.bounds.width - (insets.left + insets.right) - space
        let width = contentW / numberOfColumns
        return CGSize(width: width, height: 180)
    }

    // CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .cellID, for: indexPath) as! ChannelCell
        let channel = channelsList[indexPath.row]
        cell.config(channel: channel)
        if indexPath.row == selectedChannelIdx {
            delay(0.2) {[weak self] in
                self?.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
            selectedChannelIdx = nil
        }
        return cell
    }

    // SELECT
    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 10.0, *) {
            HapticFeedback.veryLightImpact()
        }
     
        if let selected = indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: selected, animated: true)
        }
        let channel = channelsList[indexPath.row]
        listDelegate?.channels( self,didSelectItemAt: indexPath, channel: channel, shouldSelectCell: { bool in
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
        })
        
    }
    
    // ANIMATION
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(
            withDuration: 0.3,
            delay: 0.005 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
                cell.transform = .identity
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(
            withDuration: 0.5,
            animations: {
                cell?.transform = .identity
        })
        
    }

    
    

}
 
fileprivate extension String {
    static let channelCellNibName = "ChannelCell"
}
