//
//  HapticFeedback.swift
//  Qi Mobile Bank
//
//  Created by Abdulla Jafar on 1/5/20.
//  Copyright © 2020 Enjaz Mac. All rights reserved.
//

import Foundation
import UIKit




@available(iOS 10.0, *)
class HapticFeedback {
    @available(iOS 10.0, *)
    static let notificationFeedback = UINotificationFeedbackGenerator()
    static let selectionFeedback = UISelectionFeedbackGenerator()

    static func success () {
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warning () {
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    static func error () {
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.error)
    }
    
    
    static func lightImpact () {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func veryLightImpact () {
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
    
    static func mediumImpact () {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    
}
