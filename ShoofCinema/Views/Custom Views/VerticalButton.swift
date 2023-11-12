//
//  VerticalButton.swift
//  ShoofCinema
//
//  Created by Husam Aamer on 5/5/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

class VerticalButton: UIControl {
	
	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .center
		return imageView
	}()

	lazy var label: UILabel = {
		let label = UILabel()
		label.font = Fonts.almaraiBold(12)
		label.minimumScaleFactor = 0.3
		label.adjustsFontSizeToFitWidth = true
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()
	
	var loadinIndicator: UIActivityIndicatorView?
	
	private var images: [State: UIImage] = [:]
	
	private var titles: [State: String] = [:]
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
        self.backgroundColor = Theme.current.backgroundColor
	}
	
	internal func commonInit () {
		let inset = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
		
		addSubview(imageView)
		addSubview(label)

		imageView.snp.makeConstraints { make in
			make.leading.top.trailing.equalToSuperview().inset(inset)
		}
		
		label.setContentHuggingPriority(.defaultHigh, for: .vertical)
		label.snp.makeConstraints({ make in
			make.leading.trailing.bottom.equalToSuperview().inset(inset)
			make.top.equalTo(imageView.snp.bottom).inset(-6)
		})
	}
	
	public func setTitle(_ title:String?, for state:State) {
		titles[state] = title
		
		// Apply immediatly
		if state == self.state {
			label.text = title
		}
	}
	
	public func setImage(_ image:UIImage?, for state:State) {
	 	images[state] = image
		
		// Apply immediatly
		if state == self.state {
			imageView.image = image
		}
	}
	
	override var isSelected: Bool {
		didSet {
			imageView.image = isSelected ? images[.selected] ?? images[.normal] : images[.normal]
			label.text = isSelected ? titles[.selected] ?? titles[.normal] : titles[.normal]
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				imageView.alpha = 0.8
				label.alpha = 0.8
			} else {
				imageView.alpha = 1
				label.alpha = 1
			}
			imageView.image = isHighlighted ? images[.highlighted] ?? images[.normal] : images[.normal]
			label.text = isHighlighted ? titles[.highlighted] ?? titles[.normal] : titles[.normal]
		}
	}
}

// MARK: Loading Indicator Funcs
extension VerticalButton {
	private func addIndicatorView () {
		if loadinIndicator == nil {
			if #available(iOS 13.0, *) {
				loadinIndicator = .init(style: .medium)
				loadinIndicator?.color = .white
			} else {
				loadinIndicator = .init(style: .white)
			}
			loadinIndicator?.hidesWhenStopped = true
			addSubview(loadinIndicator!)
			loadinIndicator?.snp.makeConstraints({
				$0.center.equalTo(self.imageView)
			})
		}
	}
	
	func startLoading () {
		isUserInteractionEnabled = false
		imageView.alpha = 0.2
		addIndicatorView()
		loadinIndicator?.startAnimating()
	}
	
	func stopLoading () {
		isUserInteractionEnabled = true
		imageView.alpha = 1
		loadinIndicator?.stopAnimating()
		loadinIndicator?.removeFromSuperview()
		loadinIndicator = nil
	}
}
