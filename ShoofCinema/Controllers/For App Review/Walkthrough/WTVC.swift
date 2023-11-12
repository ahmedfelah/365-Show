//
//  WTVC.swift
//  Masosa
//
//  Created by Husam Aamer on 7/30/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

class WTVC: UIViewController {
    struct WalkthroughItem {
        var title:String
        var body:String
        var imageString:String?
        var buttonTitle:String?
        var buttonAction:()->()
    }
    
    @IBOutlet weak var imageView: RoundedImageView!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var actionBtn: MasosaButton!
    
    var _item:WalkthroughItem!
    init (with item:WalkthroughItem) {
        super.init(nibName: "WTVC", bundle: nil)
        
        _item = item
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageName = _item.imageString {
            imageView.image = UIImage(named:imageName)
        }
        titleLabel.text = _item.title
        bodyLabel.text  = _item.body
        
        if let btnTitle = _item.buttonTitle {
            actionBtn.setTitle(btnTitle, for: .normal)
        } else {
            actionBtn.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.alpha = 0
        self.bodyLabel.alpha = 0
        self.imageView.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.titleLabel.alpha = 1
            self.bodyLabel.alpha = 1
            self.imageView.alpha = 1
        }
    }

    @IBAction func actionBtnAction(_ sender: Any) {
        _item.buttonAction()
    }
}
