//
//  ShowOverlayView.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 12/13/20.
//  Copyright © 2020 AppChief. All rights reserved.
//

import UIKit
import Koloda

class KolodaLabelCardView: OverlayView {

    var imageView: UIImageView!
    var title: UILabel!
    var descLabel:UILabel!
    var card:UIView!
    
    init(image:UIImage?, title:String, description:String?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
        
        card = UIView(frame: bounds)
        card.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        card.layer.cornerRadius = 12
        card.layer.shadowRadius = 4
        card.layer.shadowOpacity = 0.3
        card.layer.shadowOffset = CGSize(width: 0, height: 5)
        //card.clipsToBounds = true
        
        addSubview(card)
        
        
        card.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(30)
            $0.trailing.greaterThanOrEqualTo(-30)
            $0.height.equalTo(UIScreen.main.bounds.height / 1.9)
            $0.centerY.equalToSuperview().offset(-110)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().inset(-30 * 2).priority(.low)
        }
        
        
        imageView = UIImageView(frame: bounds)
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = image
        card.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        
        self.title = UILabel(frame: .zero)
        self.title.textColor = Theme.current.captionsColor
        self.title.font = .preferredFont(forTextStyle: .title3)
        self.title.text = title
        self.title.numberOfLines = 0
        self.title.textAlignment = .center
        card.addSubview(self.title)
        
        self.descLabel = UILabel(frame: .zero)
        self.descLabel.textColor = Colors.captionsDarker
        self.descLabel.font = .preferredFont(forTextStyle: .body)
        self.descLabel.text = description
        self.descLabel.numberOfLines = 0
        self.descLabel.textAlignment = .center
        card.addSubview(self.descLabel)
        
        self.title.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(30)
            $0.trailing.equalToSuperview().inset(30)
            $0.top.equalTo(imageView.snp.bottom).offset(35)
            //$0.bottom.equalToSuperview().inset(12)
        }
        
        self.descLabel.snp.makeConstraints({
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.title.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(12)
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
