//
//  TabViewController.swift
//  Giganet
//
//  Created by Husam Aamer on 4/27/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

extension RoundedTabBar {
    @objc func handle (notification:Notification) {
        
        print("x-notification", notification)
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else {
            return
        }
        
        if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
           print("JSONString", JSONString)
        }
        
        print("xx-data", data)
        
        let decoder = JSONDecoder()
        
        guard let notification = try? decoder.decode(ShoofAPI.Notification.self, from: data) else {
            return
        }
        
        print("xxx-notification", notification)
        
        openNotification(notification, withAlert: true)
//        performNotifiactionTarget(notification.title ?? "", notification.body.html2String, notification.type, notification.targetID ?? "", shouldAlertBeforePush: true)
        
        /*
        guard
            let userInfo = notification.userInfo,
            let aps = userInfo["aps"] as? [String:Any?],
            let target = userInfo["target"] as? String,
            let targetData = target.data(using: .utf8)
            else {
                return
        }
        
        guard
            let targetJson = try? JSON(data: targetData),
            let target_type = targetJson["type"].string,
            let target_id = targetJson["id"].string
        else {
                return
        }
        
        ////////////////// Alert title and body //////////////////////
        let alertDic = aps["alert"] as? [String:Any?]
        let title = alertDic?["title"] as? String ?? "New notification"
        let body = alertDic?["body"] as? String ?? "No content"
         l
        */
//        performNotifiactionTarget(title, body.html2String,target_type,target_id, shouldAlertBeforePush: true)
    }
    
    struct AlertData {
        let title: String?
        let message: String
    }
    
    func openNotification(_ notification: ShoofAPI.Notification, withAlert: Bool = false) {
        switch notification.type {
        case .show:
            guard let showID = notification.targetID else {
                return
            }
            
            let alert: AlertData? = withAlert ? AlertData(title: notification.aps?.alert?.title, message: notification.aps?.alert?.body ?? "") : nil

            openShow(withID: showID, alert: alert)
        default: break // No other notification types yet
        }
    }
    
    func openShow(withID showID: String, alert: AlertData? = nil) {
        ShoofAPI.shared.loadDetails(forShowWithID: showID) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let response = try result.get()
                    let show = response.body

                    guard let detailsVC = self?.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as? DetailsVC else {
                        return
                    }

                    detailsVC.show = show

                    if let alert = alert {
                        self?.showNotificationAlert(with: alert.title ?? "", and: alert.message) {
                            self?.push(viewController: detailsVC)
                        }
                    } else {
                        self?.push(viewController: detailsVC)
                    }
                } catch {
                    self?.showError(error: error)
                }
            }
        }
    }
   
    func performNotifiactionTarget (_ title:String,_ body:String,_ target_type:String,_ target_id:String, shouldAlertBeforePush:Bool,loadingCompleted:((Error?)->())? = nil) {
        ////////////////// Alert view Action //////////////////////
		switch target_type.lowercased() {
        case "movie", "show":
            openMovieDetails(with: title,
                             body: body,
                             and: target_id,
                             shouldAlertBeforePush: shouldAlertBeforePush,
                             loadingCompleted:loadingCompleted)
            break
        case "request":
            openRequestDetails(with: title,
                               body: body,
                               and:target_id,
                               shouldAlertBeforePush: shouldAlertBeforePush,
                               loadingCompleted:loadingCompleted)
            break
        case "channel":
            openChannel(with: title,
                        body: body,
                        and: target_id,
                        shouldAlertBeforePush: shouldAlertBeforePush,
                        loadingCompleted:loadingCompleted)
            break
        default:
            showNotificationAlert(with: title,
                                  and: body,
                                  viewAction: nil)
            break
        }
    }
    
    @objc func handleLink (notification:Notification) {
        guard let url = notification.object as? URL else {return}
        
        // Fragment is the value of hash
        // ex: cinema.shoof.com/page?query=value#fragment
        guard let movieToken = url.fragment else {return}
        
        openMovieDetails(with: "",
                         body: "",
                         and: movieToken,
                         shouldAlertBeforePush: false,
                         loadingCompleted:nil)
        return
    }
    
    func push(viewController:UIViewController) {
        if let nav = viewControllers?[selectedIndex] as? UINavigationController {
            if let presented = nav.presentedViewController {
                presented.dismiss(animated: true, completion: {
                    nav.pushViewController(viewController, animated: true)
                })
            } else {
                nav.pushViewController(viewController, animated: true)
            }
        }
    }
    func showError(error:Error) {
        if let nav = viewControllers?[selectedIndex] as? UINavigationController {
            nav.presentedViewController?.dismiss(animated: true, completion: {
                let title = NSLocalizedString("genericErrorTitle", comment: "")
                let body = error.localizedDescription
                Alert(on: self).showCancelableAlert(title, body, nil)
            })
        }
    }
}




extension RoundedTabBar {
    func openMovieDetails (with title:String, body:String,and token:String, shouldAlertBeforePush:Bool = false,loadingCompleted:((Error?)->())? = nil) {
		
        ShoofAPI.shared.loadDetails(forShowWithID: token) { [weak self] result in
            DispatchQueue.main.async { [self] in
                guard let self = self else { return }
                
                do {
                    
                    let response = try result.get()
                    let show = response.body
                    if let detailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as? DetailsVC {
                        detailsVC.show = show
                        if shouldAlertBeforePush {
                            self.showNotificationAlert(with: title, and: body, viewAction: {
                                self.push(viewController: detailsVC)
                            })
                        } else {
                            self.push(viewController: detailsVC)
                        }
                    }
                    
                    loadingCompleted?(nil)
                } catch {
                    self.showError(error: error)
                    loadingCompleted?(error)
                }
            }
        }
    }
    
    func openRequestDetails (with title:String, body:String,and request_id:String, shouldAlertBeforePush:Bool = false,loadingCompleted:((Error?)->())? = nil) {
        RRequests.getSingleRequest(with: request_id) { [weak self](json, error) in
            guard let `self` = self else {return}
            
            loadingCompleted?(error)
            
            if let error = error {
                self.showError(error: error)
            } else
            if let json = json,
                let showRequestVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowRequestVC") as? ShowRequestVC {
                showRequestVC.data = json
                
                if shouldAlertBeforePush {
                    self.showNotificationAlert(with: title, and: body, viewAction: {
                        self.push(viewController: showRequestVC)
                    })
                } else {
                    self.push(viewController: showRequestVC)
                }
            }
        }
        
    }
    func openChannel (with title:String, body:String,and channel_id:String, shouldAlertBeforePush:Bool = false,loadingCompleted:((Error?)->())? = nil) {
//        RRequests.getChannels {[weak self] (json, error) in
//            guard let `self` = self else {return}
//            guard let channelsJson = json else {return}
//
//            loadingCompleted?(error)
//
//            let sections = channelsJson["sections"].arrayValue
//                .map({ChannelSection.init(from: $0)})
//                .compactMap({$0})
//
//            var channel:Channel?
//            var section:ChannelSection?
//            for s in sections {
//                for c in s.channels {
//                    if c.name == channel_id {
//                        channel = c
//                        section = s
//                    }
//                }
//            }
//
//            if let section = section, let channel = channel {
//                let detailsView = ChannelsCollectionView(with:.zero,
//                                                         list: [ChannelsCollectionView.Section(title: section.name, channels: section.channels)],
//                                                         selectedChannelName: channel.name)
//                detailsView.tag = 1
//                //detailsView.listDelegate = self
//                self.play(channel: channel, with: detailsView)
//            }
//        }
    }
    
    func showNotificationAlert (with title:String, and body:String, viewAction:(()->())?) {
        var actions = [UIAlertAction]()
        
        if let viewAction = viewAction
        {
            let viewAction = UIAlertAction(title: Localize("notificationShowButton"), style: .default) { (_) in
                viewAction()
            }
            actions.append(viewAction)
        }
        
        Alert(on: self).showCancelableAlert(title, body, actions)
    }
}
