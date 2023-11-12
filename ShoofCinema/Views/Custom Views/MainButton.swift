//
//  MainButton.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/21/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class MainButton: UIButton {
    
    let activityIndicator = UIActivityIndicatorView()
    var buttonString: String?
    
    
    @IBInspectable var ThemeTintColor: UIColor =  Theme.current.tintColor {
        didSet {
            self.tintColor = Theme.current.tintColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override var isEnabled: Bool {
        get {
            super.isEnabled
        } set {
            super.isEnabled = newValue
            
            if let text = titleLabel?.text, buttonString == nil {
                buttonString = text
            }
        }
    }

    internal func setupView() {
//        buttonString = self.titleLabel?.text ?? ""
        
        /// activity Indicator
        activityIndicator.style = .white
        activityIndicator.frame = self.bounds
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.isHidden = true
        

        let fontSize = self.titleLabel?.font.pointSize
        self.titleLabel?.font = Fonts.almaraiBold(fontSize ?? 17)
        /// adding action the button tap
        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    
    private func pulseAnimation() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 1.0
        pulse.toValue = 0.85
        pulse.autoreverses = true
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        self.layer.add(pulse, forKey: nil)
    }
    
    
    // MARK:- ACTIONS
    @objc internal func tapped() {
        if #available(iOS 10.0, *) {
            HapticFeedback.veryLightImpact()
        }
        pulseAnimation()
    }
    
    
    // MARK:- PUBLIC ACTION
    func showActivityIndicator () {
        buttonString = titleLabel?.text
        self.setTitle(nil, for: .normal)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        self.isEnabled = false
    }
    
    func hideActivityIndicator () {
        self.setTitle(buttonString, for: .normal)
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        self.isEnabled = true
    }
    
    func shake() {
        if #available(iOS 10.0, *) {
            HapticFeedback.error()
        }
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
}



final class NoContentButton : MainButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customize()
    }

    private func customize() {
        self.layer.borderWidth = 1
        self.layer.borderColor = Theme.current.tintColor.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor.clear
        self.setTitleColor(Theme.current.tintColor, for: .normal)
    }

}



final class PlayButton : MainButton {
    
    
    let playIcon : UIImageView = {
        let iv = UIImageView()
        let pi = UIImage(named: "ic-play-button-icon") ?? UIImage()
        iv.contentMode = .scaleAspectFill
        iv.image = pi
        iv.layer.shadowColor = Theme.current.tintColor.cgColor
        iv.layer.shadowOpacity = 0.25
        iv.layer.shadowRadius = 2
        iv.layer.shadowOffset = CGSize(width: -2, height: 2)
        return iv
    }()
    
    let nvActivityIndicator : NVActivityIndicatorView = {
        return NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50),
                                       type: .ballScale,
                                       color: Theme.current.tintColor,
                                       padding: 0)
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func setupView() {
        super.setupView()
        self.addSubview(playIcon)
        
        playIcon.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.center.equalToSuperview()
        }
        
        self.addSubview(nvActivityIndicator)
        self.nvActivityIndicator.isHidden = true
        nvActivityIndicator.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.center.equalToSuperview()
        }
        
    }

    public func showPlayActivityIndicator () {
        self.playIcon.isHidden = true
        self.nvActivityIndicator.isHidden = false
        self.nvActivityIndicator.startAnimating()
    }
    
    public func hidePlayActivityIndicator () {
        self.playIcon.isHidden = false
        self.nvActivityIndicator.isHidden = true
        self.nvActivityIndicator.stopAnimating()
    }
}



final class MatchButton : MainButton {
    
    let textLabel : UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .heavy)
        l.textColor = Theme.current.tintColor
		l.adjustsFontSizeToFitWidth = true
		l.minimumScaleFactor = 0.3
        return l
    }()
    
    let nvActivityIndicator : NVActivityIndicatorView = {
        return NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50),
                                       type: .ballScale,
                                       color: Theme.current.tintColor,
                                       padding: 0)
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func setupView() {
        
        self.isEnabled = false
        self.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        self.addSubview(nvActivityIndicator)
        self.nvActivityIndicator.isHidden = true
        nvActivityIndicator.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.center.equalToSuperview()
        }
        
    }

    public func showCustomActivityIndicator () {
        self.textLabel.isHidden = true
        self.nvActivityIndicator.isHidden = false
        self.nvActivityIndicator.startAnimating()
    }
    
    public func hideCustomActivityIndicator () {
        self.textLabel.isHidden = false
        self.nvActivityIndicator.isHidden = true
        self.nvActivityIndicator.stopAnimating()
    }
}



final class RoundedButton : MainButton {
    
    override func setupView() {
        self.layer.cornerRadius = 10
    }
}


final class CirclerButton : MainButton {
    
    override func setupView() {
        self.layer.cornerRadius = self.frame.height / 2
    }
}



class HomeHeaderButton: UIButton {
    
    let activityIndicator = UIActivityIndicatorView()
    lazy var buttonString = ""
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        
        buttonString = self.titleLabel?.text ?? ""
        
        /// activity Indicator
        activityIndicator.style = .white
        activityIndicator.frame = self.bounds
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.isHidden = true
        
        let fontSize = self.titleLabel?.font.pointSize
        self.titleLabel?.font = Fonts.almaraiLight(fontSize ?? 17)
        /// adding action the button tap
        self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    

    internal func setupView() {
    }
    
    private func pulseAnimation() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.1
        pulse.fromValue = 1.0
        pulse.toValue = 0.85
        pulse.autoreverses = true
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        self.layer.add(pulse, forKey: nil)
    }
    
    
    // MARK:- ACTIONS
    @objc internal func tapped() {
        if #available(iOS 10.0, *) {
            HapticFeedback.veryLightImpact()
        }
        pulseAnimation()
    }
    
    
    
    public func setSelected (){
        self.titleLabel?.font = Fonts.almaraiExtraBold(16)
    }
    
    
    public func setDeselected (){
        self.titleLabel?.font = Fonts.almaraiLight(15)
    }

    

    
}
