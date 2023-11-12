//
//  StyledStaticTVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/22/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class StyledStaticTable: UITableView {
    
    
    override func awakeFromNib() {
        customize()
    }
    
    
    private func customize() {
        self.backgroundColor = Theme.current.backgroundColor
    }

}


class StyledTableCell : UITableViewCell {
    override func awakeFromNib() {
        customize()
    }
    private func customize () {
        let selectionView = UIView()
        selectionView.backgroundColor = Theme.current.secondaryColor
        self.selectedBackgroundView = selectionView
        
    }
}
