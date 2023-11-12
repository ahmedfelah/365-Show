//
//  WalkthroghPagerVC.swift
//  Masosa
//
//  Created by Husam Aamer on 7/30/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

class WalkthroghPagerVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    typealias WalkthroughItem = WTVC.WalkthroughItem
    var list : [WalkthroughItem]!
    
    var indicator:UIPageControl = .init()
    init() {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: [OptionsKey.spineLocation:SpineLocation.mid])

        
        list = [
            WalkthroughItem(title: "Movies & TV Recommendations Based On Your Taste",
                            body: "Intelligent Recommendations",
                            imageString: "wt-1",
                            buttonTitle: "Next",
                            buttonAction: nextBtnAction),
            WalkthroughItem(title: "DISCOVER",
                           body: "Find out new movies to watch",
                           imageString: "wt-2",
                           buttonTitle: "Next",
                           buttonAction: nextBtnAction),
            WalkthroughItem(title: "Favorite List",
                           body: "Add movies to your favorite list to watch later",
                           imageString: "wt-3",
                           buttonTitle: "Start Using",
                           buttonAction: dismissWalkthrough)
        ]
    }
    
    func nextBtnAction () {
        guard let currentIndex = viewControllers?.first?.view.tag,
            let nextVC = controller(for: currentIndex + 1).1 else {
                return
        }
        indicator.currentPage = currentIndex + 1
        setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
    }
    
    func dismissWalkthrough () {
        RPref.walkthroghSeen = true
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        view.backgroundColor = Theme.current.backgroundColor
        
        indicator.numberOfPages                  = list.count
        indicator.currentPageIndicatorTintColor  = Theme.current.tintColor
        indicator.pageIndicatorTintColor         = Theme.current.textColor
        view.addSubview(indicator)
        indicator.snp.makeConstraints({
            $0.bottom.equalToSuperview().offset(-40)
            $0.centerX.equalToSuperview()
        })
        
        setViewControllers([controller(for: 0).1!], direction: .forward, animated: false, completion: nil)
    }
    
    func controller(for index:Int) -> (Int,UIViewController?) {
        var index = index
        if index >= list.count {
            index = 0
        }
        if index < 0 {
            index = list.count - 1
        }
        let vc = WTVC(with: list[index])
        vc.view.tag = index
        return (index,vc)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let index = viewController.view.tag - 1
        let (_,vc) = controller(for: index)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag + 1
        let (_,vc) = controller(for: index)
        return vc
    }
    
    //Delegate
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool)
    {
        if let currentIndex = viewControllers?.last?.view.tag {
            indicator.currentPage = currentIndex
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
