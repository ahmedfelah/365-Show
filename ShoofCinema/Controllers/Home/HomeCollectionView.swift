//
//  HomeCollectionView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/27/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

extension UICollectionViewFlowLayout {
	open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
		return true  //RETURN true if collection view needs to enable RTL
	}
}

// MARK: - SECTION COLLECTION VEIW
extension HomeVC : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    // ITEMS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedSections.count
    }
    
    // CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .sectionCellID, for: indexPath)
                as! SectionCell
        
        cell.configure(item: displayedSections[indexPath.row])
        cell.moreButton.tag = indexPath.row
        cell.layoutIfNeeded()
        cell.showsCollection.contentOffset = cachedPosition[indexPath] ?? .zero
        cell.actionDelegate = self
        return cell
    }
    
    // SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = displayedSections[indexPath.row]
        switch item.style {
        case .vertical:
            return CGSize(width: view.frame.size.width, height: 350)
        case .history:
            return CGSize(width: view.frame.size.width, height: 200)
        default:
            return CGSize(width: view.frame.size.width, height: 300)
        }
    }
    
    // HEADER
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: .headerID, for: indexPath)
            as! HomeHeaderView
            
            if let featuredSection = featuredSection {
                headerView.shows = featuredSection.shows
            }
            
            self.headerView = headerView
            
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: .footerID , for: indexPath)
                    as! HomeFooter
            
            self.footerView = footerView
            
            return footerView
        }

    }
    
    // HEADER SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: UIDevice.current.userInterfaceIdiom == .pad ? 850 : 650)
    }

    // FOOTER
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
    
    // INSETS
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }
    
    // ANIMATION
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == (displayedSections.count - 1) {
            loadNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell  = cell as? SectionCell {
            cachedPosition[indexPath] = cell.showsCollection.contentOffset
        }
    }
}






fileprivate extension String {
    static let sectionCellNibName = "SectionCell"
    static let sectionCellID = "sectionCellID"
    static let posterCellNibName = "PosterCell"
    static let posterCellID = "posterCellID"
    static let headerNibName = "HomeHeader"
    static let headerID = "headerID"
    static let footerNibName = "HomeFooter"
    static let footerID = "footerID"
}
