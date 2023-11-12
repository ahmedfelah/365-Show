//
//  ChannelPagesVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/23/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit



class ChannelPagesVC: CustomTabmanVC {
    
    // MARK: - VARS
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        getChannels()
    }
    
    private func setupView () {
        self.view.backgroundColor = Theme.current.backgroundColor
    }
    
    func getChannels () {
        // MARK: - API CALL ( get all channels data)
        view.hideNoContentView()
        showHUD()
//        channelsNM.getChannels()
        ShoofAPI.shared.loadTVSections { [weak self] result in
            do {
                let response = try result.get()
                let sections = response.sections
                
                DispatchQueue.main.async {
                    self?.view.hideNoContentView()
                    self?.titles = sections.map{ $0.name }
                    self?.viewControllers = sections.map { ChannelsVC(with: $0) }
                    self?.reloadData()
                    self?.hideHUD()
                }
            } catch {
                DispatchQueue.main.async {
					self?.hideHUD()
                    self?.view.showNoContentView(with: .genericErrorTitle, .noMatchesMessage, and: UIImage(named: .sadFaceIcon)!, actionButtonTitle: .tryAgainButtonTitle, reloadButtonAction: self?.getChannels)
                }
            }
        }
    }
}
