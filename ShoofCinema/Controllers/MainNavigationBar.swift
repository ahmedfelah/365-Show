//
//  MainNavigationBar.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/21/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class MainNavigationBar: UINavigationBar {

    required init?(coder: NSCoder) {
         super.init(coder: coder)
    }

    override func awakeFromNib() {
        customizeView()
    }
    
    private func customizeView () {
        self.tintColor = .white
        self.setBackgroundImage(UIImage(), for: .default)
        self.barTintColor = Theme.current.backgroundColor
        self.shadowImage = UIImage()
        self.isTranslucent = false
        self.backgroundColor = Theme.current.backgroundColor
        self.titleTextAttributes = [.foregroundColor: UIColor.white,
                                    NSAttributedString.Key.font: Fonts.almarai()
        ]
        let yourBackImage = UIImage(named: "ic-back-nav-icon")
        self.backIndicatorImage = yourBackImage
        self.backIndicatorTransitionMaskImage = yourBackImage
        self.backItem?.title = ""
    }
}



class NewMainNavigationController : UINavigationController {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        customizeView()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    
    override func awakeFromNib() {
        customizeView()
    }
    
    private func customizeView () {
        
        self.navigationBar.tintColor = .white
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.barTintColor = Theme.current.backgroundColor
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = false
        self.navigationBar.backgroundColor = Theme.current.backgroundColor
        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,
                                    NSAttributedString.Key.font: Fonts.almarai()
        ]
        let yourBackImage = UIImage(named: "ic-back-nav-icon")
        self.navigationBar.backIndicatorImage = yourBackImage
        self.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.navigationBar.backItem?.title = ""
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return tabBar?.homeIndicatorShouldBeHidden ?? false
    }
    
    override var prefersStatusBarHidden: Bool {
        return tabBar?.statusBarShouldBeHidden ?? false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return tabBar?.preferredStatusBarStyle ?? .lightContent } }}
