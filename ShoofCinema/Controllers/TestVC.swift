//
//  TestVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/7/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NFDownloadButton
class TestVC: UIViewController {
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let downloadButton = NFDownloadButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: downloadButton)
//        if let navBar = navigationController?.navigationBar as? MainNavigationBar {
//            navBar.
//        }
    }
    
    



}
