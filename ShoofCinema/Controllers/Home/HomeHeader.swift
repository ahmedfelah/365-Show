//
//  HomeHeader.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/21/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher
import SwiftUI

protocol HomeHeaderActionDelegate : AnyObject {
    func showMovies()
    func showTVShows()
    func showHome()
    func showSearch()
}

class HomeHeaderView : UICollectionReusableView  {

    
    // MARK: - LINKS
    @IBOutlet weak var moonButton: UIButton!
    @IBOutlet weak var backgroundImageView : UIImageView!
    @IBOutlet weak var gradientView : GradientView!
    @IBOutlet weak var genresLabel : UILabel!
    @IBOutlet weak var imdbRatingLabel : UILabel!
    @IBOutlet var imdbRatingCollectionImage: [UIImageView]!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
    
    
    
    
    // Search button -> tag: 3
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: .cellID)
        }
    }
	
    var shows = [ShoofAPI.Show]() {
        didSet {
            pagerView.reloadData()
            if !shows.isEmpty {
                configureBackgroundView(idx: selectedIndex)
            }
        }
    }

    /// Not used anymore... actions handled in HomeVC instead
    weak var actionDelegate : HomeHeaderActionDelegate?

    private var pagerItemSize : CGSize {
        let itemWidth : CGFloat = pagerView.frame.size.width / 1.5
        let itemHeight : CGFloat = pagerView.frame.size.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
    var selectedIndex : Int = 0
    
    // MARK: - LOAD
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
		
        setupPagerView()
        addTapGesture()
        moonButton.imageView?.tintColor = ShoofAPI.User.ramadanTheme ? Theme.current.tintColor : .white
        moonButton.tintColor = ShoofAPI.User.ramadanTheme ? Theme.current.tintColor : .white
    }
    
    private func setupPagerView () {
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.automaticSlidingInterval = 8
        pagerView.isInfinite = true
        pagerView.backgroundColor = UIColor.clear
        pagerView.itemSize = pagerItemSize
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.interitemSpacing = 30
        
    }

    private func configureBackgroundView (idx: Int) {
        guard let sectionShow = shows.indices.contains(idx) ? shows[idx] : nil else {
            return
        }

        backgroundImageView.setImage(url: sectionShow.posterURL)
        self.imdRating(number: Float(sectionShow.rating ?? "0") ?? 0)
        
        if let titleImageURL = sectionShow.titleImageURL {
            titleImageView.isHidden = false
            titleImageView.kf.setImage(with: titleImageURL)
            titleLabel.isHidden = true
        } else {
            titleLabel.isHidden = false
            titleLabel.textWithAnimation(text: sectionShow.title, duration: 0.3)
            titleImageView.isHidden = true
        }
        
        
    }
    
    private func imdRating(number: Float) {
        for index in 0 ... 4 {
            if index < Int(number / 2) {
                UIView.animate(withDuration: 0.5) {
                    self.imdbRatingCollectionImage[index].image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal)
                }
            }
            else {
                UIView.animate(withDuration: 0.5) {
                    self.imdbRatingCollectionImage[index].image = UIImage(systemName: "star")
                }
            }
        }
    }

    private func addTapGesture  () {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDetails(gesture:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func showDetails (gesture : UITapGestureRecognizer) {
        let vc = DetailsSwiftUIViewController()
        vc.show = shows[selectedIndex]
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        parentViewController!.navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - FSPagerView DELEGAGE
extension HomeHeaderView :  FSPagerViewDataSource , FSPagerViewDelegate {
    
    // items
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        shows.count
    }
    
    // cell
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: .cellID, at: index)
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.backgroundColor = Theme.current.tabbarColor
		cell.imageView?.kf.setImage( with: shows[index].coverURL, placeholder: nil, options: [.transition(.fade(0.4))])
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if let detailsVC = UIStoryboard(name: "HomeSB", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: DetailsVC.self)) as? DetailsVC {
            detailsVC.show = shows[index]
            parentViewController!.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int) {
        
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        selectedIndex = targetIndex
        configureBackgroundView(idx: targetIndex)
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        selectedIndex = pagerView.currentIndex
        configureBackgroundView(idx: pagerView.currentIndex)
    }
}


 
