//
//  MZDownloadManager.swift
//  MZDownloadManager
//
//  Created by Muhammad Zeeshan on 19/04/2016.
//  Copyright © 2016 ideamakerz. All rights reserved.
//

import UIKit
import FirebaseCrashlytics

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc public protocol MZDownloadManagerDelegate: class {
    /**A delegate method called each time whenever any download task's progress is updated
     */
    @objc func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called when interrupted tasks are repopulated
     */
    @objc func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel])
    /**A delegate method called each time whenever new download task is start downloading
     */
    @objc optional func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever running download task is paused. If task is already paused the action will be ignored
     */
    @objc optional func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    @objc optional func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is resumed. If task is already downloading the action will be ignored
     */
    @objc optional func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is cancelled by the user
     */
    @objc optional func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any download task is finished successfully
     */
    @objc optional func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever any finished downloaded file moved to the final location
     */
    @objc optional func downloadRequestFinishedFiledMoved(to location:NSURL,_ downloadModel: MZDownloadModel, index: Int, fileName:String, fileExtension:String)
    /**A delegate method called each time whenever any download task is failed due to any reason
     */
    @objc optional func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int)
    /**A delegate method called each time whenever specified destination does not exists. It will be called on the session queue. It provides the opportunity to handle error appropriately
     */
    @objc optional func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL)
    
}

open class MZDownloadManager: NSObject {
    
    fileprivate var sessionManager: URLSession!
    
    fileprivate var backgroundSessionCompletionHandler: (() -> Void)?
    
    fileprivate let TaskDescFileNameIndex = 0
    fileprivate let TaskDescFileURLIndex = 1
    fileprivate let TaskDescFileDestinationIndex = 2
    
    fileprivate weak var delegate: MZDownloadManagerDelegate?
    
    open var downloadingArray: [MZDownloadModel] = []
    
    public convenience init(session sessionIdentifer: String, delegate: MZDownloadManagerDelegate, sessionConfiguration: URLSessionConfiguration? = nil, completion: (() -> Void)? = nil) {
        self.init()
        self.delegate = delegate
        self.sessionManager = backgroundSession(identifier: sessionIdentifer, configuration: sessionConfiguration)
        self.populateOtherDownloadTasks()
        self.backgroundSessionCompletionHandler = completion
    }
    
    public class func defaultSessionConfiguration(identifier: String) -> URLSessionConfiguration {
        return URLSessionConfiguration.background(withIdentifier: identifier)
    }
    
    fileprivate func backgroundSession(identifier: String, configuration: URLSessionConfiguration? = nil) -> URLSession {
        let sessionConfiguration = configuration ?? MZDownloadManager.defaultSessionConfiguration(identifier: identifier)
        assert(identifier == sessionConfiguration.identifier, "Configuration identifiers do not match")
        let session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }
}

// MARK: Private Helper functions

extension MZDownloadManager {
    
    fileprivate func downloadTasks() -> [URLSessionDownloadTask] {
        var tasks: [URLSessionDownloadTask] = []
        let semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            tasks = downloadTasks
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        debugPrint("MZDownloadManager: pending tasks \(tasks)")
        
        return tasks
    }
    
    fileprivate func populateOtherDownloadTasks() {
        
        let downloadTasks = self.downloadTasks()
        
        for downloadTask in downloadTasks {
            guard let taskDescComponents: [String] = downloadTask.taskDescription?.components(separatedBy: ",") else {
                return
            }
            let fileName = taskDescComponents[TaskDescFileNameIndex]
            let fileURL = taskDescComponents[TaskDescFileURLIndex]
            let destinationPath = taskDescComponents[TaskDescFileDestinationIndex]
            
            let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath, customData: nil) //Set customData in didPopulate delegate
            downloadModel.task = downloadTask
            
            if downloadTask.state == .running {
                downloadModel.status = TaskStatus.downloading.description()
                downloadingArray.append(downloadModel)
            } else if(downloadTask.state == .suspended) {
                downloadModel.status = TaskStatus.paused.description()
                downloadingArray.append(downloadModel)
            } else {
                ///This happens when user pause download then relaunch the app, The surprise is that the populated `downloadTask` state would be `completed`
                if downloadTask.state == .completed && downloadTask.countOfBytesReceived != downloadTask.countOfBytesExpectedToReceive {
                    downloadModel.status = TaskStatus.paused.description()
                } else {
                    downloadModel.status = TaskStatus.failed.description()
                }
            }
        }
    }
    
    fileprivate func isValidResumeData(_ resumeData: Data?) -> Bool {
        
        guard resumeData != nil || resumeData?.count > 0 else {
            return false
        }
        
        return true
        
    }
}

extension MZDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        for (index, downloadModel) in self.downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
                    var totalBytesCount = downloadTask.countOfBytesExpectedToReceive
                    var progress:Float!
                    if totalBytesCount != -1 { // For small files value might be -1
                        progress = Float(receivedBytesCount / Double(totalBytesCount))
                    } else {
                        totalBytesCount = 0
                        progress = 0
                    }
                    
                    let remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten
                    
                    var writtenBytes = (Float(totalBytesWritten) - Float(downloadModel.totalBytesWritten))

                    
                    if writtenBytes.isNaN || writtenBytes.isInfinite || writtenBytes == 0 {
                        writtenBytes = 1
                    }
                    
                    let remainingTime = remainingContentLength / Int64(writtenBytes)
                    let hours = Int(remainingTime) / 3600
                    let minutes = (Int(remainingTime) - hours * 3600) / 60
                    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
                    
                    let totalFileSize = MZUtility.calculateFileSizeInUnit(totalBytesCount)
                    let totalFileSizeUnit = MZUtility.calculateUnit(totalBytesCount)
                    
                    let downloadedFileSize = MZUtility.calculateFileSizeInUnit(totalBytesWritten)
                    let downloadedSizeUnit = MZUtility.calculateUnit(totalBytesWritten)
                    
                    downloadModel.remainingTime = (hours, minutes, seconds)
                    downloadModel.file = (totalFileSize, totalFileSizeUnit as String)
                    downloadModel.downloadedFile = (downloadedFileSize, downloadedSizeUnit as String)
                    downloadModel.progress = progress
                    
                    downloadModel.totalBytesWritten = totalBytesWritten
                    
                    
                    if self.downloadingArray.contains(downloadModel), let objectIndex = self.downloadingArray.firstIndex(of: downloadModel) {
                        self.downloadingArray[objectIndex] = downloadModel
                    }
                    
                    self.delegate?.downloadRequestDidUpdateProgress(downloadModel, index: index)
                })
                break
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        for (index, downloadModel) in downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                
                var fileName = downloadModel.fileName ?? "unknown_name"
                let basePath = downloadModel.destinationPath == "" ? MZUtility.baseFilePath : downloadModel.destinationPath
                
                let fileManager : FileManager = FileManager.default
                
                
                let httpResponse = downloadTask.response as? HTTPURLResponse
                if let statusCode = httpResponse?.statusCode {
                    if statusCode < 200 || statusCode > 299 {
                        //Download failed for some reason
                        
                        /**
                         Returning error is done in `urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)`
                         */
                        
                        //Clean downloaded file
                        try? fileManager.removeItem(at: location)
                        
                        return
                    }
                }
                
                
                
                //If all set just move downloaded file to the destination
                if fileManager.fileExists(atPath: basePath) {
                    
                    //Get file extension
                    if let mimeType = downloadTask.response?.mimeType,
                        let fileExtension = MZUtility.fileExtension(from: mimeType)
                    {
                        /**
                         I'm not adding file extension by default here
                         Because I'm allowing only mp4 and srt
                         */
                        //fileName += ".\(fileExtension)"
                        
                        let destinationPath = (basePath as NSString).appendingPathComponent(fileName)
                        let fileURL = URL(fileURLWithPath: destinationPath as String)
                        debugPrint("directory path = \(destinationPath)")
                        
                        do {
                            
                            //Delete if exist
                            if fileManager.fileExists(atPath: fileURL.path) {
                                try fileManager.removeItem(at: fileURL)
                            }
                            
                            try fileManager.moveItem(at: location, to: fileURL)
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.delegate?.downloadRequestFinishedFiledMoved?(
                                    to: fileURL as NSURL,
                                    downloadModel,
                                    index: index,
                                    fileName: fileName,
                                    fileExtension: fileExtension)
                                //self.delegate?.downloadRequestFinished?(downloadModel, index: index)
                            })
                        } catch let error as NSError {
                            /*
                             🔻🔻VERY VERY IMPORTANT🔻🔻
                             
                             IF THE DOWNLOAD HAS BEEN INTIRRUPTED MANY TIMES, ESPICIALLY WITH FORCE APP STOP WHILE RUNNING IN DEBUG MODE OR WHEN APP CRASHES MANY TIMES WHILE DOWNLOADING A FILE.
                             THEN THIS FUNCTION WILL BE CALLED WITH A WRONG `location` LIKE:
                             
                             file:///Users/Brilliant/Library/Developer/CoreSimulator/Devices/9D65EC24-61F5-4C4B-B051-1EB46F2B6B3E/data/Containers/Data/Application/43BB5763-A143-43A2-8404-705BB5F0B993/Library/Caches/com.apple.nsurlsessiond/Downloads/com.YourCompany.App/com.YourCompany.App
                             
                             THE REAL PATH SHOULD BE LIKE THIS:
                             
                             file:///Users/Brilliant/Library/Developer/CoreSimulator/Devices/9D65EC24-61F5-4C4B-B051-1EB46F2B6B3E/data/Containers/Data/Application/43BB5763-A143-43A2-8404-705BB5F0B993/Library/Caches/com.apple.nsurlsessiond/Downloads/com.YourCompany.App/CFNetworkDownload_aTtBXP.tmp
                             
                             🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺
                             */
                            
                            let log = """
                            Error while moving downloaded file to destination path:\(error)
                            from location \(location.absoluteString)
                            to location \(fileURL)
"""
                            debugPrint(log)
                            
                            let error = NSError(
                                domain: "com.appchief.supercell",
                                code: 404,
                                userInfo: [
                              "title":"Custom data was not set but match is exist",
                              "description":log
                            ])
                            Crashlytics.crashlytics().record(error: error)
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            })
                        }
                    } else {
                        let error = NSError(domain: "UnknownFileExtension", code: 403, userInfo: [NSLocalizedDescriptionKey : "Could not determine file type"])
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                        })
                    }
                } else {
                    //Opportunity to handle the folder doesnot exists error appropriately.
                    //Move downloaded file to destination
                    //Delegate will be called on the session queue
                    //Otherwise blindly give error Destination folder does not exists
                    
                    if let _ = self.delegate?.downloadRequestDestinationDoestNotExists {
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.delegate?.downloadRequestDestinationDoestNotExists?(downloadModel, index: index, location: location)
                        })
                    } else {
                        let error = NSError(domain: "FolderDoesNotExist", code: 404, userInfo: [NSLocalizedDescriptionKey : "Destination folder does not exists"])
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                        })
                    }
                }
                
                break
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("task id: \(task.taskIdentifier)")
        /***** Any interrupted tasks due to any reason will be populated in failed state after init *****/
        
        DispatchQueue.main.async {
            
            let err = error as NSError?
            
            if (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonUserForceQuitApplication || (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
                
                let downloadTask = task as! URLSessionDownloadTask
                let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
                let fileName = taskDescComponents[self.TaskDescFileNameIndex]
                let fileURL = taskDescComponents[self.TaskDescFileURLIndex]
                let destinationPath = taskDescComponents[self.TaskDescFileDestinationIndex]
                
                let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath, customData: nil)
                /**
                 
                    A VERY IMPORTANT NOTE HERE
                 IF USER PAUSED A DOWNLOAD TASK THEN TERMINATED THE APP, TASK WILL BE POPULATED AS COMPLETED WITH FAILED STATUS!
                 SO YOU HAVE TO CHECK THE DATABASE STATUS TO ENSURE THE STATUS IS TRUE
                 
                 */
                downloadModel.status = TaskStatus.failed.description()
                downloadModel.task = downloadTask
                
                let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                
                var newTask = downloadTask
                if self.isValidResumeData(resumeData) == true {
                    newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                } else {
                    newTask = self.sessionManager.downloadTask(with: URL(string: fileURL as String)!)
                }
                
                newTask.taskDescription = downloadTask.taskDescription
                downloadModel.task = newTask
                
                self.downloadingArray.append(downloadModel)
                
                self.delegate?.downloadRequestDidPopulatedInterruptedTasks(self.downloadingArray)
                
            } else {
                for(index, object) in self.downloadingArray.enumerated() {
                    let downloadModel = object
                    if task.isEqual(downloadModel.task) {
                        
                        let httpResponse = task.response as? HTTPURLResponse
                        if let statusCode = httpResponse?.statusCode, statusCode < 200 || statusCode > 299 {
                            
                            //Download failed for some reason
                            self.downloadingArray.remove(at: index)
                            
                            let error = NSError(domain: "DownloadFailed", code: statusCode, userInfo: [
                                NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: statusCode)
                            ])
                            DispatchQueue.main.async {
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            }
                        }
                        else
                        if err?.code == NSURLErrorCancelled || err == nil {
                            self.downloadingArray.remove(at: index)
                            
                            if err == nil {
                                self.delegate?.downloadRequestFinished?(downloadModel, index: index)
                            } else {
                                self.delegate?.downloadRequestCanceled?(downloadModel, index: index)
                            }
                            
                        } else {
                            let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                            var newTask = task
                            if self.isValidResumeData(resumeData) == true {
                                newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                            } else {
                                newTask = self.sessionManager.downloadTask(with: URL(string: downloadModel.fileURL)!)
                            }
                            
                            newTask.taskDescription = task.taskDescription
                            downloadModel.status = TaskStatus.failed.description()
                            downloadModel.task = newTask as? URLSessionDownloadTask
                            
                            self.downloadingArray[index] = downloadModel
                            
                            if let error = err {
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            } else {
                                let error: NSError = NSError(domain: "MZDownloadManagerDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred"])
                                
                                self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                backgroundCompletion()
            })
        }
        debugPrint("All tasks are finished")
    }
}

//MARK: Public Helper Functions

extension MZDownloadManager {
    
    @objc public func addDownloadTask(_ fileName: String, request: URLRequest, destinationPath: String, customData:Any?) {
        
        let url = request.url!
        let fileURL = url.absoluteString
        
        let downloadTask = sessionManager.downloadTask(with: request)
        downloadTask.taskDescription = [fileName, fileURL, destinationPath].joined(separator: ",")
        downloadTask.resume()
        
        debugPrint("session manager:\(String(describing: sessionManager)) url:\(String(describing: url)) request:\(String(describing: request))")
        
        let downloadModel = MZDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath, customData: customData)
        downloadModel.status = TaskStatus.downloading.description()
        downloadModel.task = downloadTask
        
        downloadingArray.append(downloadModel)
        delegate?.downloadRequestStarted?(downloadModel, index: downloadingArray.count - 1)
    }
    
    @objc public func addDownloadTask(_ fileName: String, fileURL: String, destinationPath: String, customData:Any?) {
        
        let url = URL(string: fileURL)!
        let request = URLRequest(url: url)
        addDownloadTask(fileName, request: request, destinationPath: destinationPath, customData:nil)
        
    }
    
    @objc public func addDownloadTask(_ fileName: String, fileURL: String) {
        addDownloadTask(fileName, fileURL: fileURL, destinationPath: "", customData: nil)
    }
    
    @objc public func addDownloadTask(_ fileName: String, request: URLRequest) {
        addDownloadTask(fileName, request: request, destinationPath: "", customData: nil)
    }
    
    @objc public func pauseDownloadTaskAtIndex(_ index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.paused.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.suspend()
        downloadModel.status = TaskStatus.paused.description()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidPaused?(downloadModel, index: index)
    }
    
    @objc public func resumeDownloadTaskAtIndex(_ index: Int) {
        
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        downloadTask!.resume()
        downloadModel.status = TaskStatus.downloading.description()
        
        downloadingArray[index] = downloadModel
        
        delegate?.downloadRequestDidResumed?(downloadModel, index: index)
    }
    
    @objc public func retryDownloadTaskAtIndex(_ index: Int) {
        let downloadModel = downloadingArray[index]
        
        guard downloadModel.status != TaskStatus.downloading.description() else {
            return
        }
        
        let downloadTask = downloadModel.task
        
        downloadTask!.resume()
        downloadModel.status = TaskStatus.downloading.description()
        downloadModel.task = downloadTask
        
        downloadingArray[index] = downloadModel
    }
    
    @objc public func cancelTaskAtIndex(_ index: Int) {
        let downloadInfo = downloadingArray[index]
        let downloadTask = downloadInfo.task
        downloadTask!.cancel()
    }
    
    @objc public func presentNotificationForDownload(_ notifAction: String, notifBody: String) {
        let application = UIApplication.shared
        let applicationState = application.applicationState
        
        if applicationState == UIApplication.State.background {
            let localNotification = UILocalNotification()
            localNotification.alertBody = notifBody
            localNotification.alertAction = notifAction
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.applicationIconBadgeNumber += 1
            application.presentLocalNotificationNow(localNotification)
        }
    }
}
