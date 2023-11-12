//
//  Navigator.swift
//  Qi Mobile Bank
//
//  Created by Abdulla Jafar on 12/22/19.
//  Copyright © 2019 Enjaz Mac. All rights reserved.
//

import Foundation
import UIKit



final class Navigator {

    public static func loadViewController(onWindow window : UIWindow?, _ storyboardFileName : String, _ viewControllerID : String) {
        let sb = UIStoryboard(name: storyboardFileName, bundle: nil)
        window?.rootViewController = sb.instantiateViewController(withIdentifier: viewControllerID)
        window?.makeKeyAndVisible()
    }

    public static func changeWindowTo(_ storyboardFileName : String, _ viewControllerID : String) {
        let storyBoard = UIStoryboard(name: storyboardFileName, bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: viewControllerID)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window!.rootViewController = VC
        }
    }
    
    public static func persentViewController(on viewController : UIViewController ,_ storyboardFileName : String, _ viewControllerID : String,
                                                  _ presentationStyle : UIModalPresentationStyle = .fullScreen,
                                                  _ transitionStyle : UIModalTransitionStyle?  = nil) {
        let storyBoard = UIStoryboard(name: storyboardFileName, bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: viewControllerID)
        VC.modalPresentationStyle = presentationStyle
        if let transitionStyle = transitionStyle {
            VC.modalTransitionStyle = transitionStyle
        }
        viewController.present(VC, animated: true, completion: nil)
    }
    
    


}
