//
//  Alert.swift
//  Qi Mobile Bank
//
//  Created by Abdulla Jafar on 12/8/19.
//  Copyright © 2019 Enjaz Mac. All rights reserved.
//

import Foundation
import UIKit

class Alert {

    let viewController : UIViewController
    
    let ramadanModeAlertMessage = ShoofAPI.User.ramadanTheme ? "ramadanModeDeactiveBody" : "ramadanModeActiveBody"
    
    init(on vc : UIViewController) {
        self.viewController = vc
    }

    func showCancelableAlert(_ title:String, _ message: String?, _ actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancelAlertButton", comment: ""), style: .cancel, handler: nil))
        //alert.view.tintColor = .blue
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithDone (_ title:String, _ message: String?, _ actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("doneAlertButton", comment: ""), style: .default, handler: nil))
        alert.view.tintColor = Theme.current.tintColor
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(_ title:String, _ message: String?, _ actions: [UIAlertAction]?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alert.addAction(action)
            }
        }
        //alert.view.tintColor = .blue
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    func unableToPlay () {
        let title = NSLocalizedString("unableToPlayShowAlertTitle", comment: "")
        let message = NSLocalizedString("unableToPlayShowAlertBody", comment: "")
        showCancelableAlert(title, message, nil)
    }
    
    func noEpisodes() {
        let title = NSLocalizedString("noEpisodesAlertTitle", comment: "")
        let message = NSLocalizedString("noEpisodesAlertMessage", comment: "")
        showCancelableAlert(title, message, nil)
    }
	
	func noMovieFiles() {
		let title = NSLocalizedString("noEpisodesAlertTitle", comment: "")
		let message = NSLocalizedString("noMovieAlertMessage", comment: "")
		showCancelableAlert(title, message, nil)
	}
	
    func noContent () {
        let title = NSLocalizedString("genericErrorTitle", comment: "")
        let message = NSLocalizedString("genericErrorMessage", comment: "")
        showCancelableAlert(title, message, nil)
    }
    
    
    func genericError () {
        let title = NSLocalizedString("genericErrorTitle", comment: "")
        let message = NSLocalizedString("genericErrorMessage", comment: "")
        showCancelableAlert(title, message, nil)
    }
    
    func backendAPIError (message: String) {
        let title = NSLocalizedString("genericErrorTitle", comment: "")
        let message = message.isEmpty ? NSLocalizedString("genericErrorMessage", comment: "") : message
        showCancelableAlert(title, message, nil)
    }
    
    func noMatchesError () {
        let title = NSLocalizedString("genericErrorTitle", comment: "")
        let message = NSLocalizedString("noMatchesMessage", comment: "")
        showCancelableAlert(title, message, nil)
    }
    
    func successfullyRegistered (withUserName name : String? , action : @escaping  ()->() ) {
        let title = NSLocalizedString("successAlertTitle", comment: "")
        let message = NSLocalizedString("registrationSuccessMessage", comment: "") + " " + (name ?? "")
        let action = UIAlertAction(title: NSLocalizedString("dismissAlertButton", comment: ""), style: .default) { _ in action() }
        showAlert(title, message, [action])
    }
    
    func logoutAlert (action : @escaping  ()->() ) {
        let title = NSLocalizedString("logoutAlertTitle", comment: "")
        let message = NSLocalizedString("logoutAlertMessage", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("logoutAlertTitle", comment: ""), style: .default) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    func loginFirstToFav (action : @escaping  ()->() ) {
        let title = NSLocalizedString("loginFirstAlertTitle", comment: "")
        let message = NSLocalizedString("loginFirstAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("loginAlertTitle", comment: ""), style: .default) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    func loginToContinue (action : @escaping  ()->() ) {
        let title = NSLocalizedString("loginToContinueAlertTitle", comment: "")
        let message = NSLocalizedString("loginToContinueAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("loginAlertTitle", comment: ""), style: .default) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    func commentPosted(action : @escaping  ()->() ) {
        let title = NSLocalizedString("successAlertTitle", comment: "")
        let message = NSLocalizedString("commentPostedAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("dismissAlertButton", comment: ""), style: .default) { _ in action() }
        showAlert(title, message, [action])
    }
    
    func clearHistory(action : @escaping  ()->() ) {
        let title = NSLocalizedString("clearHistoryAlertTitle", comment: "")
        let message = NSLocalizedString("clearHistoryAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("clearAlertButton", comment: ""), style: .destructive) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    func removeShowFromHistory(action : @escaping  ()->() ) {
        let title = NSLocalizedString("removeShowAlertTitle", comment: "")
        let message = NSLocalizedString("removeShowAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("removeAlertButton", comment: ""), style: .destructive) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    func deleteShowFromDownload(action : @escaping  ()->() ) {
        let title = NSLocalizedString("deleteFromDownloadAlertTitle", comment: "")
        let message = NSLocalizedString("deleteFromDownloadAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("deleteAlertButton", comment: ""), style: .destructive) { _ in action() }
        showCancelableAlert(title, message, [action])
    }
    
    
    func changeLanguageRestart (quitAction : @escaping () ->() ) {
        let title = NSLocalizedString("changeLanguageAlertTitle", comment: "")
        let message = NSLocalizedString("changeLanguageAlertBody", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("appQuitAlertButton", comment: ""), style: .destructive) { (_) in quitAction() }
        showCancelableAlert(title, message, [action])
    }
    
    func changeMode(quitAction : @escaping () ->() ) {
        let title = NSLocalizedString("changeModeAlertTitle", comment: "")
        let message = NSLocalizedString(ramadanModeAlertMessage, comment: "")
        let action = UIAlertAction(title: NSLocalizedString("okAlertButton", comment: ""), style: .default) { (_) in quitAction() }
        showCancelableAlert(title, message, [action])
    }

}


class ActionSheet {

    let viewController : UIViewController
    
    init(on viewController : UIViewController) {
        self.viewController = viewController
    }
    
    private func showActionSheet (_ title : String, message : String?, actions : [UIAlertAction]?) {
        let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        if let actions = actions {
            actions.forEach { (action) in
                sheet.addAction(action)
            }
        }
        sheet.addAction(UIAlertAction(title: NSLocalizedString("dismissAlertButton", comment: ""), style: .cancel, handler: nil))
        sheet.popoverPresentationController?.sourceView = viewController.view
        sheet.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
        sheet.popoverPresentationController?.permittedArrowDirections = []
        //sheet.view.tintColor = .blue
        viewController.present(sheet, animated: true, completion: nil)
    }

    func clearHistory(clearAction : @escaping  ()->()) {
        let title = NSLocalizedString("More", comment: "")
        let action = UIAlertAction(title: NSLocalizedString("clearHistoryAlertTitle", comment: "nil"), style: .default) { _ in clearAction() }
        showActionSheet(title, message: nil, actions: [action])
    }
    
    func chooseDownloadResolution( sources: [CPlayerResolutionSource], selectedResolutionAction : @escaping (_ card : CPlayerResolutionSource)-> () ) {
        let title = NSLocalizedString("downloadResolutionSheetTitle", comment: "")
        var sheetActions = [UIAlertAction]()
        for source in sources.filter ({$0.source_file != nil}) {
            let action = UIAlertAction(title: source.title, style: .default) { _ in selectedResolutionAction(source) }
            sheetActions.append(action)
        }
        showActionSheet(title, message: nil, actions: sheetActions)
    }

}





