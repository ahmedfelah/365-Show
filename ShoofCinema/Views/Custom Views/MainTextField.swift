//
//  MainTextField.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/9/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation

import UIKit

public class MainTextField: UITextField {
    
    internal let padding : UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupView()

    }

    internal func setupView() {
        self.borderStyle = .none
        self.layer.cornerRadius = 10
        
        /// colors
        self.backgroundColor = Theme.current.secondaryColor
        self.textColor = .white
        self.tintColor = Theme.current.tintColor

        self.font = Fonts.almarai()
    }

	public override var placeholder: String? {
		set {
			if let p  = newValue {
				let place = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray,
																	   NSAttributedString.Key.font : Fonts.almarai()])
				self.attributedPlaceholder = place
			} else {
				self.attributedPlaceholder = nil
			}
		}
		get {
			attributedPlaceholder?.string
		}
	}
	
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}





public class SearchTextField: UITextField {
    
    internal let padding : UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupView()

    }

    internal func setupView() {
        self.borderStyle = .none
        
        /// colors
        self.backgroundColor = Theme.current.backgroundColor
        self.textColor = .white
        self.tintColor = Theme.current.tintColor

        /// place holder color
        if let p  = placeholder {
            let place = NSAttributedString(string: p, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray,
                                                                   NSAttributedString.Key.font : Fonts.almarai(20)])
            self.attributedPlaceholder = place
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}
