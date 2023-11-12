
//
//  DownloadsVC.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/6/20.
//  Copyright © 2020 AppChief. All rights reserved.
//
import UIKit
import RealmSwift
import FirebaseCrashlytics

fileprivate var _formatter : NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    formatter.numberStyle = .decimal
    formatter.locale = Locale.init(identifier: "en")
    return formatter
}()

class DownloadsVC: MasterTVC {
    
    
    // MARK: - VARS
    var data : Results<RDownload>! {
        didSet {
            if data.isEmpty {
                view.showNoContentView(with: .noDownloadsTitle, .noDownloadsBody, and: UIImage(named: .noDownloadsIconName)!, actionButtonTitle: nil)
            } else {
                view.hideNoContentView()
            }
        }
    }
    var observer : NotificationToken?
    var mzManger : MZDownloadManager? {get {return isOutsideDomain ? nil : DownloadManager.shared.manager}}
    static var formatter:NumberFormatter {
        get {
            return _formatter
        }
    }
    var isDeletingPath:(IndexPath:IndexPath,CountBeforeDelete:Int)?
    
    // MARK: - LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
    
        data = realm.objects(RDownload.self)
            .sorted(by: ["order"])
        
        if isOutsideDomain {
            data = data.filter("status = \(DownloadStatus.downloaded.rawValue)")
        } else {
            observeChanges(in: data)
            DownloadManager.shared.observeAllDownloads(observer: self)
        }
        
        updateNoContent()
        
        FIRSet(userProperty: "\(data.count)", name: .numberOfDownloads)
    }
    
    /// Get live model from download manager
    /// - Parameter indexPath: Index path of cell
    func liveModel(forCellAt indexPath:IndexPath) -> MZDownloadModel? {
        let rmFilename = data[indexPath.row].video_filename
        return mzManger?.downloadingArray.first(where: {$0.fileName == rmFilename})
    }
    
    /// Get Download Task index from clicked RmDownloadShow
    /// - Parameter rmItem
    func taskIndex(for rmItem:RDownload) -> Int? {
        if let taskIndex = DownloadManager.shared.manager.downloadingArray.firstIndex(where: {
            if let linkedRm = $0.customData as? RDownload {
                return linkedRm == rmItem
            }
            else if $0.fileName == rmItem.video_filename || $0.fileName == rmItem.subtitle_filename {
                
                //Set custom data and return true
                $0.customData = rmItem
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
                
                self.tableView.reloadData()
                self.updateNoContent()
                
                afterDeleteBlock?()
            })
        } else {
            DownloadManager.shared.cancelTaskAndDelete(rmItem, beforeDeleteBlock: nil, afterDeleteBlock: nil)
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
    
    func updateNoContent () {
        if data.isEmpty {
            view.showNoContentView(with: .noDownloadsTitle, .noDownloadsBody, and: UIImage(named: .noDownloadsIconName)!, actionButtonTitle: nil)
        } else {
            view.hideNoContentView()
        }
    }
    
    func observeChanges (in data:Results<RDownload>) {
        
        observer = data.observe({ [weak self] (changes) in
            guard let `self` = self else {return}
            
            switch changes {
            case .update( _, let deletes,let inserts, _):
                //print(deletes,inserts,modifications)
                
                /// REALM BUG HAPPENS WHEN DELETING, INSERTS AND MANY DELETES GET RECEIVED!
                if deletes.count > 0 , inserts.count > 0 {
                    return
                }
                if inserts.count > 0 {
                    let insertPaths = inserts.compactMap({IndexPath(row: $0, section: 0)})
                    if #available(iOS 11.0, *) {
                        self.tableView.performBatchUpdates({
                            self.tableView.insertRows(at: insertPaths, with: .right)
                        }, completion: { _ in
                            self.updateNoContent()
                        })
                    } else {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: insertPaths, with: .right)
                        self.tableView.endUpdates()
                        self.updateNoContent()
                    }
                    return
                }
                
                break
            default:
                break
            }
        })
    }
    
    deinit {
        observer = nil
    }
}

// MARK: - DOWNLOAD DELEGATE
extension DownloadsVC: DownloadManagerDelegate {
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        
        if item.isInvalidated {return}
        
        guard let itemRow = data.index(of: item) else {
            return
        }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: itemRow, section: 0)) as? DownloadsCell else {
            return
        }
        
        updateProgress(for: cell,with: item, from: downloadModel)
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int, for item: RDownload) {
        
    }
    
    func downloadRequestWillDelete(rmDownloadShow item: RDownload) {
        guard let itemRow = data.index(of: item) else {
            return
        }
        isDeletingPath = (IndexPath: IndexPath(row: itemRow, section: 0),
                          CountBeforeDelete:data.count)
    }
    
    func downloadRequestDidDeleteRmDownloadShow(with primaryKey: Any?) {
        if let deletingPath = isDeletingPath {
            
            var toDeletePaths = [deletingPath.IndexPath]
            
            /// We should compare to check if
            let currentCount = data.count
            let deletedCellCount = deletingPath.CountBeforeDelete - currentCount
            if deletedCellCount == 2 {
                //Happens when user delete last episode in series
                //SeriesHeader and last episode should be removed
                toDeletePaths.append(IndexPath(row: deletingPath.IndexPath.row - 1, section: 0))
            } else if deletedCellCount > 2 {
                //Should never happens
                tableView.reloadData()
                return
            }
            
            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: toDeletePaths, with: .fade)
                }, completion: {_ in
                    self.isDeletingPath = nil
                    self.updateNoContent()
                })
            } else {
                tableView.beginUpdates()
                self.tableView.deleteRows(at: toDeletePaths, with: .fade)
                tableView.endUpdates()
                self.isDeletingPath = nil
                self.updateNoContent()
            }
        }
    }
    
    func downloadRequestDidChangedStatus(for item: RDownload, downloadModel: MZDownloadModel, index: Int) {
        if let row = data.index(of: item) {
            let path = IndexPath(row: row, section: 0)
            
            if item.statusEnum == .downloaded {
                tableView.reloadRows(at: [path], with: .fade)
            } else if let cell = self.tableView.cellForRow(at: path) as? DownloadsCell {
                cell.updateUI(from: item)
            }
        } else {
            /**
             # When this case happens?
             - If you use filter on realm query then you may not find item in the array
             easiest approath is to reload table
             */
            tableView.reloadData()
        }
    }
}

extension DownloadsVC {
    func updateProgress (for cell:DownloadsCell,with rmDownloadShow:RDownload,from downloadModel:MZDownloadModel ) {
        
        cell.updateUI(rmDownloadShow.statusEnum,
                      progress: downloadModel.progress,
                      speed: downloadModel.speed?.speed, speedUnit: downloadModel.speed?.unit ?? "KB",
                    fileSize: downloadModel.file?.size, fileSizUnit: downloadModel.file?.unit,
                    downloadedSize: downloadModel.downloadedFile?.size, downloadedUnit: downloadModel.downloadedFile?.unit)
    }
    
}


// MARK: - TALBE
extension DownloadsVC {
    
    // ROWS
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // CELL
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.row]
        let status = item.statusEnum
        
        var identifier = ""
        if item.isSeriesHeader {
            identifier = "SHOW_HADER"
        } else if item.isSeries {
            if status == .downloaded {
                identifier = "EPISODE_LOADED"
            } else {
                identifier = "EPISODE_LOADEING"
            }
        } else {
            identifier = "MOVIE"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DownloadsCell
        cell.actionDelegate = self
        cell.rmDownload = item
        
        /// Update progress according to the latest live value from the manager
        if let model = liveModel(forCellAt: indexPath)
        {
            if let file = model.file , file.size != 0 {
                updateProgress(for: cell, with: item, from: model)
            }
        }
        return cell
    }
    
    // HEIGHT
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = data[indexPath.row]
        let status = item.statusEnum
        if item.isSeriesHeader {
            return 205
        }
        else if item.isSeries {
            if status == .downloaded {
                return 80
            } else {
                return 130
            }
        } else {
            return 205
        }

    }
}


extension DownloadsVC : DownloadsActionDelegate {
    
    func deleteAction(item: RDownload) {
        tabBar?.alert.deleteShowFromDownload { [weak self] in
            self?.delete(item)
        }
    }
    
    func pauseAction(item: RDownload) {
        self.pause(item)
    }
    
    func resumeAction(item: RDownload) {
        self.resume(item)
    }
    
    func playAction(item: RDownload) {
        guard let show = item.asShoofShow() else { return }
        let vc = DetailsSwiftUIViewController()
        vc.show = show
        vc.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }

}

fileprivate extension String {
    static let noDownloadsTitle  = NSLocalizedString("noDownloadsTitle", comment: "")
    static let noDownloadsBody  = NSLocalizedString("noDownloadsMessage", comment: "")
    static let noDownloadsIconName  = "ic-no-downloads"
}
