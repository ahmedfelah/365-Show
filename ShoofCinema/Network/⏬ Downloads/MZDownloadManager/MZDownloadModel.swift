//
//  MZDownloadModel.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit

public enum TaskStatus: Int {
    case unknown, gettingInfo, downloading, paused, failed
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        default:
            return "Unknown"
        }
    }
}

open class MZDownloadModel: NSObject {
    
    open var fileName: String!
    open var fileURL: String!
    open var status: String = TaskStatus.gettingInfo.description()
    
    open var file: (size: Float, unit: String)?
    open var downloadedFile: (size: Float, unit: String)?
    
    open var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    open var speed: (speed: Float, unit: String)?
    
    open var progress: Float = 0
    
    open var task: URLSessionDownloadTask?
    
    open var totalBytesWritten: Int64 = 0
    private var _totalBytesWrittenSecondBefore: Int64 = 0
    
    fileprivate(set) open var destinationPath: String = ""
    
    open var customData: Any?
        
    fileprivate convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
    
    convenience init(fileName: String, fileURL: String, destinationPath: String, customData:Any?) {
        self.init(fileName: fileName, fileURL: fileURL)
        
        self.destinationPath = destinationPath
        self.customData = customData
        
        fireWeakTimer()
    }
    func fireWeakTimer () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.updateSpeed()
            self?.fireWeakTimer()
        }
    }
    
    @objc func updateSpeed () {
        var diff = totalBytesWritten - _totalBytesWrittenSecondBefore
        if diff < 0 {
            diff = 0
        }
        let speedSize = MZUtility.calculateFileSizeInUnit(diff)
        let speedUnit = MZUtility.calculateUnit(diff)
        speed = (speedSize, speedUnit as String)
        _totalBytesWrittenSecondBefore = totalBytesWritten
    }
}
