//
//  DownloadManager-Additions.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/23/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

enum DownloadStatus:Int {
    case unknown
    case downloading
    case downloading_sub
    case paused
    case failed
    case loading
    case in_queue
    case downloaded

    var title:String {
        get {
            switch self {
            case .unknown:
                return NSLocalizedString("unknownStatus", comment: "")
            case .failed:
                return NSLocalizedString("failureStatus", comment: "")
            case .paused:
                return NSLocalizedString("pausedStatus", comment: "")
            case .downloaded:
                return NSLocalizedString("downloadedStatus", comment: "")
            case .in_queue:
                return NSLocalizedString("waitingStatus", comment: "")
            case .loading:
                return NSLocalizedString("loadingStatus", comment: "")
            case .downloading:
                return NSLocalizedString("downloadingStatus", comment: "")
            case .downloading_sub:
                return NSLocalizedString("downloadingTranslationStatus", comment: "")
            default:
                return ""
            }
        }
    }
    var icon:UIImage? {
        get {
            switch self {
            case .unknown:
                return UIImage(named: "CloudStop")
            case .downloading:
                return UIImage(named: "Download")
            case .failed:
                return UIImage(named: "ErrorTriangle")
            case .paused:
                return UIImage(named: "Pause")
            case .downloaded:
                return UIImage(named: "Phone")
            default:
                return nil
            }
        }
    }
}
