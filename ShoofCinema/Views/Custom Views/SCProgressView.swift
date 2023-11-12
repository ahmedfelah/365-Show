//
//  SCProgressView.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/9/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

class SCProgressView: UIView {
    
    var currentStatus           = DownloadStatus.unknown
    lazy var bar                = SCProgressBarView()
    lazy var leftStack          = UIStackView()
    lazy var statusIcon         = UIImageView()
    lazy var downloadedLabel    = UILabel()
    lazy var slashLabel         = UILabel()
    lazy var sizeLabel          = UILabel()
    lazy var rightLabel         = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commoonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commoonInit()
    }
    func commoonInit (){
        
        slashLabel.text = "\\"
        
        let font = Fonts.almaraiLight(12.5)
        downloadedLabel.font    = font
        slashLabel.font         = font
        sizeLabel.font          = font
        rightLabel.font         = font
        
        downloadedLabel.textColor   = Theme.current.captionsColor
        slashLabel.textColor        = Theme.current.captionsDarkerColor
        sizeLabel.textColor         = Theme.current.captionsDarkerColor
        rightLabel.textColor        = Theme.current.captionsDarkerColor
        
        statusIcon.tintColor        = Theme.current.captionsColor
        
        leftStack.spacing = 4
        
        
        // Add views
        addSubview(bar)
        addSubview(leftStack)
        leftStack.addArrangedSubview(statusIcon)
        leftStack.addArrangedSubview(downloadedLabel)
        leftStack.addArrangedSubview(slashLabel)
        leftStack.addArrangedSubview(sizeLabel)
        addSubview(rightLabel)
        
        
        // Set constraints
        bar.snp.makeConstraints({
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(18)
        })
        leftStack.snp.makeConstraints({
            $0.top.equalTo(bar.snp_bottom).offset(6)
            $0.leading.equalToSuperview().offset(6)
            
            //To give the view a height equal to its content
            //$0.bottom.equalToSuperview()
        })
        
        //For small screens
        if UIScreen.main.bounds.width <= 320 {
            rightLabel.snp.makeConstraints({
                $0.centerY.equalTo(bar.snp_centerY)
                $0.trailing.equalTo(bar.snp_trailing).offset(-6)
            })
        } else {
            rightLabel.snp.makeConstraints({
                $0.top.equalTo(bar.snp_bottom).offset(6)
                $0.trailing.equalToSuperview().offset(-6)
            })
        }
        
        statusIcon.snp.makeConstraints({
            $0.width.height.equalTo(14)
        })
    }
    
    func set ( _ status:DownloadStatus,
               progress:Float,
               speed:Float?, speedUnit:String = "KB",
               fileSize:Float?, fileSizUnit:String?,
               downloadedSize:Float?, downloadedUnit:String?
    ) { 
        if currentStatus != status {
            currentStatus = status
            bar.changeStatus(to: status)
            statusIcon.image = DownloadStatus.downloading.icon
        }
        bar.progress = progress
        
        
        if status == .downloading {
            slashLabel.isHidden     = false
            
            if let speed = DownloadsVC.formatter.string(from: NSNumber(floatLiteral: Double(speed ?? 0)))
            {
                rightLabel.text = "\(speed) \(speed == "0" ? "Kb" : speedUnit)/s"
            }
            if let downloaded = DownloadsVC.formatter.string(from: NSNumber(floatLiteral: Double(downloadedSize ?? 0))),
                let size = DownloadsVC.formatter.string(from: NSNumber(floatLiteral: Double(fileSize ?? 0)))
            {
                downloadedLabel.text = "\(downloaded) \(downloadedUnit ?? "KB")"
                sizeLabel.text = "\(size) \(fileSizUnit ?? "KB")"
            }
        } else {
            slashLabel.isHidden     = true
            downloadedLabel.text    = status.title
            sizeLabel.text          = ""
            rightLabel.text         = ""
            statusIcon.image        = status.icon
        }
    }
}
