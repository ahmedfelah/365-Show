//
//  MoreVC.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/22/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import RealmSwift
import SafariServices

extension ShoofAPI.User : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(email)
    }
    
    static func == (lhs: ShoofAPI.User, rhs: ShoofAPI.User) -> Bool {
        lhs.id == rhs.id
    }
}

var fakeDeletedAccounts : Set<ShoofAPI.User> {
    get {
        (try? UserDefaults.standard.decodable(forKey: "fakeDeletedAccounts")) ?? []
    } set {
        UserDefaults.standard.setEncodable(newValue, forKey: "fakeDeletedAccounts")
    }
}

class MoreVC: MasterTVC {
    
    // MARK: - LINKS
    @IBOutlet weak var logoutButton : MainButton!
    @IBOutlet weak var userNameLabel : UILabel!
    @IBOutlet weak var userEmailLabel : UILabel!
    @IBOutlet weak var profileNameView  : ProfileNameView!
    
    @IBOutlet weak var registerCell : UITableViewCell!
    @IBOutlet weak var userProfileCell : UITableViewCell!
    @IBOutlet weak var historyCell : UITableViewCell!
    @IBOutlet weak var favoriteCell: UITableViewCell!
    @IBOutlet weak var requestCell : UITableViewCell!
    @IBOutlet weak var notificationCell : UITableViewCell!
    @IBOutlet weak var downloadCell : UITableViewCell!
    @IBOutlet weak var changeLanguageCell : UITableViewCell!
    @IBOutlet weak var facebookCell : UITableViewCell!
    @IBOutlet weak var facebookGroupCell : UITableViewCell!
    @IBOutlet weak var developersCell : UITableViewCell!
    @IBOutlet weak var aboutUsCell : UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!

    @IBOutlet weak var versionLabel : UILabel!
    
    @IBOutlet weak var downloadIndicator : CirclerView!
    @IBOutlet weak var downloadLabel : UILabel!
    @IBOutlet weak var downloadIcon : UIImageView!
    @IBOutlet weak var familyModCell: UITableViewCell!
    
    @IBOutlet weak var familyModSwitch: UISwitch!
    @IBOutlet weak var familyModeTitleLabel: UILabel!
    @IBOutlet weak var deleteAccountCell: UITableViewCell!
    @IBOutlet weak var deleteAccountCellLabel: UILabel!
    

//    // MARK: - VARS
//    private var isActiveUser = false {
//        didSet {
//            tableView.reloadData()
//        }
//    }

    var rmDownloading:Results<RDownload>?
    var token:NotificationToken?
//    private lazy var networkManager : NetworkManager = {
//        let m = NetworkManager()
//        m.networkVD = self
//        return m
//    }()
    
    
    // MARK: - LOAD
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setStatusBar(backgroundColor: Theme.current.backgroundColor)
        tableView.reloadData()
        setupViews()
        
        dump(Account.shared.token)
        dump(Account.shared.info)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyModeTitleLabel.text = NSLocalizedString("familyMode", comment: "")
        deleteAccountCellLabel.text = NSLocalizedString("deleteAccount", comment: "")
        
        if let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            versionLabel.text = NSLocalizedString("version", comment: "")  + " :" + "\(versionString)"
        }
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        
        NotificationCenter.default.addObserver(forName: .userDidChange, object: nil, queue: .main) { [weak self] n in
            if let user = n.object as? ShoofAPI.User {
                print(user)
            }
            self?.tableView.reloadData()
        }
        
        familyModSwitch.isOn = ShoofAPI.Settings.shared.isFamilyModOn
        familyModSwitch.addTarget(self, action: #selector(handleFamilyModSwitch), for: .valueChanged)
        
//        NotificationCenter.default.addObserver(forName: .familyModDidChange, object: nil, queue: .main) { [weak self] _ in
//            self?.familyModSwitch.isOn = Sett
//        }
        
//        NotificationCenter.default.addObserver(
//            forName: NSNotification.Name(rawValue: gnNotification.didChangeLoginState),
//            object: nil, queue: nil) { [weak self] (_) in
//            
//            self?.tableView.reloadData()
//            
//        }
//        
        
        if !isOutsideDomain {
            //Continue downloads and verify db objects
            DownloadManager.shared.continueAvailableDownloads()
            
            observeDownloadChanges()
        }
        
    }
    
    @objc func handleFamilyModSwitch(sender: UISwitch) {
        ShoofAPI.Settings.shared.isFamilyModOn = sender.isOn
    }
    
    // MARK: - PRIVATE
    override func setupViews() {
        super.setupViews()
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.showsHorizontalScrollIndicator = false
        if let account = ShoofAPI.User.current {
            self.userNameLabel.text = account.name?.capitalized
            self.userEmailLabel.text = account.email
            
            if let image = account.image {
                profileNameView.setImage(from: image)
            } else if let name = account.name {
                self.profileNameView.setFirstLetter(withName: name)
            }
        }
    }
    
    func openFacebook () {
        let appURL = URL(string:"fb://profile/100345048168515")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            //openWebView(url: Routes.faceBookPageUrl)
        }
        
    }
    
    func openFacebookGroup () {
        let appURL = URL(string:"fb://profile/498626110769410")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        } else {
            //openWebView(url: Routes.faceBookGroupUrl)
        }
        
    }
    
    private func openWebView(url: String) {
        guard let link = URL.init(string: url) else { return }
        let vc = SFSafariViewController.init(url: link)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func observeDownloadChanges () {
        rmDownloading = realm
            .objects(RDownload.self)
            .filter("status = %i or status = %i or status = %i and isSeriesHeader = false",
                    DownloadStatus.downloading.rawValue,
                    DownloadStatus.downloading_sub.rawValue,
                    DownloadStatus.failed.rawValue)
        
        token = rmDownloading?.observe { [weak self](changes) in
            switch changes {
            case .initial(let objects):
                self?.setDownloadState(from:objects)
                break
            case .update(let objects, _, _,_):
                self?.setDownloadState(from:objects)
                break
            default:
                break
            }
        }
    }
    
    
    private func setDownloadState (from data:Results<RDownload>) {
        var failedCount:Int = 0
        var inProgressCount:Int = 0
        data.forEach({
            let status = $0.statusEnum
            if status == .failed {
                failedCount += 1
            } else {
                inProgressCount += 1
            }
        })
        var color : UIColor?
        var labelValue : String?
        var stateImage : UIImage?
        downloadIndicator.isHidden = false
        downloadLabel.isHidden = false
        downloadIcon.isHidden = false
        if inProgressCount > 0 {
            color = Theme.current.tintColor
            labelValue = "\(inProgressCount)"
            stateImage = UIImage(named: "Download") ?? UIImage()
        } else if failedCount > 0 {
            color = .orange
            labelValue = "\(failedCount)"
            stateImage = UIImage(named: "ErrorTriangle") ?? UIImage()
        } else {
            downloadLabel.isHidden = true
            downloadIcon.isHidden = true
            downloadIndicator.isHidden = true
        }
        
        downloadLabel.text = labelValue
        downloadLabel.textColor = color
        downloadIcon.tintColor = color ?? .darkGray
        downloadIcon.image = stateImage
    }

    // MARK: - TABLE
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch cell {
        case registerCell           : return ShoofAPI.User.current == nil ? tableView.estimatedRowHeight : 0
        case familyModCell          : return 0
        case userProfileCell        : return ShoofAPI.User.current == nil ? 0 : tableView.estimatedRowHeight
        case requestCell            : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case historyCell            : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case notificationCell       : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case downloadCell           : return appPublished                ?  tableView.estimatedRowHeight : 0
        case favoriteCell           : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case changeLanguageCell     : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case facebookCell           : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case facebookGroupCell      : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case developersCell         : return 0
        case aboutUsCell            : return ShoofAPI.shared.isInNetwork ?  tableView.estimatedRowHeight : 0
        case deleteAccountCell      : return !appPublished && isOutsideDomain && ShoofAPI.User.current != nil ? tableView.estimatedRowHeight : 0
        case logoutCell             : return ShoofAPI.User.current != nil ? tableView.estimatedRowHeight : 0
        default                     : return tableView.estimatedRowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case registerCell:
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        case userProfileCell:
            let updateProfile = UpdateProfileViewController()
            navigationController?.pushViewController(updateProfile, animated: true)
        case facebookCell:
            openFacebook()
        case facebookGroupCell:
            openFacebookGroup()
        case aboutUsCell:
            openWebView(url: Routes.cinemaWebsite)
        case developersCell:
            print("open about us")
        case deleteAccountCell:
            let alert = UIAlertController(title: NSLocalizedString("deleteAccount", comment: "").capitalized, message: NSLocalizedString("deleteAccountMessage", comment: ""), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("deleteAlertButton", comment: ""), style: .destructive) { _ in
                if let currentUser = ShoofAPI.User.current {
                    fakeDeletedAccounts.insert(currentUser)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    ShoofAPI.shared.signOut()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancelAlertButton", comment: ""), style: .cancel)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        default: break
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - ACTIONS
    @IBAction func logoutTapped() {
        tabBar?.alert.logoutAlert {
//            self?.view.isUserInteractionEnabled = false
//            self?.networkManager.logout()
//            self?.logoutButton.showActivityIndicator()
            ShoofAPI.shared.signOut()
//            self?.tableView.reloadData() 
        }
        
    }
}

// MARK: - SFSafariViewControllerDelegate
extension MoreVC: SFSafariViewControllerDelegate{
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - NETWORK
extension MoreVC {
    
    func requestEnded() {
        logoutButton.hideActivityIndicator()
        view.isUserInteractionEnabled = true
    }
    
    func failure() {
        tabBar?.alert.noContent()
    }
    
    func failureMessage(data: String) {
        tabBar?.alert.backendAPIError(message: data)
    }
    
    func success() {
        print("LOGOUT SUCCESS")
//        isActiveUser = ShoofAPI.User.current == nil ? false : true
//        isActiveUser = Account.shared.token == nil ? false : true
    }

}





fileprivate extension String {
    
    static let downloadLabelDownloading = NSLocalizedString("downloadLabelDownload", comment: "")
    static let downloadLabelIssue = NSLocalizedString("downloadLabelIssue", comment: "")
}

