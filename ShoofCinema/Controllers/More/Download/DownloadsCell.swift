//
//  DownloadCell.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/7/20.
//  Copyright © 2020 AppChief. All rights reserved.
//
import UIKit
import Kingfisher


protocol DownloadsActionDelegate  : AnyObject {
    func deleteAction (item : RDownload)
    func pauseAction (item : RDownload)
    func resumeAction (item : RDownload)
    func playAction (item : RDownload)
}

class DownloadsCell: UITableViewCell {
    
    // MARK: - LINKS
    @IBOutlet weak var poster: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var progressView: SCProgressView?
    @IBOutlet weak var playButton : MainButton!
    @IBOutlet weak var deleteButton : MainButton!
    @IBOutlet weak var resumeButton : MainButton!
    @IBOutlet weak var pauseButton : MainButton!
    
    
    // MARK: - VARS
    weak var actionDelegate : DownloadsActionDelegate?

    var rmDownload:RDownload! {
        didSet {
            
			let shoofShow = rmDownload.show?.asShoofShow()
            poster?.kf.setImage(with: shoofShow?.posterURL, placeholder: nil, options: [.transition(.fade(0.4))])
            
            if reuseIdentifier == "SHOW_HADER" {
                titleLabel.text = shoofShow?.title
                subtitle.text = shoofShow?.formattedGenres
                descriptionLabel.text = shoofShow?.description
            }
            else if reuseIdentifier == "EPISODE_LOADED" || reuseIdentifier == "EPISODE_LOADEING" {
                titleLabel.text = getCleanSeriesTitle(item : rmDownload)
                subtitle.text = .qualityText + rmDownload.resolution + "p"
            }
            // MOVIE
            else {
                titleLabel.text = rmDownload.show?.asShoofShow().title
                subtitle.text = .qualityText + rmDownload.resolution + "p"
            }
            
            updateUI(from: rmDownload)
        }
    }

    // MARK: - LOAD
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    
    
    
    func updateUI (from object:RDownload) {
        setButtonsForStatus(rmDownload.statusEnum)
        
        updateUI(rmDownload.statusEnum,
                progress: rmDownload.progress,
                speed: 0,
                speedUnit: "Kb",
                fileSize: rmDownload.file_size,
                fileSizUnit: rmDownload.file_unit,
                downloadedSize: rmDownload.downloaded_size,
                downloadedUnit: rmDownload.downloaded_unit)
                
    }
    
    func updateUI ( _ status:DownloadStatus,
               progress:Float,
               speed:Float?, speedUnit:String = "Kb",
               fileSize:Float?, fileSizUnit:String?,
               downloadedSize:Float?, downloadedUnit:String?
    ) {
        progressView?.set(status,
                         progress: progress,
                         speed: speed, speedUnit: speedUnit,
                         fileSize: fileSize, fileSizUnit: fileSizUnit,
                         downloadedSize: downloadedSize,downloadedUnit: downloadedUnit)
    }
    
    // MARK: - PRIVATE
    private func getCleanSeriesTitle (item : RDownload) -> String{
        let season = item.series_season_title ?? ""
        let episode = item.series_title ?? ""
        return  NSLocalizedString("episodeNameLowerCase", comment: "") + " \(episode), \(NSLocalizedString("seasonNameLowerCase", comment: "")) \(season)"
    }
    
    private func setButtonsForStatus(_ status : DownloadStatus) {
        switch status {
        case .downloaded:
            progressView?.isHidden = true
            pauseButton?.isHidden = true
            resumeButton?.isHidden = true
            
            deleteButton?.isHidden = false
            playButton?.isHidden = false
            
        case .downloading:
            progressView?.isHidden = false
            pauseButton?.isHidden = false
            deleteButton?.isHidden = false
            
            resumeButton?.isHidden = true
            playButton?.isHidden = true            
        case .failed:
            progressView?.isHidden = false
            deleteButton?.isHidden = false
            resumeButton?.isHidden = false
                    
            pauseButton?.isHidden = true
            playButton?.isHidden = true
        case .paused:
            progressView?.isHidden = false
            deleteButton?.isHidden = false
            resumeButton?.isHidden = false
                    
            pauseButton?.isHidden = true
            playButton?.isHidden = true
            
        default :
            progressView?.isHidden = true
            pauseButton?.isHidden = true
            resumeButton?.isHidden = true
            deleteButton?.isHidden = false
            playButton?.isHidden = true
        }
        
    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func deleteButtonTapped() {
        actionDelegate?.deleteAction(item: self.rmDownload)
    }
    
    @IBAction func pauseButtonTapped() {
        actionDelegate?.pauseAction(item: self.rmDownload)
    }
    
    @IBAction func resumeButtonTapped() {
        actionDelegate?.resumeAction(item: self.rmDownload)
    }
    
    @IBAction func playButtonButtonTapped() {
        actionDelegate?.playAction(item: self.rmDownload)
    }

}


fileprivate extension String {
    static let qualityText = NSLocalizedString("qualityText", comment: "")
}
