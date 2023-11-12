//
//  SCProgressView.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/9/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

class SCProgressBarView: UIView {
    
    var progress:Float = 0 {
        didSet {
            updatePercentageLabel()
        }
    }
    
    lazy var loadedView = UIView()
    lazy var percentageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commoonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commoonInit()
    }
    func commoonInit (){
        clipsToBounds = true
        
        backgroundColor = UIColor(red:0.21, green:0.21, blue:0.21, alpha:1) // Dark lava
        loadedView.backgroundColor = UIColor(red:0.75, green:0.14, blue:0.26, alpha:1) // Bright maroon
        loadedView.frame = CGRect(origin: .zero,
                                  size: CGSize(width: 0, height: frame.height))
        //percentageLabel.backgroundColor = .green
        percentageLabel.font = Fonts.almaraiBold(13)
        percentageLabel.frame            = CGRect(x: 0, y: 0,width: 50, height: frame.height)
        percentageLabel.textColor        = .white
        percentageLabel.textAlignment    = .center

        addSubview(loadedView)
        addSubview(percentageLabel)
        percentageLabel.snp.makeConstraints({
            $0.leading.equalTo(8)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(50)
        })
        loadedView.snp.makeConstraints({
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(0)
        })
        
        updatePercentageLabel()
    }
    
    private func updatePercentageLabel () {
        let _percent = progress.isNaN ? 0 : progress
        
        percentageLabel.text = (DownloadsVC.formatter.string(from: NSNumber(floatLiteral: Double(_percent * 100))) ?? "0") + "%"
        
        updateLoadedView()
    }
    func updateLoadedView () {
        let _percent = progress.isNaN ? 0 : progress
        
        let loadedWidth = CGFloat(_percent) * frame.width
        loadedView.snp.updateConstraints({
            $0.width.equalTo(loadedWidth)
        })
    }
    
    func changeStatus(to status:DownloadStatus) {
        if status == .downloading {
            loadedView.backgroundColor = Theme.current.tintColor
        } else {
            loadedView.backgroundColor = Theme.current.captionsDarkerColor
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //Rounding corners
        layer.cornerRadius = frame.height / 2
        updateLoadedView()
    }
}
