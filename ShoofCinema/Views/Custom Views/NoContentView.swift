//
//  NoContentView.swift
//  Giganet
//
//  Created by Husam Aamer on 6/1/18.
//  Copyright © 2018 AppChief. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class ACNoContentView: UIView {

    // MARK: - VIEWS
    var titleLabel : UILabel!
    var infoLabel : UILabel!
    var imageView : UIImageView!
    var reloadButton : NoContentButton?
    var reloadButtonBlock   :(()->())?
    
    
    // MARK: - INIT
    init(with title:String? = nil,
         _ message:String? = nil,
         and image:UIImage? = nil,
         actionButtonTitle : String? = nil,
         action:(()->())? = nil
    ) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 375, height: 600)))
        titleLabel = UILabel(frame: .zero)
        infoLabel = UILabel(frame: .zero)
        imageView = UIImageView(frame: .zero)
                
        if action != nil {
            self.reloadButtonBlock = action
            reloadButton = NoContentButton(frame : CGRect(origin: .zero, size: CGSize(width: 150, height: 50)))
            reloadButton?.setTitle(actionButtonTitle, for: .normal)
            reloadButton?.addTarget(self, action: #selector(reloadAction(_:)), for: .touchUpInside)
            addSubview(reloadButton!)
        }
        
        titleLabel.font = Fonts.almaraiBold(20)
        titleLabel.textColor = Theme.current.tintColor
        infoLabel.textColor = Theme.current.secondaryLightColor
        infoLabel.font = Fonts.almaraiLight()
        
        titleLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        infoLabel.textAlignment = .center
        imageView.contentMode = .scaleAspectFill
        
        
        reloadButton?.titleLabel?.font = Fonts.almaraiBold()
        
        addSubview(titleLabel)
        addSubview(infoLabel)
        addSubview(imageView)
        
        
        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.centerX.equalToSuperview()
            m.trailing.lessThanOrEqualTo(-18)
            m.leading.greaterThanOrEqualTo(18)
        }
        infoLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(15)
            m.centerX.equalToSuperview()
            m.width.equalTo(300)
        }
        imageView.snp.makeConstraints { (m) in
            m.bottom.equalTo(titleLabel.snp.top).offset(-40)
            m.centerX.equalToSuperview()
            m.height.equalTo(100)
            m.width.equalTo(100).priority(.low)
        }
        reloadButton?.snp.makeConstraints { (m) in
            m.top.equalTo(infoLabel.snp.bottom).offset(25)
            m.centerX.equalToSuperview()
            m.width.greaterThanOrEqualTo(150)
            m.height.greaterThanOrEqualTo(50)
        }
        
        updateViews(with: title, message, and: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You can't load this view from storyboard")
    }
    
    func updateViews(with title:String? = nil, _ info:String? = nil, and image:UIImage? = nil) {
        titleLabel.text = title
        infoLabel.text = info
        imageView.image = image
    }
    
    
    // MARK: - ACTIONS
    @objc func reloadAction (_ sender:UIButton) {
        reloadButtonBlock?()
    }
    
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		if let superview = superview {
			// if parent view is collection view flipped for right to left
			// then flip this view back
			if let cv = superview as? ShowsCollectionView {
				if isRTL,cv.collectionViewLayout.flipsHorizontallyInOppositeLayoutDirection {
					transform = .init(scaleX: -1, y: 1)
				}
			}
		}
	}
}


extension UIView {
    
    private static let association = ObjectAssociation<ACNoContentView>()
    
    var noContentView: ACNoContentView? {
        get { return UITableView.association[self] }
        set { UITableView.association[self] = newValue }
    }
    
    func show(noContentView:ACNoContentView) {
        //setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        if self.noContentView == nil {
            self.noContentView = noContentView
            addSubview(self.noContentView!)
            self.noContentView?.snp.makeConstraints({ (m) in
                m.leading.equalToSuperview()
                m.leading.equalToSuperview()
                m.centerX.equalToSuperview()
                m.centerY.equalToSuperview()
                m.height.equalTo(350)
            })
        } else {
            self.noContentView?.updateViews(with: noContentView.titleLabel.text, noContentView.infoLabel.text, and: noContentView.imageView.image)
        }
        
        //isScrollEnabled = false
    }
    
    func showNoContentView( with title:String, _ info:String, and image:UIImage, actionButtonTitle : String?, reloadButtonAction:(()->())? = nil) {
        let noContentView = ACNoContentView(with: title, info, and: image, actionButtonTitle: actionButtonTitle, action: reloadButtonAction)
        show(noContentView: noContentView)
    }
    
    func hideNoContentView() {
        noContentView?.removeFromSuperview()
        noContentView = nil
    }

}

//Associated class
public final class ObjectAssociation<T: AnyObject> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}






