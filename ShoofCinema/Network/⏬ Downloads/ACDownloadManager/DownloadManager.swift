//
//  DownloadManager.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/10/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

var downloadManager : DownloadManager?

@objc protocol DownloadManagerDelegate : AnyObject {
    @objc optional func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item:RDownload)
    
    //@objc func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel])
    /**A delegate method called each time whenever new download task is start downloading
     */
    @objc optional func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int, for item:RDownload)
//    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
//     */
//    @objc optional func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int,for item:RmDownloadShow)
//    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
//     */
//    @objc optional func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int, for item:RmDownloadShow)
//    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
//     */
//    @objc optional func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int, for item:RmDownloadShow)
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    @objc optional func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item:RDownload)
//    /**A delegate method called each time whenever any download task is finished successfully
//     */
//    @objc optional func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int, for item:RmDownloadShow)
//    /**A delegate method called each time whenever any download task is failed due to any reason
//     */
//    @objc optional func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int, for item:RmDownloadShow)
//    /**A delegate method called each time whenever specified destination does not exists. It will be called on the session queue. It provides the opportunity to handle error appropriately
//     */
//    @objc optional func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL, for item:RmDownloadShow)
    
    @objc optional func downloadRequestWillDelete(rmDownloadShow item:RDownload)
    @objc optional func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?)
    @objc optional func downloadRequestDidChangedStatus(for item:RDownload,downloadModel: MZDownloadModel, index: Int)
}



class DownloadManager: NSObject {
    static var shared:DownloadManager {
        get{
            //If outside domain then don't initiate any download process
            if isOutsideDomain {
                fatalError("You are not allowed to start or get information of any process from outside domain")
            }
            
            if downloadManager == nil {
                downloadManager = DownloadManager()
            }
            
            return downloadManager!
        }
    }
    
    /// Allowed classes delegates
    typealias AllowedDelegateObserver = (DownloadManagerDelegate)
    
    /// Observer will receive messages about all downloads changes, NSPointerArray allowes weak reference to observers
    private var _downloadsObservers = NSPointerArray.weakObjects()
    
    /// Observer will receive messages for one download task
    private weak var _oneDownloadObserver:AllowedDelegateObserver?
    
    
    /// Observer will receive messages about all downloads changes
    /// - Parameter observer: AllowedDelegateObserver
    func observeAllDownloads(observer:AllowedDelegateObserver) {
        _downloadsObservers.addObject(observer)
    }
    
    /// Download manager
    var manager : MZDownloadManager!
    
    
    override init() {
        super.init()
        manager = MZDownloadManager(session: "com.appchief.mzDownloadSession", delegate: self)
    }
    
    /// Cell this on app launch to continue downloads and verify database statuses
    func continueAvailableDownloads () {
        //Will auto continue upon initiation
        
        
        var mzmodels = [String:Int]()
        for (index,model) in manager.downloadingArray.enumerated() {
            mzmodels[model.fileName] = index
        }

        debugPrint("continueAvailableDownloads VERIFY DB FOR DOWNLOADS \n", mzmodels)
        
        let data = realm.objects(RDownload.self)
            .filter("status != %i",DownloadStatus.downloaded.rawValue)
        try? realm.write {
            if data.count > 0 {
                for item in data {

                    let status = item.statusEnum
                    var newStatus:DownloadStatus?

                    
                    if let modelIndex = mzmodels[item.video_filename] {
                        if modelIndex >= manager.downloadingArray.count {
                            if status != .downloaded {
                                newStatus = .unknown
                            }
                            
                        } else {
                            /// Set custom data for all existing downloads
                            manager.downloadingArray[modelIndex].customData = item
                            
                            let model = manager.downloadingArray[modelIndex]
                            
                            if model.status == TaskStatus.downloading.description() && !(status == .downloading_sub || status == .downloading) {
                                newStatus = .downloading
                            }
                            else if model.status == TaskStatus.gettingInfo.description() && status != .loading {
                                newStatus = .loading
                            }
                            else if model.status == TaskStatus.paused.description() && status != .paused {
                                newStatus = .paused
                            }
                            else if model.status == TaskStatus.failed.description() && status != .failed {
                                newStatus = .failed
                            }
                        }
                    } else {
                        /// No in progress download for this rm item
                        
                        /*
                         GOOD TO KNOW
                         if item forced to pause on last app termination `applicationWillTerminate` , then it would not be listed in mzdownloads list. until download is get populated by MZDownloadManager class!
                        */
                        if status == .paused {
                            // Don't change status, wait for download population in `didPolpulateInterruptedTask`
                        } else
                        // This might be a "series fake header", "downloaded file" or a download that failed many times then task canceled by iOS
                        if status != .downloaded {
                            newStatus = .failed
                        }
                    }

                    //Write new verified status
                    if let newStatus = newStatus {
                        item.status = newStatus.rawValue
                    }
                }
            }
            
            /// Clean downloads that are exist in manager but not exist in db
            var toCancelModels : [Int] = []
            manager.downloadingArray.enumerated().forEach { (index,toTestModel) in
                if toTestModel.customData == nil {
                    toCancelModels.append(index)
                }
            }
            toCancelModels.forEach({manager.cancelTaskAtIndex($0)})
        }
    }
    
    
    /// Call this in AppDelegate `applicationWillTerminate` to save current status of download to database
    func applicationWillTerminate () {
        for (index,downloadModel) in manager.downloadingArray.enumerated() {
            
            if let rmDownload = objectFor(downloadModel) {
                //print("applicationWillTerminate", downloadModel.fileName, "updated database")
                update(rmDownload , setProgressFrom: downloadModel, at: index)
            }
        }
    }
    func update(_ rmDownload:RDownload,
                setStatus status:DownloadStatus? = nil,
                setProgressFrom mzmodel:MZDownloadModel,
                at index:Int, additionalWriteBlock:((RDownload)->())? = nil)
    {
        try? realm.write {
            if let status = status {
                rmDownload.status = status.rawValue
            }
            if mzmodel.status == TaskStatus.downloading.description() {
            }
            rmDownload.progress = mzmodel.progress
            if let file = mzmodel.file {
                rmDownload.file_unit = file.unit
                rmDownload.file_size = file.size
            }
            if let file = mzmodel.downloadedFile {
                rmDownload.downloaded_unit = file.unit
                rmDownload.downloaded_size = file.size
            }
            additionalWriteBlock?(rmDownload)
        }
        /**UPDATE OBSERVERS*/
        for observer in _downloadsObservers.allObjects {
            if let observer = observer as? AllowedDelegateObserver {
                observer.downloadRequestDidChangedStatus?(for: rmDownload, downloadModel: mzmodel, index: index)
            }
        }
    }
    /// Called when download is canceled
    /// - Parameter rmDownload: object to be deleted
    func cancelTaskAndDelete(_ rmDownload:RDownload,
                beforeDeleteBlock:((RDownload)->())? = nil,
                afterDeleteBlock:((Any?)->())? = nil)
    {
        /**
        # STEP 1 : CANCEL TASK IF EXIST
        */
        var taskIndex:Int?
        if let _taskIndex = manager.downloadingArray.firstIndex(where: {
            if let linkedRm = $0.customData as? RDownload {
                return linkedRm == rmDownload
            }
            return false
        }) {
            taskIndex = _taskIndex
            DownloadManager.shared.manager.cancelTaskAtIndex(_taskIndex)
        }
        
        /**
         # STEP 2 : DELETE RmDownloadShow
         */
        
        /**UPDATE OBSERVERS*/
        for observer in _downloadsObservers.allObjects {
            if let observer = observer as? AllowedDelegateObserver {
                observer.downloadRequestWillDelete?(rmDownloadShow: rmDownload)
            }
        }
        
        if let taskIndex = taskIndex {
            DownloadManager.shared.manager.downloadingArray[taskIndex].customData = nil
        }

        DownloadManager.delete(rmDownload, beforeDeleteBlock: beforeDeleteBlock, afterDeleteBlock: { primaryKey in
            
            afterDeleteBlock?(primaryKey)
            
            /**UPDATE OBSERVERS*/
            for observer in self._downloadsObservers.allObjects {
                if let observer = observer as? AllowedDelegateObserver {
                    observer.downloadRequestDidDeleteRmDownloadShow?(with: primaryKey)
                }
            }
        })
        
        
    }
    static func delete(_ rmDownload:RDownload,
        beforeDeleteBlock:((RDownload)->())? = nil,
        afterDeleteBlock:((Any?)->())? = nil)
    {
        beforeDeleteBlock?(rmDownload)
        let primaryKey = rmDownload.video_filename
        do {
            try RealmManager.deleteDownloadObject(rmDownload)

            afterDeleteBlock?(primaryKey)
            
        } catch {
            downlaodFailed(with: error)
        }
    }
    
    ////////////////////////////////////
    /// Start a download from Show object
    /// - Parameter show: Show
	func download(_ episode:ShoofAPI.Media.Episode? = nil ,
				  in season:ShoofAPI.Media.Season? = nil,
				  show:ShoofAPI.Show,
				  source:CPlayerResolutionSource) -> RDownload?
    {
        do {
            let rm = try RealmManager.createDownloadObjectFor(show,
															  and: episode,
															  in: season,
															  from:source)
            return download(from: rm)
        } catch {
            let error = RError(localizedTitle: "Database Error", localizedDescription: error.localizedDescription, code: 400)
            DownloadManager.downlaodFailed(with: error)
        }
        return nil
    }
    
    
    /// Start download from rmDownload object
    @discardableResult
    func download (from rmDownload:RDownload) -> RDownload {
        
        do {
            //Download subtitle if exist and not downloaded yet
            if let sub_url = rmDownload.subtitle_url , let sub_filename = rmDownload.subtitle_filename {
                if !rmDownload.subtitle_downloaded {
                    try removeFileIfExsist(at: sub_filename)
                    manager.addDownloadTask(sub_filename , fileURL: sub_url, destinationPath:"", customData: rmDownload)//Add directory before adding path
                    return rmDownload
                }
            }
            
            //Download movie
            let testUrl = rmDownload.video_url
            let filename = rmDownload.video_filename
            try removeFileIfExsist(at: filename)
            manager.addDownloadTask( filename,
                                     fileURL: testUrl,
                                     destinationPath:"", //Add directory before adding path
                                     customData:rmDownload)
        } catch {
            DownloadManager.downlaodFailed(with: error)
        }
        
        return rmDownload
    }
    func removeFileIfExsist(at path:String) throws {
        
        let subtitlePath = MZUtility.baseFilePath + path
        if FileManager.default.fileExists(atPath: subtitlePath) {
            try FileManager.default.removeItem(atPath: subtitlePath)
        }
    }
    /// Called when download get failed to show message directly to the user
    /// - Parameter error: Error object
    static fileprivate func downlaodFailed (with error:Error) {
        
        let alert = UIAlertController(title: NSLocalizedString("downloadErrorMessage", comment: ""), message: error.localizedDescription, preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("dismissAlertButton", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /// get rm object
    func objectFor(_ downloadModel:MZDownloadModel) -> RDownload? {
        //debugPrint(#function)
        if let rm = downloadModel.customData as? RDownload {
            return rm
        }
        
        
        let searchForKey = downloadModel.fileName.hasPrefix("sub") ? "subtitle_filename" : "video_filename"
        if let rm = realm.objects(RDownload.self)
            .filter("\(searchForKey) = %@",downloadModel.fileName!).first {
            
            if let index = manager.downloadingArray.firstIndex(of: downloadModel) {
                manager.downloadingArray[index].customData = rm
            }

            // This should be fired on download start only
            debugPrint("xxxxxxxxxxx Custom data was not set",downloadModel.fileName ?? "")
//            let error = NSError(domain: "com.appchief.supercell", code: 404, userInfo: [
//                "title":"DownloadModel Lost Custom Data",
//                "description":"Custom data was not set but match is exist, you should set custom data for all downloads in `viewDidLoad` or when download get started. [mStatus:\(downloadModel.status) & mStatus:\(rm.statusEnum.title), mProgress:\(downloadModel.progress) & mProgress:\(rm.progress) , mFileName:\(downloadModel.fileName ?? "Unknow")]"
//            ])
//            Crashlytics.sharedInstance().recordError(error)
            
            return rm
        }
        
        return nil
    }
}

extension DownloadManager: MZDownloadManagerDelegate {
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel]) {
        debugPrint("did populated \(downloadModel)", "Is main thread \(Thread.isMainThread)")
        //Sometimes app terminated on
        for model in downloadModel {
            guard let rmDownload = objectFor(model) else {
                /**
                 يمكن اليوزر ماسح الداونلود سابقاً وانمسح من الداتابيس بس ما انمسح من الداونلود
                 */
                if let index = manager.downloadingArray.firstIndex(of: model) {
                    manager.cancelTaskAtIndex(index)
                    
                    let error = NSError(
                        domain: "com.appchief.supercell",
                        code: 404,
                        userInfo: [
                      "title":"Custom data was not set but match is exist",
                      "description":"Custom data was not set but match is exist, you should set custom data for all downloads in `viewDidLoad` or when download get started. [mStatus:\(model.status), mProgress:\(model.progress), mFileName:\(model.fileName ?? "Unknow")]"
                    ])
                    Crashlytics.crashlytics().record(error:error)
                    continue
                }
                
                fatalError("Couldn't find model with filename \(String(describing: model.fileName))")
            }
            
            
            if rmDownload.statusEnum == .paused && model.status == TaskStatus.failed.description() {
                /**
                # ABOUT THIS CASE
                 
                   A VERY IMPORTANT NOTE HERE
                IF USER PAUSED A DOWNLOAD TASK THEN TERMINATED THE APP, TASK WILL BE POPULATED AS COMPLETED WITH FAILED STATUS on next launch!
                SO YOU HAVE TO CHECK THE DATABASE STATUS TO ENSURE THE STATUS IS TRUE
                
                 🤦🏻‍♂️🤦🏻‍♂️🤦🏻‍♂️🤦🏻‍♂️
                */
                
            } else {
                try? realm.write {
                    if model.status == TaskStatus.downloading.description() {
                        rmDownload.status = model.fileName.hasPrefix("sub") ? DownloadStatus.downloading_sub.rawValue : DownloadStatus.downloading.rawValue
                    } else if model.status == TaskStatus.paused.description() {
                        rmDownload.status = DownloadStatus.paused.rawValue
                    } else if model.status == TaskStatus.failed.description() {
                        rmDownload.status = DownloadStatus.failed.rawValue
                    }
                }
            }
        }
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function, downloadModel.fileName, downloadModel.status)
        guard let rmDownload = objectFor(downloadModel) else {
            fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
        }
        
        let isdownloadingSubtitle = downloadModel.fileName.hasPrefix("sub")
        update(rmDownload, setStatus: isdownloadingSubtitle ? DownloadStatus.downloading_sub : DownloadStatus.downloading, setProgressFrom: downloadModel, at: index)
        
        /**UPDATE OBSERVERS*/
        for observer in _downloadsObservers.allObjects {
            if let observer = observer as? AllowedDelegateObserver {
                observer.downloadRequestStarted?(downloadModel, index: index, for: rmDownload)
            }
        }
    }
    
    func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function, downloadModel.fileName, "Is main thread \(Thread.isMainThread)")
        
        guard let rmDownload = objectFor(downloadModel) else {
            fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
        }
        
        update(rmDownload, setStatus: downloadModel.fileName.hasPrefix("sub") ? DownloadStatus.downloading_sub : DownloadStatus.downloading, setProgressFrom: downloadModel, at: index)
    }
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function,index, downloadModel.fileName)
        
        guard let rmDownload = objectFor(downloadModel) else {
            fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
        }
        
        let isdownloadingSubtitle = downloadModel.fileName.hasPrefix("sub")
        
        if isdownloadingSubtitle {
            update(rmDownload, setStatus: .downloading, setProgressFrom: downloadModel, at: index, additionalWriteBlock: {
                $0.subtitle_downloaded = true
            })
            download(from: rmDownload)
        } else {
            update(rmDownload, setStatus: .downloaded, setProgressFrom: downloadModel, at: index)
        }
    }
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function,index, downloadModel.fileName)
        
        guard let rmDownload = objectFor(downloadModel) else {
            fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
        }
        
        update(rmDownload, setStatus: DownloadStatus.paused, setProgressFrom: downloadModel, at: index)
    }
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function,index, downloadModel.fileName)
        
        guard let rmDownload = objectFor(downloadModel) else {
            fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
        }
        
        update(rmDownload, setStatus: downloadModel.fileName.hasPrefix("sub") ? DownloadStatus.downloading_sub : DownloadStatus.downloading, setProgressFrom: downloadModel, at: index)
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        //debugPrint(#function,index, NSString.init(format: "%.2f%% %@", downloadModel.progress * 100, downloadModel.fileName ?? ""))
        
        
        //Do we have any listener?
        if _downloadsObservers.count == 0 && _oneDownloadObserver == nil {return}
        
        //Get rm from object
        guard let rmDownload = objectFor(downloadModel) else {
            //Manager has a download task but item is not registered in database
            //Database might be changed manually, or deletion done but task cancellation failed recently
            manager.cancelTaskAtIndex(index)
            //fatalError("Couldn't find rmDownloadShow with filename \(String(describing: downloadModel.fileName))")
            return
        }
        
        /**UPDATE OBSERVERS*/
        for observer in _downloadsObservers.allObjects {
            if let observer = observer as? AllowedDelegateObserver {
                observer.downloadRequestDidUpdateProgress?(downloadModel, index: index, for: rmDownload)
            }
        }
    }
    
    
    
    
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        debugPrint(#function, downloadModel.fileName, "Is main thread \(Thread.isMainThread)")
        
        in_main {
            guard let rmDownload = self.objectFor(downloadModel) else {
                fatalError("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
            }
            
            self.update(rmDownload, setStatus: DownloadStatus.failed, setProgressFrom: downloadModel, at: index)
        }
    }
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        debugPrint(error, downloadModel.fileName, "Is main thread \(Thread.isMainThread)")
        DownloadManager.downlaodFailed(with: error)
        
        if error.code == 17 { //File exist
            
        }
        guard let rmDownload = objectFor(downloadModel) else {
            debugPrint("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
            return
        }
        
        update(rmDownload, setStatus: .failed, setProgressFrom: downloadModel, at: index)
    }
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        debugPrint(#function, downloadModel.fileName)
        
        guard let rmDownload = objectFor(downloadModel) else {
            debugPrint("Couldn't find model with filename \(String(describing: downloadModel.fileName))")
            return
        }
        
        /**UPDATE OBSERVERS*/
        for observer in _downloadsObservers.allObjects {
            if let observer = observer as? AllowedDelegateObserver {
                observer.downloadRequestCanceled?(downloadModel, index: index, for: rmDownload)
            }
        }
        
        /**
         
         # DELETING RM MODEL IS DONE IN `delete()` function
         
         */
    }
    func downloadRequestFinishedFiledMoved(to location: NSURL, _ downloadModel: MZDownloadModel, index: Int, fileName: String, fileExtension: String) {
    }
}
