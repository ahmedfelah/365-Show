//
//  FamilyModeButton.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 4/22/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

class FamilyModeButton: UIButton {
    let onImage = UIImage(named: "scissors")
    let offImage = UIImage(named: "scissors")?.withAlpha(0.6)
    
    var isOn: Bool {
        get {
            ShoofAPI.Settings.shared.isFamilyModOn
        } set {
            ShoofAPI.Settings.shared.isFamilyModOn = newValue
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        update()
    }
    
    private func update() {
        UIView.transition(with: self, duration: 0.10, options: .transitionCrossDissolve) { [self] in
            setImage(isOn ? onImage : offImage, for: .normal)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isOn.toggle()
    }
}

extension UIImage {
    func withAlpha(_ a: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (_) in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: a)
        }
    }
}
