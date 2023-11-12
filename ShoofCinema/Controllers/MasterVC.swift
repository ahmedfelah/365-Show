//
//  BaseVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/20/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MasterVC: UIViewController {
    
    let hud = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70) , type: .ballPulse, color: Theme.current.tintColor, padding: 0)
    var gradient : CAGradientLayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationItem.backButtonTitle = ""
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupHUD()
    }
    
    
    internal func setupViews () {
        self.view.backgroundColor = Theme.current.backgroundColor
        
        
    }
    
    
    func setupClearNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func addGradientNav() {
        let gradientView = GradientView()
        let color = Theme.current.backgroundColor.withAlphaComponent(0.4).cgColor
        let clear = UIColor.clear.cgColor
		gradientView.isUserInteractionEnabled = false
        gradientView.gradientLayer.colors = [color,clear]
        gradientView.gradientLayer.locations = [0.0 , 1.0]
        gradientView.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientView.gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)

        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 70),
        ])
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle { get {return .lightContent} }
    

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

