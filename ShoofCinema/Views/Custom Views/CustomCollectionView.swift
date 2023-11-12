//
//  CustomCollectionView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/22/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customize()
    }

    public func customize() {
        self.isScrollEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.allowsSelection = true
    }
    
    
    public func registerCell(withNibName nib :String, andID id : String = "cellID" ) {
        self.register(UINib(nibName: nib, bundle: nil), forCellWithReuseIdentifier: id)
    }
    
    
    public func registerHeader(withNibName nib :String, andID id : String = "headerID" ) {
        self.register(UINib(nibName: nib, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader ,withReuseIdentifier: id)
    }

}
