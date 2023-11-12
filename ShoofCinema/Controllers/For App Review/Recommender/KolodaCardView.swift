//
//  ShowOverlayView.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 12/13/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit
import Koloda

class KolodaCardView: OverlayView {

    var imageView: UIImageView!
    var title: UILabel!
    var card:UIView!
    var matchLabel:UILabel!
    
    init(show: ShoofAPI.Show) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        
        card = UIView(frame: bounds)
        card.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        card.layer.cornerRadius = 12
        card.layer.shadowRadius = 4
        card.layer.shadowOpacity = 0.3
        card.layer.shadowOffset = CGSize(width: 0, height: 5)
        addSubview(card)
        
        card.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(30)
            $0.trailing.greaterThanOrEqualTo(-30)
            $0.height.equalTo(UIScreen.main.bounds.height / 1.7)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-110)
            $0.width.equalToSuperview().inset(-30 * 2).priority(.low)
        }
        
        
        imageView = UIImageView(frame: bounds)
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
		imageView.kf.setImage( with: show.posterURL, placeholder: nil, options: [.transition(.fade(0.4))])
        card.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(12)
            $0.trailing.greaterThanOrEqualTo(-12)
            $0.top.equalTo(12)
            $0.height.equalTo((UIScreen.main.bounds.height / 1.7) - 60)
            $0.width.equalTo(imageView.snp.height).multipliedBy(0.690)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(-12 * 2).priority(.low)
        }
        
        
        title = UILabel(frame: .zero)
        title.textColor = .white
        title.font = .systemFont(ofSize: 20)
        title.text = show.title
        title.numberOfLines = 1
        title.textAlignment = .center
        card.addSubview(title)
        
        title.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.leading).inset(10)
            $0.trailing.equalTo(imageView.snp.trailing).inset(10)
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        let matchRate = "\(Int(arc4random_uniform(10)) + 82)%"
//        if matchValues == nil {
//            matchValues = [:]
//        }
        matchValues[show.id] = matchRate
        
        matchLabel = UILabel(frame: .zero)
        matchLabel.textColor = UIColor(red: 0.68, green: 0.81, blue: 0.46, alpha: 1.00)
        if #available(iOS 11.0, *) {
            matchLabel.font = .systemFont(ofSize: 20, weight: .black)
        }
        matchLabel.text = show.title
        matchLabel.numberOfLines = 0
        matchLabel.textAlignment = .center
        matchLabel.text = matchRate
        matchLabel.backgroundColor = card.backgroundColor
        matchLabel.layer.cornerRadius = 6
        matchLabel.clipsToBounds = true
        card.addSubview(matchLabel)
        matchLabel.snp.makeConstraints({
            $0.centerX.equalTo(imageView.snp.centerX)
            $0.bottom.equalTo(imageView.snp.bottom).offset(6)
        })
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            card.alpha = 0
            card.frame.offsetY(-30)
            UIView.animate(withDuration: 0.7) {
                self.card.alpha = 1
                self.card.frame.offsetY(30)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
