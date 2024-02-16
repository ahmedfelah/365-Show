//
//  KolodaVC.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 12/13/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit
import Koloda


@available(iOS 13.0, *)

class KolodaVC: UIViewController {

    var kolodaView: KolodaView!
    var shows:[ShoofAPI.Show] = []
    var optionsStack :UIStackView!
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "RECOMMENDATIONS"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = Theme.current.backgroundColor
        
        kolodaView = KolodaView(frame: view.bounds)
        view.addSubview(kolodaView)
        kolodaView.snp.makeConstraints({$0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 9, bottom: 9, right: 9))})
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        loadRandomShows()
        
        
        let widthes:[CGFloat] = [65,80,80,65]
        let titleSize:[CGFloat] = [14,16,16,14]
        let titles :[String]  = ["Terrible","Not Bad","Good","Great"]
        let colors :[UIColor] = [
            UIColor(red: 0.83, green: 0.40, blue: 0.40, alpha: 1.00),
            UIColor(red: 0.92, green: 0.72, blue: 0.18, alpha: 1.00),
            UIColor(red: 0.35, green: 0.62, blue: 0.97, alpha: 1.00),
            UIColor(red: 0.40, green: 0.84, blue: 0.59, alpha: 1.00),
            
        ]
        
        optionsStack = UIStackView()
        
        for index in 0...3 {
            let optionBtn = UIButton(type: .custom)
            optionBtn.titleLabel?.font = .systemFont(ofSize: titleSize[index], weight: .semibold)
            optionBtn.titleLabel?.textColor = UIColor.white
            optionBtn.setTitle(titles[index], for: .normal)
            optionBtn.backgroundColor = colors[index]
            optionBtn.layer.cornerRadius = widthes[index]/2
            optionBtn.layer.borderColor = Theme.current.separatorColor.withAlphaComponent(0.8).cgColor
            optionBtn.tag = index
            optionBtn.addTarget(self, action: #selector(optionAction(_:)), for: .touchUpInside)
            optionsStack.addArrangedSubview(optionBtn)
            optionBtn.snp.makeConstraints({
                $0.size.equalTo(widthes[index])
            })
        }
        
        
        optionsStack.axis = .horizontal
        optionsStack.spacing = 5
        optionsStack.distribution = .equalSpacing
        optionsStack.alignment = .bottom
        view.addSubview(optionsStack)
        optionsStack.snp.makeConstraints({
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(25)
        })

        
    }
    
    private func loadRandomShows () {
        posters(shouldLoad: 1) { (success) in
            self.shows.append(contentsOf: success.shows)

            if self.shows.count == success.shows.count {
                self.kolodaView.reloadData()
            }

            #if DEBUG
            #else
            if self.shows.count < 30 {
                self.loadRandomShows()
            }
            #endif

        } failedWith: { (error) in
            print(error)
        }
    }
    
    @objc func optionAction (_ sender:UIButton) {
        switch sender.tag {
        case 0,1:
            kolodaView.swipe(.left, force: true)
        case 2,3:
            kolodaView.swipe(.right, force: true)
        default:
            return
        }
    }
    
    private lazy var randomShowsFilter: ShoofAPI.Filter = {
        let randomGenre = ShoofAPI.Genre.allGenres.randomElement()
        var filter = ShoofAPI.Filter.none
        filter.genreID = randomGenre?.id
        return filter
    }()
    
    func posters( shouldLoad page: Int, success: @escaping (ShowsLoadingSuccessResult) -> (), failedWith: @escaping (Error) -> ()) {
        ShoofAPI.shared.loadShows(withFilter: randomShowsFilter, pageNumber: page) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let response = try result.get()
                    let successResult = ShowsLoadingSuccessResult(shows: response.body, isLastPage: response.isOnLastPage)
                    success(successResult)
                } catch {
                    failedWith(error)
                    self?.tabBar?.alert.genericError()
                }
            }
        }
//        RRequests.getRandomShowsForCategory(with: 1) { [weak self] (json, error) in
//            guard let `self` = self else {return}
//            
//            
//            if let showsJson = json?.array {
//                let shows = showsJson.compactMap({Show(from: $0)})
//                
//                let isLast = true
//                let result = ShowsLoadingSuccessResult(shows: shows, isLastPage: isLast)
//                
//                success(result)
//                
//                return
//            } else if let err = error {
//                failedWith(err)
//                return
//            }
//            self.tabBar?.alert.genericError()
//        }
    }
}


@available(iOS 13.0, *)
extension KolodaVC: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        if index == 0 {return}
        let rootVC = DetailsSwiftUIViewController()
        rootVC.show = shows[index-1]
        
        present(rootVC, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        let minimumOpacity :CGFloat = 1-(finishPercentage/100) + 0.2
        
        switch direction {
        case .right, .topRight:
            optionsStack.arrangedSubviews.forEach({
                $0.alpha = $0.tag == 3 ? 1 : minimumOpacity
            })
            break
        case .bottomRight:
            optionsStack.arrangedSubviews.forEach({
                $0.alpha = $0.tag == 2 ? 1 : minimumOpacity
            })
            break
        case .bottomLeft:
            optionsStack.arrangedSubviews.forEach({
                $0.alpha = $0.tag == 1 ? 1 : minimumOpacity
            })
            break
        case .left, .topLeft:
            optionsStack.arrangedSubviews.forEach({
                $0.alpha = $0.tag == 0 ? 1 : minimumOpacity
            })
            break
        default:
            optionsStack.arrangedSubviews.forEach({$0.alpha = 1})
            break
        }
    }
    
    func kolodaDidResetCard(_ koloda: KolodaView) {
        optionsStack.arrangedSubviews.forEach({$0.alpha = 1})
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        optionsStack.arrangedSubviews.forEach({$0.alpha = 1})
    }
    
}

@available(iOS 13.0, *)
extension KolodaVC: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return shows.count + 1
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index == 0 {
            return KolodaLabelCardView(image: UIImage(named: "Empty Cards"),title: "Rate the following films to make the suggestions more suitable for you.", description: "← Swipe left or right to rate →")
        }
        return KolodaCardView(show: shows[index-1])
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }
}
