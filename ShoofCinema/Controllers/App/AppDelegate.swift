//
//  AppDelegate.swift
//  SuperCell
//
//  Created by Husam Aamer on 3/30/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseCore
import FirebaseRemoteConfig
import IQKeyboardManagerSwift
import FirebaseMessaging
import SnapKit
import Kingfisher
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //Used for presenting UIAlertController globally and above all
    var win:UIWindow?
    
    var window: UIWindow?
    var objectsToBeHandled:[String:Notification]?
    
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return AppDelegate.orientationLock
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        askForNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
       
        
        // Change default cache limit
        ImageCache.default.memoryStorage.config.expiration = .days(60)
        ImageCache.default.memoryStorage.config.totalCostLimit = 1024 * 1024 * 1024
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        Realm.Configuration.defaultConfiguration =  Realm.Configuration(schemaVersion: 42) { migration, oldVersion in
            
            if oldVersion < 41 {
                migration.deleteData(forType: "RContinueShow")
            }
		}
		
		do {
			try RealmManager.migrateRmDownloadsToRDownloads()
		} catch {
			print(error)
		}
		
        //updateFirebaseRemoteConfigs()
		
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.disabledTouchResignedClasses = [SearchVC.self,WriteCommentVC.self, SubmitRequestVC.self]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [SearchVC.self,WriteCommentVC.self, SubmitRequestVC.self]
        IQKeyboardManager.shared.disabledToolbarClasses = [SearchVC.self,WriteCommentVC.self, SubmitRequestVC.self]
        
        //Firebase
//        Analytics.setUserID(UIDevice.current.identifierForVendor?.uuidString)
//        if application.canOpenURL(URL(string: "pin://")!) {
//            FIRSet(userProperty: "1", name: .hasApp_pinco)
//        }
        
        
        setupUI()
        
		Messaging.messaging().subscribe(toTopic: "all") { error in
          print("Subscribed to 'all' topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "ios-dev") { error in
          print("Subscribed to 'ios-dev' topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "ios-dev-test") { error in
          print("Subscribed to 'ios-dev-test' topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "cinema_all") { error in
          print("Subscribed to topic: cinema_all")
        }
        
        ShoofAPI.shared.addTopic("cinema_all") { result in
            do {
                let response = try result.get()
                if response.body {
                    print("Subscribed to topic: cinema_all")
                }
            } catch {
                print("Failed to add topic with error: \(error.localizedDescription)")
            }
        }
        
        #if DEBUG
        if let user = ShoofAPI.User.current {
            print("LOGGED IN USER: ", user)
        }
        #endif
    
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
        
        completionHandler()
    }
    
    fileprivate func updateFirebaseRemoteConfigs() {
        //Update remote config
        RemoteConfig.remoteConfig().fetch { (status, error) in
            
            /*
             XXXXXX 1\ Code before `activateFetched()` XXXXXX
             */
            
            /* XXXXXX 2\ Activating fetched data XXXXXX */
            RemoteConfig.remoteConfig().activate { (success, error) in
                
            }
            
            
            /*XXXXXX  3\ Code after `activateFetched()` XXXXXX*/
            
            //Check appstore build
            let appstore_build = FIRParams.value(key: .appstore_build).numberValue
            
            

            
            if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
               let buildInt = Int(buildNumber),
                appstore_build.intValue > buildInt
            {
                let toStore = UIAlertAction(title: "Update now", style: .default, handler: { (_) in
                    openAppStore(appID: "")
                })
                let last_update_features = FIRParams.value(key: .last_update_features).stringValue ?? ""
                let a = alert(title: "UpdateAvailable", body: last_update_features, cancel: "Later", actions: [toStore], style: .alert)
                delay(5, closure: {
                    if let root = self.window?.rootViewController {
                        root.present(a, animated: true, completion: nil)
                    }
                })
            }
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    var userPropertiesSent = false
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //AppEventsLogger.activate(application)
        //FBSDKAppEvents.setUserID(UIDevice.current.identifierForVendor!.uuidString)
        
        //Set user properties
        if !userPropertiesSent {
            userPropertiesSent = true
            
            if UIAccessibility.isVoiceOverRunning {
                FIRSet(userProperty: "1", name: .isVoiceOver)
            } else {
                FIRSet(userProperty: "0", name: .isVoiceOver)
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if !isOutsideDomain {
            DownloadManager.shared.applicationWillTerminate()
        }
    }
	
    private func setupUI () {
        
        // hiding the back button title for all navigation items
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        BarButtonItemAppearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        BarButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -200, vertical: 0), for:UIBarMetrics.default)
        
        //Style for UIAlertController
        //UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self,UIPopoverBackgroundView.self,UIPopoverPresentationController.self]).tintColor = .blue
        if #available(iOS 13.0, *) {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self,UIPopoverBackgroundView.self, UIPopoverPresentationController.self]).overrideUserInterfaceStyle = .dark
        }
        
        
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        
        
        // Add this code in your AppDelegate didFinishLauncingWithOptions
        // or you can change configuration of certain subclass using self. backgroundConfiguration = ...
        if #available(iOS 14.0, *) {
            var bgConfig = UIBackgroundConfiguration.listPlainCell()
            bgConfig.backgroundColor = UIColor.clear
            UITableViewHeaderFooterView.appearance().backgroundConfiguration = bgConfig
            //For cell use: UITableViewCell.appearance().backgroundConfiguration = bgConfig
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print(url.absoluteString)
            let _ = self.application(application, open: url, options: [:])
        }
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //print(url)
        //print(url.query)
        //print(url.fragment)
        //print(options)
        
        let notif = Notification(name: Notification.Name(rawValue: gnNotification.didOpenFromLink),
                                 object: url, userInfo: nil)
        
        //If app was in background it will open directly
        NotificationCenter.default.post(notif)
        
        //If app launched from notification then add object to queue
        if objectsToBeHandled == nil {
            objectsToBeHandled = [:]
        }
        objectsToBeHandled?[gnNotification.didOpenFromLink] = notif
        
        return GIDSignIn.sharedInstance.handle(url)
        
//        return true
    }
}
