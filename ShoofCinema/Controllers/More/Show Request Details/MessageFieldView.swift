//
//  MessageFieldView.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/18/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MessageFieldView: UIView {

    var field:UITextView!
    var sendBtn:UIButton!
    lazy var indicator:UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    var sendAction:((String, @escaping (Bool)->())->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Theme.current.tabbarColor
        
        field = UITextView(frame: .zero)
        field.isScrollEnabled = true
        field.setContentHuggingPriority(.defaultLow, for: .vertical)
        field.layer.cornerRadius = 10
        field.font = Fonts.almaraiLight(17)
        //field.delegate = self
        field.keyboardDismissMode = .interactive
        field.keyboardAppearance = .dark
        addSubview(field)
        
        sendBtn = UIButton(type: .custom)
        sendBtn.setImage(UIImage(named: "send-button"), for: .normal)
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        addSubview(sendBtn)
        sendBtn.snp.makeConstraints({
            $0.top.equalTo(8)
            $0.bottom.equalTo(field.snp_bottom)
            $0.trailing.equalToSuperview().offset(-12)
        })
        
        field.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.trailing.equalTo(sendBtn.snp_leading).offset(-12)
            $0.height.equalTo(30).priority(.medium)
            $0.height.lessThanOrEqualTo(100).priority(.high)
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func sendMessage() {
        if indicator.isAnimating {
            return
        }
        self.field.isUserInteractionEnabled = false
        self.field.alpha = 0.7
        self.field.resignFirstResponder()
        
        addSubview(indicator)
        indicator.startAnimating()
        indicator.center = field.center
        
        sendAction?(field.text) { succeeded in
            self.indicator.stopAnimating()
            self.indicator.removeFromSuperview()
            
            self.field.isUserInteractionEnabled = true
            self.field.alpha = 1
            
            if succeeded {
                delay(0.1, closure: {
                        self.field.text = ""
                })
            } else {
                
            }
        }
    }
    var originalTopInset : CGFloat = 0
}
extension MessageFieldView: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        delay(0.1) {
//            guard let vc = self.parentViewController as? ShowRequestVC else {return}
//            self.originalTopInset = vc.tableView.contentInset.top
//            vc.tableView.contentInset.top = IQKeyboardManager.shared.movedDistance
//        }
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        guard let vc = self.parentViewController as? ShowRequestVC else {return}
//        vc.tableView.contentInset.top = originalTopInset
//    }
    func textViewDidChange(_ textView: UITextView) {
        textView.snp.updateConstraints({
            $0.height.equalTo(textView.contentSize.height).priority(.medium)
        })
    }
}
