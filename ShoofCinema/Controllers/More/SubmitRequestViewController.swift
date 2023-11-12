//
//  SubmitRequestViewController.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/3/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

class SubmitRequestViewController: MasterVC {
    
    let titleTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        textField.placeholder = "Request title"
        textField.font = .systemFont(ofSize: 17, weight: .bold)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    let detailsTextView : UITextView = {
        let textView = UITextView()
        textView.keyboardAppearance = .dark
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 17, weight: .bold)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.backgroundColor = Theme.current.secondaryColor
        textView.layer.cornerRadius = 16
        textView.isScrollEnabled = true
        return textView
    }()
    
    lazy var submitButton : MainButton = {
        let button = MainButton()
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setBackgroundColor(Theme.current.tintColor, for: .normal)
        button.setBackgroundColor(Theme.current.tintColor.withAlphaComponent(0.6), for: .disabled)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        button.layer.cornerRadius = 16
        return button
    }()
    
    lazy var stackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleTextField, detailsTextView, submitButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 15
        stackView.distribution = .fillProportionally
//        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "Submit New Request"
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 56),
            detailsTextView.heightAnchor.constraint(equalToConstant: 240),
            
            submitButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
    
    @objc func submit(sender: MainButton) {
        view.endEditing(true)
        
        guard let title = titleTextField.text, !title.isEmpty, let details = detailsTextView.text, !details.isEmpty else {
            sender.shake()
            return
        }
        
        sender.showActivityIndicator()
        
        ShoofAPI.shared.addRequest(withTitle: title, details: details) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    let _ = try result.get()
                    
                    sender.hideActivityIndicator()
                    
                    if let navigationController = self?.navigationController {
                        navigationController.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true)
                    }
                } catch {
                    self?.tabBar?.alert.backendAPIError(message: error.localizedDescription)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
