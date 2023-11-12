//
//  Views.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/22/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit


public class CirclerView: UIView {

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = self.frame.height / 2
    }

}

public class LineRoundedView: UIView {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 2
        self.backgroundColor = Theme.current.tintColor
    }

}


public class VeryLightRoundedView: UIView {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 5
    }

}

public class LightRoundedView: UIView {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 10
    }

}

public class MediumRoundedView: UIView {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 20
    }

}

class ProfileView : UIView {
    lazy var firstLetterLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = Theme.current.tintColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func setFirstLetter(fromName name: String) {
        let firstLetter = String(name.prefix(1)).uppercased()
        self.firstLetterLabel.text = firstLetter
        imageView.removeFromSuperview()
        addSubview(firstLetterLabel)
        NSLayoutConstraint.activate([
            firstLetterLabel.heightAnchor.constraint(equalToConstant: 70),
            firstLetterLabel.widthAnchor.constraint(equalToConstant: 70),
            firstLetterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            firstLetterLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setImage(from url: URL) {
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
        firstLetterLabel.removeFromSuperview()
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

public class ProfileNameView : CirclerView {
    
    // MARK: - LNKS & VARS
    @IBOutlet weak var firstLetterLabel : UILabel!
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
//        imageView.layer.cornerRadius = 30
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = frame.height / 2
    }
    
    // MARK: - INIT
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setGradient()
        
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - PRIVATE METHODS
    private func setGradient() {
        guard let gLayer = self.layer as? CAGradientLayer else { return }
        gLayer.colors = [UIColor.black.cgColor, Theme.current.secondaryColor.cgColor]
        gLayer.startPoint  = CGPoint(x: 0, y: -1)
        gLayer.endPoint  = CGPoint(x: 1, y: 0)  
    }
    

    
    // MARK: - PUBLIC METHODS
//    public func setFirstLetter(withName name : String) {
//        let firstLetter = String(name.prefix(1)).uppercased()
//        self.firstLetterLabel.text = firstLetter
//    }
    
    public func setFirstLetter(withName name: String) {
        let firstLetter = String(name.prefix(1)).uppercased()
        self.firstLetterLabel.text = firstLetter
        imageView.isHidden = true
        firstLetterLabel.isHidden = false
    }
    
    public func setImage(from url: URL) {
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
        firstLetterLabel.isHidden = true
        imageView.isHidden = false
    }
}

public class ProfileAvatarView : UIView {
    
    lazy var firstLetterLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = Theme.current.tintColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    func setFirstLetter(fromName name: String) {
        let firstLetter = String(name.prefix(1)).uppercased()
        self.firstLetterLabel.text = firstLetter
        imageView.removeFromSuperview()
        addSubview(firstLetterLabel)
        NSLayoutConstraint.activate([
            firstLetterLabel.heightAnchor.constraint(equalToConstant: 70),
            firstLetterLabel.widthAnchor.constraint(equalToConstant: 70),
            firstLetterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            firstLetterLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setImage(from url: URL) {
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
        firstLetterLabel.removeFromSuperview()
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    public func setImage(image: UIImage) {
        imageView.image = image
        firstLetterLabel.removeFromSuperview()
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
      
    }
}
