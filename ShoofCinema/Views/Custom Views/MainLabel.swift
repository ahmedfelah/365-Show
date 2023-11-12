//
//  MainLabel.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/20/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit

class MainLabel: UILabel {
    
    let faceMap = [
        "Ultra Light"  :    "Light",
        "Thin"         :    "Light",
        "Light"        :    "Light",
        "Regular"      :    "Regular",
        "Medium"       :    "Regular",
        "Semibold"     :    "Regular",
        "Bold"         :    "Bold",
        "Heavy"        :    "ExtraBold",
        "Black"        :    "ExtraBold"
    ]
    
    
    override func awakeFromNib() {
        let face = font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.face) as! String
        let tjawalFace = faceMap[face] ?? "Regular"
        guard let customFont = UIFont(name: "Almarai-\(tjawalFace)", size: self.font.pointSize) else {
            fatalError("Tajawal FONT NOT LOADED")
        }
        self.font = customFont
        self.adjustsFontForContentSizeCategory = true
        
    }
    
    @IBInspectable var ThemeTintColor : UIColor = Theme.current.tintColor {
        didSet {
            textColor = Theme.current.tintColor
        }
    }
}
