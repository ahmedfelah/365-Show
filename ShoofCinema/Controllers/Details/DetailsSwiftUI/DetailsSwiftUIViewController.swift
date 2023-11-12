//
//  DetailsSwiftUIViewController.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit
import SwiftUI

class DetailsSwiftUIViewController: UIViewController {
    
    var show: ShoofAPI.Show?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let hostView = UIHostingController(rootView: DetailsView(show: show, tab: tabBar!, parentVC: self))
        
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hostView.view)
        
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        self.view.addConstraints(constraints)
        
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
