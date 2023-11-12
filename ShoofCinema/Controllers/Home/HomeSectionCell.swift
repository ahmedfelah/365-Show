//
//  HomeSectionCollectionView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/27/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
protocol SectionCellActionDelegate  : AnyObject {
    func moreTapped (section : HomeSection)
}

// MARK: - SECTION COLLECTION CELL
class SectionCell : UICollectionViewCell {
    // MARK: - LINKS
    @IBOutlet weak var showsCollection : UICollectionView!
    @IBOutlet weak var sectionTitleLabel : UILabel!
    @IBOutlet weak var moreButton : MainButton!
    
    weak var actionDelegate : SectionCellActionDelegate?
    
//    private var section : HomeSection?
    private var section: ShoofAPI.Section?
    
    lazy var recentShows = realm.objects(RRecentShow.self)
    
//    private var showsList = [Show]() {
//        didSet {
//            self.showsCollection.reloadData()
//        }
//    }
    
    var shows = [ShoofAPI.Show]() {
        didSet {
            self.showsCollection.reloadData()
        }
    }
    
    
    // MARK: - LOAD
    override func awakeFromNib() {
        setupShowsCollection()
        customize()
    }
    // MARK: - PRIVATE
    private func setupShowsCollection () {
        showsCollection.delegate = self
        showsCollection.dataSource = self
        showsCollection.backgroundColor = Theme.current.backgroundColor
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        showsCollection.collectionViewLayout = layout
        showsCollection.showsVerticalScrollIndicator = false
        showsCollection.showsHorizontalScrollIndicator = false
        showsCollection.register(UINib(nibName: .posterCellNibName, bundle: nil), forCellWithReuseIdentifier: .posterCellID)
        showsCollection.register(UINib(nibName: .verticalCellNibName, bundle: nil), forCellWithReuseIdentifier: .verticalCellID)
        showsCollection.register(HistoryPosterCell.self, forCellWithReuseIdentifier: HistoryPosterCell.identifier)
    }
    
    private func customize () {
        self.sectionTitleLabel.font = Fonts.almarai()
    }
    
    func configure(item: ShoofAPI.Section) {
        self.section = item
        self.shows = item.shows
        self.sectionTitleLabel.text = item.title.uppercased()
        
//        if Bool.random() {
        self.moreButton.isHidden = false
//        self.shows.firstInde
//        self.moreButton.tag =
//        } else {
//            self.moreButton.isHidden = true
//        }
    }
    
    public func configure(item : HomeSection) {
//        self.section = item
//        self.showsList = item.showsList
//        self.sectionTitleLabel.text = item.title.uppercased()
//
//        if item.tag != "" || item.category != -1 || item.tagID != 0 {
//            self.moreButton.isHidden = false
//        } else {
//            self.moreButton.isHidden = true
//        }
    }
    
    @IBAction func moreTapped () {
//        actionDelegate?.moreTapped(section: self.section!)
    }
}


extension SectionCell : UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    // ITEMS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    // CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let show = shows[indexPath.row]
        if section?.style == .history {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryPosterCell.identifier, for: indexPath) as! HistoryPosterCell
            if let rmRecentShow = recentShows.first(where: { $0.id == show.id }) {
                cell.configure(item: rmRecentShow)
            }
            
            cell.layoutIfNeeded()
            return cell
        } else if section?.style == .special {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .verticalCellID, for: indexPath) as! VerticalPosterCell
            cell.cofigure(item: shows[indexPath.row])
            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .posterCellID, for: indexPath)
                    as! HomePosterCell
            
            cell.configure(item: shows[indexPath.row])
            cell.layoutIfNeeded()
            return cell
        }
        
//        if section?.style !=  .vertical {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .posterCellID, for: indexPath)
//                    as! HomePosterCell
//            
//            cell.configure(item: shows[indexPath.row])
//            cell.layoutIfNeeded()
//            return cell
//        } else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .verticalCellID, for: indexPath) as! VerticalPosterCell
//            cell.cofigure(item: shows[indexPath.row])
//            cell.layoutIfNeeded()
//            return cell
//        }

    }

    // SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = section else {
            return .zero
        }
        
        switch section.style {
        case .special:
            let height = CGFloat(300)
            return CGSize(width: height * (3/6) , height: height)
        case .history:
            //let height = CGFloat(150)
            return CGSize(width: 250 , height: 150)
        default:
            let width = CGFloat(145)
            let height = CGFloat(250)
            return CGSize(width: width , height: height)
        }
    }
    
    // INSETS
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    // SELECT
    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailsSwiftUIViewController()
        vc.show = shows[indexPath.row]
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        parentViewController!.navigationController?.pushViewController(vc, animated: true)
    }
}


extension SectionCell {
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
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
                self.collectionView(self.showsCollection, didSelectItemAt: peekVC.peekedIndexPath)
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
    static let posterCellNibName = "HomePosterCell"
    static let posterCellID = "posterCellID"
    
    static let watchTrailerTitle = NSLocalizedString("watchTrailerTitle", comment: "")
    static let youtubeIconName = NSLocalizedString("ic-youtube", comment: "")
    
    
    static let verticalCellNibName = "VerticalPosterCell"
    static let verticalCellID = "verticalCellID"

}
