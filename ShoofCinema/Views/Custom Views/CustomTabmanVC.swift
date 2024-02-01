//
//  FirstViewController.swift
//  SuperCell
//
//  Created by Husam Aamer on 3/30/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import NVActivityIndicatorView

class CustomTabmanVC: TabmanViewController {
    
    // MARK: - VARS
    var titles = [String]()
    var viewControllers = [UIViewController]()
    var bar : TMBarView<TMHorizontalBarLayout, TMLabelBarButton, TMLineBarIndicator>!
    let hud = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70) , type: .ballPulse, color: Theme.current.tintColor, padding: 0)
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        //delegate = self
        customizeTabman()
        addBar(bar, dataSource: self, at: .top)
        setupHUD()
    }
    
    // MARK: - PRIVATE
    private func customizeTabman () {
        bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .progressive // Customize
        bar.backgroundView.style = .flat(color: .black)
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20, bottom: 0.0, right: 20)
        bar.buttons.customize { (button) in
            button.tintColor = UIColor.white
            button.font = Fonts.almarai()
            button.selectedFont = Fonts.almaraiBold()
            button.selectedTintColor = UIColor.white
            button.contentInset      = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        bar.indicator.tintColor = Theme.current.tintColor
    }
    
    private func setupHUD() {
        
        
        self.view.addSubview(hud)
        hud.snp.makeConstraints {
            $0.size.equalTo(70)
            $0.center.equalToSuperview()
        }
    }

    func showHUD () {
        hud.isHidden = false
        hud.startAnimating()
    }
    
    func hideHUD () {
        hud.isHidden = true
        hud.stopAnimating()
    }

}


// MARK: - DELEGATE
extension CustomTabmanVC: PageboyViewControllerDataSource, TMBarDataSource {
    
    // ITSM
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    // VC
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    // FIRST PAGE
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .first
    }
    
    // BAR ITEM
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: titles[index])
        return item
    }
    
}


// For Player 
extension CustomTabmanVC {
    override var prefersStatusBarHidden: Bool {
        return tabBar?.statusBarShouldBeHidden ?? false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {get {return .lightContent}}

    override var prefersHomeIndicatorAutoHidden: Bool {
        return tabBar?.homeIndicatorShouldBeHidden ?? false
    }
}
