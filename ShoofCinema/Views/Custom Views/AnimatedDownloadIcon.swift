//
//  AnimatedDownloadIcon.swift
//  SuperCell
//
//  Created by Husam Aamer on 1/29/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit

class AnimatedDownloadIcon: AnimatedImageView {
    let loadingImages = (0...12).map { UIImage(named: "Download_\($0)")!}
    
    override func didMoveToSuperview() {
        if superview != nil {
            image = loadingImages.first
            animationImages = loadingImages
            animationDuration = 1.5
            animationRepeatCount = 100
            startAnimate { [weak self](completed) in
                guard let `self` = self else {return}
                self.image = self.loadingImages.last
            }
            superview?.tintColor = Theme.current.tintColor
        } else {
            superview?.tintColor = Theme.current.captionsColor
        }
    }
}

class AnimatedImageView: UIImageView, CAAnimationDelegate {

    var completion: ((_ completed: Bool) -> Void)?

    func startAnimate(completion: ((_ completed: Bool) -> Void)?) {
        self.completion = completion
        if let animationImages = animationImages {
            let cgImages = animationImages.map({ $0.cgImage as AnyObject })
            let animation = CAKeyframeAnimation(keyPath: "contents")
            animation.values = cgImages
            animation.repeatCount = Float(self.animationRepeatCount)
            animation.duration = self.animationDuration
            animation.delegate = self
            self.layer.add(animation, forKey: nil)
        } else {
            self.completion?(false)
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?(flag)
    }
}
