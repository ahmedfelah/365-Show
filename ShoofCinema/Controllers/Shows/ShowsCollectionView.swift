//
//  PostersCollectionView.swift
//  TestAVPlayer
//
//  Created by Husam Aamer on 4/2/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit

struct ShowsLoadingSuccessResult {
    var shows:[ShoofAPI.Show]
    var isLastPage:Bool
}

protocol ShowsCollectionViewDelegate : AnyObject {
    func showsCollectionView(_ colelctionView: ShowsCollectionView, shouldLoadPage pageNumber: Int, withFilter filter: ShoofAPI.Filter)
    func showNoContentView()
}

class ShowsCollectionView: UICollectionView {
    
    // MARK: - VARS
    public var scrollDirection : ScrollDirection = .horizontal
    @IBInspectable public var showHeader : Bool = true
    var shows: [ShoofAPI.Show] = []
    
    weak var showsDelegate : ShowsCollectionViewDelegate?
    
    private(set) var currentPage = 1

	var filter = ShoofAPI.Filter.none
    
    private var isLastPage = false
    private var isFetchInProgress = false
    private var numberOfLoadingCells = 6
    private var _loadingCells = 6
    private var shouldShowLoadingCells = true
    
    // MARK: - INIT
    init(frame: CGRect, scrollDirection : ScrollDirection) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.scrollDirection = scrollDirection
        setupCollection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCollection()
    }
    
    // MARK: - PRIVATE
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = scrollDirection
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 80, right: 10)
        collectionViewLayout = layout
        backgroundColor = Theme.current.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        register(UINib(nibName: .showCellNibName, bundle: nil), forCellWithReuseIdentifier: .posterCellID)
        register(UINib(nibName: .loadingCellNibName, bundle: nil), forCellWithReuseIdentifier: .loadingCellID)
        if showHeader {
            register(UINib(nibName: "FilterHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FilterHeaderView")
        }
        
        delegate  = self
        dataSource = self
    }
    
    private func loadNewPage () {
        hideNoContentView()
        if isFetchInProgress || isLastPage {
            return
        }
        isFetchInProgress = true
        if shows.count == 0 {
            shouldShowLoadingCells = true
            reloadData()
        }
        
        showsDelegate?.showsCollectionView(self, shouldLoadPage: currentPage, withFilter: filter)
    }
    
    private func append(items:[ShoofAPI.Show], andForceRemoveLoadingCells:Bool) {
        if items.count == 0 {
            deleteLoadingCells2{}
            if shows.count == 0 {
                showsDelegate?.showNoContentView()
            }
            return
        }
        
        if andForceRemoveLoadingCells {
            deleteLoadingCells2 {
                var paths = [IndexPath]()
                let startFrom = self.shows.count
                for i in 0...items.count-1
                {
                    paths.append(IndexPath(item: startFrom + i, section: 0))
                }
                
                self.shows.append(contentsOf: items)
                self.performBatchUpdates({
                    self.insertItems(at: paths)
                }) { (finished) in
                }
            }
        } else {
            var paths = [IndexPath]()
            let startFrom = shows.count
            for i in 0...items.count-1 {
                paths.append(IndexPath(item: startFrom + i, section: 0))
            }
            shows.append(contentsOf: items)
            performBatchUpdates({ insertItems(at: paths) })
        }
        
    }
	
    private func deleteLoadingCells2 (completed:@escaping ()->()) {
        if _loadingCells > 0 {
            var paths = [IndexPath]()
            let startFrom = shows.count
            for i in 0..._loadingCells-1
            {
                paths.append(IndexPath(item: startFrom + i, section: 0))
            }
            _loadingCells = 0
            performBatchUpdates({
                deleteItems(at: paths)
            }) { (finished) in
                completed()
            }
        }
    }
    
    private func deleteLoadingCells (completed:@escaping ()->()) {
        if _loadingCells > 0 {
            var paths = [IndexPath]()
            let startFrom = shows.count
            for i in 0..._loadingCells-1
            {
                paths.append(IndexPath(item: startFrom + i, section: 0))
            }
            _loadingCells = 0
            performBatchUpdates({
                deleteItems(at: paths)
            }) { (finished) in
                completed()
            }
        }
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
      return indexPath.row >= shows.count
    }
    
    // MARK: - PUBLIC
    public func showCollectionNoContentView( title : String, message : String, imageName : String, actionButtonTitle : String? = nil, action : (()->())? ) {
        currentPage = 1
        _loadingCells = 0
        shows.removeAll()
        reloadData()
        showNoContentView(with: title, message, and: UIImage(named: imageName)!, actionButtonTitle: actionButtonTitle, reloadButtonAction: action)
    }
    
    public func reloadPosters() {
        
        currentPage = 1
        isLastPage = false
        
        _loadingCells = numberOfLoadingCells
        
        self.filter = .none
        shows.removeAll()
		
        reloadData()
        
        loadNewPage()
    }
    
    public func reloadWithFilter() {
        currentPage = 1
        _loadingCells = numberOfLoadingCells
        isFetchInProgress = false
        isLastPage = false
        shows.removeAll()
//        list.removeAll()
        reloadData()
        loadNewPage()
    }
    
    public func startLoading () {
        showsDelegate?.showsCollectionView(self, shouldLoadPage: currentPage, withFilter: filter)
//        showsDelegate?.showsCollectionView(self, shouldLoadPage: currentPage, genre: genre, year: year, sortType: sortType)
//        showsDelegate?.showsCollectionShouldLoad(self, page: currentPage, genreID: nil, year: nil)
    }
    
    public func loadShows(shows: [ShoofAPI.Show], isLastPage: Bool) {
        isFetchInProgress = false
        currentPage += 1
        self.isLastPage = isLastPage
//        if continueLoading {
//            self.isLastPage = isLastPage
//        } else {
//            self.isLastPage = true
//        }
        
        append(items: shows, andForceRemoveLoadingCells: isLastPage)
        
        if isLastPage {
            _loadingCells = 0
        }
    }
    
    public func successBlock (result: (shows: [ShoofAPI.Show], isLastPage: Bool)) {
        isFetchInProgress = false
        
    }
    
//    public func successBlock (result:ShowsLoadingSuccessResult) {
//        isFetchInProgress = false
//        currentPage += 1
//        if continueLoading {
//            isLastPage = result.isLastPage
//
//        } else {
//            isLastPage = true
//        }
//
//        append(items: result.shows,andForceRemoveLoadingCells: isLastPage)
//        if result.isLastPage {
//            _loadingCells = 0
//        }
//    }
    
    public func emptyCollection () -> Bool {
        return shows.isEmpty
    }
}


// MARK: - COLLECTION DELEAGE
extension ShowsCollectionView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // ITEMS
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count + (shouldShowLoadingCells ? _loadingCells : 0);
    }
    
    // CELL
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        if isLoadingCell(for: indexPath) {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: .loadingCellID, for: indexPath) as! PosterLoadingCell
            let alpha = CGFloat(abs(_loadingCells - (item - shows.count))) / 10 - 0.05
            cell.shimmeringView.contentView.alpha = alpha
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .posterCellID, for: indexPath) as! HomePosterCell
        cell.configure(item: shows[indexPath.row])
        return cell
    }

    // SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if scrollDirection == .vertical {
            let numberOfColumns : CGFloat = Device.IS_IPAD ? 6 : UIScreen.main.bounds.width <= 320 ? 2 : 3
            let flowLayout  = collectionViewLayout as! UICollectionViewFlowLayout
            let insets = flowLayout.sectionInset
            let itemSpacing = flowLayout.minimumInteritemSpacing
            let spaces : CGFloat = (insets.left + insets.right) + (itemSpacing * (numberOfColumns - 1)) + 5
            let contentWidth = frame.size.width - spaces
            let width = contentWidth / numberOfColumns
            let height = width * 1.6
            return CGSize(width: width, height: height)
        } else {
            let height = self.frame.height
            let width = height / 2
            return CGSize(width: width , height : height)
        }
    }
    
    // HEADER
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if showHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FilterHeaderView", for: indexPath) as! FilterHeaderView
            headerView.actionDelegate = self
            return headerView
        } else {
            return UICollectionReusableView()
        }

    }
    
    // HEADER SIZE
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if showHeader {
            return CGSize(width: bounds.width, height: 125)
        } else {
            return .zero
        }
    }

    // WILL DISPLAY
    func collectionView(_ collectionView: UICollectionView,willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0.2
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction],animations: {
            cell.alpha = 1
        })
        if indexPath.item == (shows.count - 5) {
            loadNewPage()
        }
    }
    
    // SELECT
    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //User is selecting loading cells
        if indexPath.item >= shows.count {return}
        
        let vc = DetailsSwiftUIViewController()
        vc.show = shows[indexPath.row]
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        parentViewController!.navigationController?.pushViewController(vc, animated: true)
        
    }
}

// MARK: - STRINGS
fileprivate extension String {

    static let showCellNibName = "HomePosterCell"
    static let posterCellID = "posterCellID"
    static let loadingCellNibName = "PosterLoadingCell"
    static let loadingCellID = "loadingCellID"
}

extension ShowsCollectionView : FilterViewActionDelegate {
    func didSelectFilterItems(genre: ShoofAPI.Genre?, year: String?, type: ShoofAPI.Filter.MediaType?) {
        filter.genreID = genre?.id
        filter.year = year
        filter.mediaType = type ?? .all
        
//        if filter == nil {
//            filter = ShoofAPI.Filter(genreID: genre?.id, categoryID: nil, tagID: nil, rate: nil, year: year, isMovie: nil, sortType: nil)
//        } else {
//            filter?.genreID = genre?.id
//            filter?.year = year
//        }
        
        reloadWithFilter()
    }
}
