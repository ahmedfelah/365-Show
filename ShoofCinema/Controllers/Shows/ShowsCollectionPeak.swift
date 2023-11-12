//
//  Context_PosterCollectionView.swift
//  Giganet
//
//  Created by Husam Aamer on 3/12/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

extension ShowsCollectionView {
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.item >= shows.count  { return nil }
        let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                return self.viewController(for: indexPath)
        })
        return config
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let peekVC = animator.previewViewController as? PeekShowVC {
                self.collectionView(self, didSelectItemAt: peekVC.peekedIndexPath)
            }
        }
    }
    
//    @available(iOS 13.0, *)
//    func makeContextMenu(for indexPath:IndexPath) -> UIMenu {
//        var actions:[UIAction] = []
//        
//        if indexPath.item > shows.count {return UIMenu(title: "na")}
//        
//        let show = shows[indexPath.item]
// 
//        if let ytId = show.youtubeID {
//            let watchAd = UIAction( title: .watchTrailerTitle, image: UIImage(named: .youtubeIconName)) { action in
//                _ = OpenURL.youtube(id: ytId)
//            }
//            actions.append(watchAd)
//        }
//        let edit = UIMenu(title: "", children: actions)
//        return edit
//    }
    
    private func viewController (for indexPath:IndexPath) -> UIViewController? {
        if indexPath.item >= shows.count {return nil}
        let show = shows[indexPath.item]
        let vc = PeekShowVC(nibName: "PeekShowVC", bundle: nil)
        vc.show = show
        vc.peekedIndexPath = indexPath
        return vc
    }
    
}



fileprivate extension String {
    static let watchTrailerTitle = NSLocalizedString("watchTrailerTitle", comment: "")
    static let youtubeIconName = NSLocalizedString("ic-youtube", comment: "")
}
