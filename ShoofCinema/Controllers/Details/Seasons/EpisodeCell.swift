//
//  EpisodTableViewCell.swift
//  Giganet
//
//  Created by Husam Aamer on 5/1/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import NFDownloadButton
import DownloadButton
import SwiftUI


protocol EpisodeCellActionDelegate : AnyObject {
    func didTapDownloadButton (for episode : ShoofAPI.Media.Episode, at index : Int)
}

class EpisodeCell: UITableViewCell {
    
    // MARK: - LINKS
    @IBOutlet weak var episodeNumberLabel: UILabel!
    @IBOutlet weak var watchingProgress: UIProgressView!
    @IBOutlet weak var downloadButton: MainButton!
    @IBOutlet weak var downloadedIcon: UIImageView!
    @IBOutlet weak var downloadProgress : PKCircleProgressView!

    
    var episode : ShoofAPI.Media.Episode?
    var idx : Int = 0
    weak var actionDelegate : EpisodeCellActionDelegate?
    
    // MARK: - LOAD
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        watchingProgress.layer.cornerRadius = 1
        watchingProgress.clipsToBounds = true
        downloadProgress.tintColor = UIColor(Color.primaryText)
        downloadProgress.filledLineWidth = 3
        downloadProgress.emptyLineWidth = 1
    }
    
    // MARK: - CONFIGURE
    public func configure (episode : ShoofAPI.Media.Episode ,index : Int , progress : Float, isSelected: Bool = false, downloadProgress :  CGFloat , downloadStatus : DownloadStatus)
    {
        self.episode = episode
        self.idx = index
        self.episodeNumberLabel.text = String(episode.number)
        self.watchingProgress.setProgress(progress, animated: false)
        self.watchingProgress.isHidden = progress == 0.0// || isSelected
        
        
        configureDownloadStatus(progress: downloadProgress, status: downloadStatus)

    }
    
    public func configureDownloadStatus (progress : CGFloat, status : DownloadStatus) {
        if !isOutsideDomain {
            if status == .downloaded {
                downloadedIcon.isHidden = false
                downloadButton.isHidden = true
                downloadProgress.isHidden = true
            } else if status == .downloading {
                downloadedIcon.isHidden = true
                downloadButton.isHidden = true
                downloadProgress.isHidden = false
                downloadProgress.progress = progress
            } else {
                downloadedIcon.isHidden = true
                downloadButton.isHidden = false
                downloadProgress.isHidden = true
            }
        } else {
            downloadedIcon.isHidden = true
            downloadButton.isHidden = true
            downloadProgress.isHidden = true
        }
    }
    
    
    // MARK: - SELECTED
    override func setSelected(_ selected: Bool, animated: Bool) {
        watchingProgress.isHidden = self.watchingProgress.progress == 0 || selected
        episodeNumberLabel.textColor = selected ? Theme.current.tintColor: .white
    }
    
    override func prepareForReuse() {
        downloadedIcon.isHidden = true
        downloadButton.isHidden = true
        downloadProgress.isHidden = true
        
        episodeNumberLabel.textColor = .white
    }
    
    // MARK: - ACTIONS
    @IBAction func downloadAction() {
        actionDelegate?.didTapDownloadButton(for: episode!, at: self.idx)
    }
}
