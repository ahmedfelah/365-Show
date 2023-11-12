//
//  ViewController.swift
//  Giganet
//
//  Created by Husam Aamer on 4/27/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import AVFoundation
import SwiftUI


class LoadingVC:MasterVC {
    
    @IBOutlet weak var indicator1 : NVActivityIndicatorView!
    @IBOutlet weak var indicator2 : NVActivityIndicatorView!
    
    
    var videoTimeRemaining = 3
    
    var timeObserverToken:Any?
    
    
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.current.backgroundColor
        
        //startLoading()
        if isDebugMode {
            delay(1) {
                self.toInsideMode()
            }
        } else {
            startLoading()
        }
    }
    
    
    
    // MARK: - PRIVATE
    private func startLoading() {
        ShoofAPI.shared.loadNetworkStatus { _ in
            DispatchQueue.main.async {
                let app = UIHostingController(rootView: ContentView())
                UIApplication.shared.keyWindow?.rootViewController = app
            }
        }
    }
    
    
    //    private func showIndicator () {
    //        indicator1.isHidden = false
    //        indicator2.isHidden = false
    //        indicator1.startAnimating()
    //        indicator2.startAnimating()
    //    }
    //    private func hideIndicator() {
    //        indicator1.isHidden = true
    //        indicator2.isHidden = true
    //        indicator1.stopAnimating()
    //        indicator2.stopAnimating()
    //    }
    
    private func toInsideMode () {
        let vc = UIStoryboard(name: "HomeSB", bundle: nil).instantiateViewController(withIdentifier: String(describing: RoundedTabBar.self))
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    private func handleAPIResponse(result: Result<ShoofAPI.Endpoint<[ShoofAPI.Section]>.Response, Error>?) {
        do {
            let response = try result?.get()
            let sections = response?.body ?? []

            DispatchQueue.main.async {
                let homeView = UIHostingController(rootView: HomeView())
                UIApplication.shared.keyWindow?.rootViewController = homeView
            }
        } catch {
            print("ERROR!", error)
        }
    }
    
    
        
        
}
