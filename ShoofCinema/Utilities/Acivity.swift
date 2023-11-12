//
//  Acivity.swift
//  Qi Mobile Bank
//
//  Created by Abdulla Jafar on 1/9/20.
//  Copyright © 2020 Enjaz Mac. All rights reserved.
//

import Foundation
import UIKit

class Activity {

    static func presentShareSheet(onViewController vc : UIViewController, withText text  : String , buttonOrigin : CGPoint) {
        let actitiviyController = UIActivityViewController(activityItems: [text], applicationActivities:nil)
        actitiviyController.excludedActivityTypes = [UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.message]
        actitiviyController.popoverPresentationController?.sourceView = vc.view
        actitiviyController.popoverPresentationController?.sourceRect = CGRect(x: buttonOrigin.x, y: buttonOrigin.y, width: 100, height: 200)
        actitiviyController.popoverPresentationController?.permittedArrowDirections = .down
        vc.present(actitiviyController, animated: true)
    }
}
