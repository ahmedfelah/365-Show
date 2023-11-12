//
//  ExploreViewController.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/3/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit
import TBKNetworking
import Kingfisher
import Shimmer

private let cellIdentifier = "ExploreItemCell"

class ExploreViewController: MasterVC, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    private var explores: [ShoofAPI.Explore] = []

    let shoofAPI = ShoofAPI.shared
    
    lazy private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Theme.current.backgroundColor
        collectionView.register(ExploreItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadExplores()
    }
    
    func loadExplores() {
        showHUD()
        
        shoofAPI.loadExplores(pageNumber: 1) { [weak self] result in
            do {
                let response = try result.get()
                DispatchQueue.main.async {
                    self?.explores.append(contentsOf: response.body)
                    self?.collectionView.reloadData()
                    self?.hideHUD()
                }
            } catch {
                print("ERROR LOADING EXPLORES: ", error)
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        navigationItem.title = NSLocalizedString("explore", comment: "")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        explores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let explore = explores[indexPath.row]
        if let showsVC = UIStoryboard(name: "HomeSB", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: ShowsVC.self)) as? ShowsVC {
            showsVC.type = .filter(explore.filter)
            showsVC.navigationItem.title = NSLocalizedString("explore", comment: "")
            navigationController?.pushViewController(showsVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ExploreItemCell
        let explore = explores[indexPath.row]
        cell.configure(with: explore)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 10
        return CGSize(width: width, height: width * 0.75)
    }
}

class ExploreItemCell : UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        imageView.layer.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with explore: ShoofAPI.Explore) {
        imageView.kf.setImage(with: explore.imageURL, placeholder: Theme.current.secondaryLightColor, options: [.transition(.fade(0.4))])
    }
}

extension UIColor : Placeholder {
    public func add(to imageView: KFCrossPlatformImageView) {
        imageView.backgroundColor = self
    }
    
    public func remove(from imageView: KFCrossPlatformImageView) {
        imageView.backgroundColor = nil
    }
}
