//
//  DwonloadViewModel.swift
//  ShoofCinema
//
//  Created by mac on 9/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import RealmSwift


class DownloadsViewModel: ObservableObject {
    
    struct Download {
        var progress: Float
        var fileSize: Float?
        var status: DownloadStatus
        
    }
    
    let realm = try! Realm()
    
    @Published var downloads: [String : Download] = [:]
    
    @Published var data: Results<RDownload>
    
    var observer : NotificationToken?
    var mzManger : MZDownloadManager? {get {return isOutsideDomain ? nil : DownloadManager.shared.manager}}
    
    
    init() {
        data = realm.objects(RDownload.self)
            .sorted(by: ["order"])
        
        
        if isOutsideDomain {
            //data = data.filter("status = \(DownloadStatus.downloaded.rawValue)")
        } else {
            //observeChanges(in: data)
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
    }
    
    func pause(_ rmItem:RDownload) {
        
        if let taskIndex = taskIndex(for: rmItem) {
            DownloadManager.shared.manager.pauseDownloadTaskAtIndex(taskIndex)
        }
    }
    
    func resume(_ rmItem:RDownload) {
        if let taskIndex = taskIndex(for: rmItem) {
            DownloadManager.shared.manager.resumeDownloadTaskAtIndex(taskIndex)
        } else {
            redownload(rmItem, withTaskChecking: false)
        }
    }
    
    func delete(_ rmItem:RDownload, afterDeleteBlock:(()->())? = nil) -> Void {
        if isOutsideDomain {
            DownloadManager.delete(rmItem, beforeDeleteBlock: nil, afterDeleteBlock: { primaryKey in
                
                afterDeleteBlock?()
            })
        } else {
            if let item = rmItem.thaw() {
                DownloadManager.shared.cancelTaskAndDelete(item, beforeDeleteBlock: nil, afterDeleteBlock: nil)
            }
            
        }
        
    }
    
    func redownload(_ rmItem:RDownload, withTaskChecking:Bool = true) {
        if withTaskChecking {
            if let taskIndex = taskIndex(for: rmItem) {
                DownloadManager.shared.manager.cancelTaskAtIndex(taskIndex)
            }
        }
        
        //Redownload file
        DownloadManager.shared.download(from: rmItem)
    }
    
    func taskIndex(for rmItem:RDownload) -> Int? {
        if let taskIndex = DownloadManager.shared.manager.downloadingArray.firstIndex(where: {
            if let linkedRm = $0.customData as? RDownload {
                return linkedRm == rmItem.thaw()
            }
            else if $0.fileName == rmItem.video_filename || $0.fileName == rmItem.subtitle_filename {
                
                //Set custom data and return true
                $0.customData = rmItem.thaw()
                /*let error = RError(localizedTitle: "DownloadModel Lost Custom Data",
                                   localizedDescription: "Custom data was not set but match is exist, you should set custom data for all downloads in `viewDidLoad` or when download get started. [mStatus:\($0.status) & mStatus:\(rmItem.statusEnum.title), mProgress:\($0.progress) & mProgress:\(rmItem.progress) , mFileName:\($0.fileName ?? "Unknow")]",
                                   code: 404)
                Crashlytics.crashlytics().record(error:error)*/
                return true
            }
            return false
        }) {
            return taskIndex
        }
        
        print ("Could n't find task")
        return nil
    }
    
}


extension DownloadsViewModel: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        
        if item.isInvalidated {return}
        
        downloads[item.video_filename] = .init(progress: downloadModel.progress, status: item.statusEnum)
        
        print(downloadModel.progress)
        
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        
    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
//        guard let itemRow = data.index(of: item) else {
//            return
//        }
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }

        return array
    }
}
