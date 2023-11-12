//
//  SCDownloadButton.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/29/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

class SCDownloadButton: SCButton {
    var currentStatus:DownloadStatus = .unknown
    var downloadingImage : AnimatedDownloadIcon?
    
    /// Small button shows icon and percentage only
    var isSmall:Bool = false {
        didSet {
            setStatus(currentStatus)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            isEnabled = !isSelected
        }
    }
    override func commonInit(fontSize: CGFloat? = nil) {
        super.commonInit(fontSize: fontSize)
        
        setTitle(isSmall ? nil : "تحميل", for: .normal)
        setImage(UIImage(named: "Download"), for: .normal)
    }
    func setStatus(_ status:DownloadStatus, with progress:Float? = nil) {
        /// Button is always selected except when status == .unknown
        if status != .unknown, isSelected == false {
            isSelected = true
        }
        
        switch status {
        case .unknown:
            isSelected = false
            setTitle(isSmall ? nil : "تحميل", for: .normal)
            setImage(UIImage(named: "Download"), for: .normal)
            
            downloadingImage?.removeFromSuperview()
            downloadingImage = nil
            break
        case .downloading, .downloading_sub:
            
            /// At start of downloading
            if downloadingImage == nil {
                /// Use empty clear icon to easily save title and icon insets 
                setImage(UIImage(named: "ClearIcon"), for: .selected)
                setImage(UIImage(named: "ClearIcon"), for: .normal)
                
                downloadingImage = AnimatedDownloadIcon()
                downloadingImage?.frame = imageView!.frame
                addSubview(downloadingImage!)
                downloadingImage?.snp.makeConstraints({
                    if let btnImageview = imageView {
                        $0.center.equalTo(btnImageview.snp_center)
                    } else {
                        $0.centerX.equalTo(frame.width/4)
                        $0.centerY.equalToSuperview()
                    }
                })
            }
            break
        default:
            downloadingImage?.removeFromSuperview()
            downloadingImage = nil
            
            setTitle( isSmall ? nil : status.title, for: .normal)
            setTitle( isSmall ? nil : status.title, for: .selected)
            
            if status != currentStatus {
                setImage(status.icon, for: .normal)
                setImage(status.icon, for: .selected)
            }
            break
        }
        
        
        if var progress = progress , status != .downloaded {
            /// Progress may be in minus where file is under 1KB size (ex: srt files)
            progress = progress < 0 ? 0 : progress
            
            let progressString = NSString(format: "%.02f%%", progress * 100) as String
            setTitle(progressString, for: .normal)
            setTitle(progressString, for: .selected)
        }
        
        if titleLabel?.text == nil {
            imageEdgeInsets.left = -6
        } else {
            imageEdgeInsets.left = 0
        }
    }
}

