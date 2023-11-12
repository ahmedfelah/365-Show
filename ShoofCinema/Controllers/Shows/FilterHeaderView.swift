//
//  FilterHeaderView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/4/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class ArabicCollectionViewFlowLayout : UICollectionViewFlowLayout {

    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}

enum Sorting:String {
    case year = "year", rating = "rate" , views = "watched"
    
    var title : String {
        switch self {
        case .year:
            return "السنة"
        case .views:
            return "المشاهدات"
        case .rating:
            return "التقييم"
        }
    }
}
enum SortingType:String {
    case asc = "asc", desc = "desc"
    
    var title : String {
        switch self {
        case .asc:
            return "تصاعدي"
        case .desc:
            return "تنازلي"
        }
    }
}


protocol FilterViewActionDelegate : AnyObject {
    func didSelectFilterItems(genre : ShoofAPI.Genre?, year : String?, type: ShoofAPI.Filter.MediaType?)
}

struct FilterButton {
    enum ButtonType  {
        case genre
        case year
        case type
    }
    
    let title : String
    let type : ButtonType
}

extension ShoofAPI.Genre : Equatable {
    static func == (lhs: ShoofAPI.Genre, rhs: ShoofAPI.Genre) -> Bool {
        lhs.id == rhs.id
    }
}

class FilterHeaderView: UICollectionReusableView {
    
    // MARK: - LINKS
    @IBOutlet weak var buttonCollection : UICollectionView!
    @IBOutlet weak var mainCollection : UICollectionView!
    
    var selectedYear : String?
    var selectedGenre: ShoofAPI.Genre?
    var seleectedType : ShoofAPI.Filter.MediaType?
    
    enum ShowType: Int, CaseIterable {
        case movies, series, all
        
        var localizedDescription: String {
            NSLocalizedString(String(describing: self), comment: "")
        }
    }

    let buttons : [FilterButton] = [
        //FilterButton(title : .categoryButtonTitle, type : .category),
        FilterButton(title : .genreButtonTitle, type : .genre),
//      FilterButton(title : .sortButtonTitle, type : .sort),
        FilterButton(title : .yearButtonTitle, type : .year),
        FilterButton(title: .type, type: .type)
    ]
    
    var selectedButtonType = FilterButton.ButtonType.genre {
        didSet {
            mainCollection.reloadData()
            mainCollection.selectItemAt(row: selectedIndex, scrollPosition: .centeredHorizontally)
        }
    }
    
    var allGenres: [ShoofAPI.Genre] {
        [ShoofAPI.Genre(id: -1, name: .allTitle)] + ShoofAPI.Genre.allGenres
    }
    
    var allYears: [String] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        var years = (1900...currentYear).map { String($0) }
        years.append(.allTitle)
        return years.reversed()
    }
    
    var allType: [ShoofAPI.Filter.MediaType] {
        ShoofAPI.Filter.MediaType.allCases.reversed()
    }
    
//    var data = genreData {
//        didSet {
//            mainCollection.reloadData()
//            mainCollection.selectItemAt(row: selectedIndex(), scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
//        }
//    }

    weak var actionDelegate : FilterViewActionDelegate?
    
    var selectedIndex: Int {
        switch selectedButtonType {
        case .genre:
            if let selectedGenre = selectedGenre, let selectedIndex = allGenres.firstIndex(of: selectedGenre) {
                return selectedIndex
            }
        case .year:
            if let year = selectedYear, let selectedIndex = allYears.firstIndex(of: year) {
                return selectedIndex
            }
            
        case .type:
            if let type = seleectedType, let selectedIndex = allType.firstIndex(of: type) {
                return selectedIndex
            }
        }
        
        return 0
    }

    // MARK: - LOAD
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        self.backgroundColor = Theme.current.backgroundColor
        setupButtonsCollection()
        setupMainCollection()
        

        buttonCollection.selectItemAt(row: 0, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        mainCollection.selectItemAt(row: 0, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
    }
    
    // MARK: - PRIVATE
    
    private func setupButtonsCollection () {
        buttonCollection.delegate = self
        buttonCollection.dataSource = self
        buttonCollection.backgroundColor = UIColor.clear
        buttonCollection.showsVerticalScrollIndicator = false
        buttonCollection.showsHorizontalScrollIndicator = false
        buttonCollection.allowsMultipleSelection = false
        buttonCollection.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        let layout = ArabicCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        buttonCollection.collectionViewLayout = layout
        
    }
    
    private func setupMainCollection () {
        mainCollection.delegate = self
        mainCollection.dataSource = self
        mainCollection.backgroundColor = UIColor.clear
        mainCollection.showsVerticalScrollIndicator = false
        mainCollection.showsHorizontalScrollIndicator = false
        mainCollection.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        let layout = ArabicCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        mainCollection.collectionViewLayout = layout
    }
    
    private func setupCategoriesData () {
        
    }
    

}

// MARK: - PRIVATE
extension FilterHeaderView : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // ITEMS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == buttonCollection {
            return buttons.count
        } else {
            switch selectedButtonType {
            case .genre: return allGenres.count
            case .year: return allYears.count
            case .type: return allType.count
            }
        }
    }
    
    // CELLS
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        if collectionView == buttonCollection {
            cell.titleLabel.text = buttons[indexPath.item].title
            cell.dropdownIcon.isHidden = false
        } else {
            switch selectedButtonType {
            case .genre:
                let genre = allGenres[indexPath.row]
                cell.titleLabel.text = genre.name
            case .year:
                let year = allYears[indexPath.row]
                cell.titleLabel.text = year
            case .type:
                let type = allType[indexPath.row]
                cell.titleLabel.text = type.localizedDescription
            }
            
            
            cell.dropdownIcon.isHidden = true
        }
        return cell
    }
    
    // SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height : CGFloat = self.mainCollection.bounds.height - 8
        var itemSize : CGSize = .zero
        let padding : CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 150 : 70
        if collectionView == buttonCollection {
            itemSize = buttons[indexPath.row].title.size(withAttributes: [
                 NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
             ])
            return CGSize(width: itemSize.width + padding, height: height)
        } else {
            if selectedButtonType == .genre {
                itemSize = allGenres[indexPath.row].name.size(withAttributes: [
                     NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
                 ])
            } else if selectedButtonType == .type {
                itemSize = allType[indexPath.row].localizedDescription.size(withAttributes: [
                     NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
                 ])
            }
            else {
                itemSize = allYears[indexPath.row].size(withAttributes: [
                     NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)
                 ])
            }
            
            return CGSize(width: itemSize.width + 40, height: height)
        }
    }
    
    // INSETS
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // buttons collection
        if collectionView == buttonCollection {
            let indexedItem = buttons[indexPath.item]
            buttonCollection.selectItemAt(row: indexPath.row, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            selectedButtonType = indexedItem.type
        } else {
        // main collection
            switch selectedButtonType {
            case .genre: selectedGenre = indexPath.row == 0 ? nil : allGenres[indexPath.row]
            case .year: selectedYear = indexPath.row == 0 ? nil : allYears[indexPath.row]
            case .type: seleectedType = indexPath.row == 0 ? nil : allType[indexPath.row]
            }
            
            actionDelegate?.didSelectFilterItems(genre: selectedGenre, year: selectedYear, type: seleectedType)
        }
    }
}


class FilterCell : UICollectionViewCell {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var containerView : UIView!
    @IBOutlet weak var dropdownIcon : UIImageView!
    

    override func awakeFromNib() {
        dropdownIcon.isHidden = true
        titleLabel.numberOfLines = 1
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func prepareForReuse() {
        dropdownIcon.isHidden = true
        dropdownIcon.tintColor = .lightGray
        containerView.layer.borderColor = UIColor.darkGray.cgColor
        titleLabel.textColor = .lightGray
    }
    
    override var isSelected: Bool{
        willSet{
            super.isSelected = newValue
            if newValue
            {
                containerView.layer.borderColor = Theme.current.tintColor.cgColor
                titleLabel.textColor = Theme.current.tintColor
            }
            else
            {
                containerView.layer.borderColor = UIColor.darkGray.cgColor
                titleLabel.textColor = .lightGray
            }
        }
    }
}



fileprivate extension String {
    static let genreButtonTitle = NSLocalizedString("genreButtonTitle", comment: "")
    static let yearButtonTitle = NSLocalizedString("yearButtonTitle", comment: "")
    static let sortButtonTitle = NSLocalizedString("sortButtonTitle", comment: "")
    static let categoryButtonTitle = NSLocalizedString("categoryButtonTitle", comment: "")
    static let type =  NSLocalizedString("type", comment: "")
}


public protocol NibInstantiatable {
    
    static func nibName() -> String
    
}

extension NibInstantiatable {
    
    static func nibName() -> String {
        return String(describing: self)
    }
    
}

extension NibInstantiatable where Self: UIView {
    
    static func fromNib() -> Self {
        
        let bundle = Bundle(for: self)
        let nib = bundle.loadNibNamed(nibName(), owner: self, options: nil)
        
        return nib!.first as! Self
        
    }
    
}
