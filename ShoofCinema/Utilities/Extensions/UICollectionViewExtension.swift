//
//  UICollectionViewExtension.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/12/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit



extension UICollectionView {
    
    
    
    func selectItemAt (row : Int,scrollPosition : ScrollPosition) {
        self.indexPathsForSelectedItems?
            .forEach { self.deselectItem(at: $0, animated: false) }
        let indexPath = IndexPath(row: row, section: 0)
        self.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
    }
}
