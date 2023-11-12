//
//  SeasonTableHeaderView.swift
//  Giganet
//
//  Created by Husam Aamer on 5/1/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit

protocol SeasonHeaderActionDelegate : AnyObject {

    func seasonCollection (collectionView : UICollectionView, didSelectSeasonIndex index : Int )
}

class SeasonTableHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - LINKS
    @IBOutlet weak var seasonCollection :UICollectionView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    // MARK: - VARS
    var seasons: [ShoofAPI.Media.Season] = []
//    weak var actionDelegate : SeasonHeaderActionDelegate?
    
    // MARK: - LOAD
    override func awakeFromNib( ) {
        super.awakeFromNib()
        setupCollectionView()
        //stackview.backgroundColor = 
    }

    private func setupCollectionView() {
//        seasonCollection.delegate = self
//        seasonCollection.dataSource = self
        seasonCollection.showsVerticalScrollIndicator = false
        seasonCollection.showsHorizontalScrollIndicator = false
        seasonCollection.backgroundColor = Theme.current.backgroundColor
        let layout = ArabicCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        seasonCollection.collectionViewLayout = layout
        seasonCollection.register(UINib(nibName: "SeasonCell", bundle: nil), forCellWithReuseIdentifier: "SeasonCell")

    }
}

// MARK: - CELL
class SeasonCell : UICollectionViewCell {
    
    // MARK: - LINKS
    @IBOutlet weak var numberLabel : UILabel!
    
    // MARK: - LOAD
    override func awakeFromNib () {
        customize()
    }
    
    // MARK: - PRIVATE
    private func customize () {
        self.contentView.layer.cornerRadius = bounds.width / 2 - 10
        self.layer.masksToBounds = true
        self.contentView.layer.borderColor = UIColor.white.cgColor
        //inset(view: numberLabel, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    // MARK: - CONFIGURE
    public func configure (index : Int) {
        numberLabel.text = "Season \(index + 1)".uppercased()
    }
    
    override var isSelected: Bool {
        willSet{
            super.isSelected = newValue
            if newValue
            {
                self.contentView.layer.borderWidth = 1
                numberLabel.textColor = .white
            }
            else
            {
                self.contentView.layer.borderWidth = 0
                numberLabel.textColor = .lightGray
            }
        }

    }
    
    override func prepareForReuse() {
        self.contentView.layer.borderWidth = 0
        self.numberLabel.textColor = .lightGray
    }

}

