//
//  UIImageExtension.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/26/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import Kingfisher
extension UIImageView{
    func setImage( url :URL? ,  animated: Bool = true) {
        let duration = animated ? 0.3 : 0.0
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
			self.kf.setImage(with: url)
        }, completion: nil)
    }
}
