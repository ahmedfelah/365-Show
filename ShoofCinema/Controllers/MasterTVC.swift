//
//  BaseVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/20/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class MasterTVC: UITableViewController {
    

    
    var gradient : CAGradientLayer?
    let gradientView : UIView = {
        let view = UIView()
        return view
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationItem.backButtonTitle = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    internal func setupViews () {
        self.view.backgroundColor = Theme.current.backgroundColor
    }
    
    
    private func setupGradient(height: CGFloat, topColor: CGColor, bottomColor: CGColor) ->  CAGradientLayer {
         let gradient: CAGradientLayer = CAGradientLayer()
         gradient.colors = [topColor,bottomColor]
         gradient.locations = [0.0 , 1.0]
         gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
         gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
         gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: height)
         return gradient
    }
    func AddGradientNav(with height : CGFloat) {
        let height : CGFloat = 60
        let color = UIColor.black.cgColor
        let clear = UIColor.clear.cgColor
        gradient = setupGradient(height: height, topColor: color,bottomColor: clear)
        view.addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
        gradientView.layer.insertSublayer(gradient!, at: 0)
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
    override var preferredStatusBarStyle: UIStatusBarStyle { get { return tabBar?.preferredStatusBarStyle ?? .lightContent } }
}


