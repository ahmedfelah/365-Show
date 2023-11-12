//
//  UpdateProfileViewController.swift
//  ShoofCinema
//
//  Created by mac on 4/10/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit

class UpdateProfileViewController: MasterVC {
    
    private var avatarBase64: String = ""
    
    private let nameTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        textField.placeholder = NSLocalizedString("name", comment: "")
        textField.font = Fonts.almaraiBold(17)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
        textField.isHidden = false
        textField.layer.cornerRadius = 16
        textField.tintColor = Theme.current.tintColor
        return textField
    }()
    
    private let usernameTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        textField.placeholder = NSLocalizedString("username", comment: "")
        textField.font = Fonts.almaraiBold(17)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
        textField.isHidden = false
        textField.layer.cornerRadius = 16
        textField.tintColor = Theme.current.tintColor
        return textField
    }()
    
    private let passwordTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .password
        }
        textField.isSecureTextEntry = true
        textField.keyboardAppearance = .dark
        textField.placeholder = NSLocalizedString("password", comment: "")
        textField.font = Fonts.almaraiBold(17)
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
        textField.tintColor = Theme.current.tintColor
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    private let phoneTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        textField.placeholder = NSLocalizedString("phone", comment: "")
        textField.font = Fonts.almaraiBold(17)
        textField.keyboardAppearance = .dark
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
        textField.isHidden = false
        textField.layer.cornerRadius = 16
        textField.tintColor = Theme.current.tintColor
        textField.keyboardType = .numberPad
        return textField
    }()
    
    lazy var submitButton : MainButton = {
        let button = MainButton()
        button.setTitle(NSLocalizedString("update", comment: ""), for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = Fonts.almaraiBold(17)
        button.setBackgroundColor(Theme.current.tintColor, for: .normal)
        button.setBackgroundColor(Theme.current.tintColor.withAlphaComponent(0.6), for: .disabled)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        return button
    }()
    
    lazy var Avatar: ProfileAvatarView = {
        let avatar = ProfileAvatarView()
        avatar.backgroundColor = Theme.current.secondaryColor
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        avatar.imageView.contentMode = .scaleAspectFill
        
        return avatar
    }()
    
    lazy var logoStackView : UIStackView = {
        let button = MainButton()
        button.setTitle(NSLocalizedString("selectAvatar", comment: ""), for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = Fonts.almaraiBold(17)
        button.setTitleColor(Theme.current.tintColor, for: .normal)
        button.setBackgroundColor(Theme.current.secondaryColor, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(updateAvatar), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [Avatar, button])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            Avatar.heightAnchor.constraint(equalToConstant: 100),
            Avatar.widthAnchor.constraint(equalToConstant: 100),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 170),
           
        ])
        
        button.layer.cornerRadius = 20
        Avatar.layer.cornerRadius = 50
        
        return stackView
    }()
    
    
    lazy var textFieldsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, usernameTextField, passwordTextField, phoneTextField])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            nameTextField.heightAnchor.constraint(equalToConstant: 56),
            usernameTextField.heightAnchor.constraint(equalToConstant: 56),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            phoneTextField.heightAnchor.constraint(equalToConstant: 56),
        ])
        
        return stackView
    }()
    
    lazy var contentView : UIStackView = {
        
        var stackView = UIStackView(arrangedSubviews: [logoStackView, textFieldsStackView, submitButton])
        
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 30
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        submitButton.layer.cornerRadius = 16
        
        return stackView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        //        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        return scrollView
    }()
    
    lazy var containerView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [scrollView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func setupViews() {
        super.setupViews()
        nameTextField.text = ShoofAPI.User.current?.name ?? ""
        usernameTextField.text = ShoofAPI.User.current?.userName ?? ""
        phoneTextField.text = ShoofAPI.User.current?.phone ?? ""
        
        if let avatar = ShoofAPI.User.current?.image  {
            Avatar.setImage(from: avatar)
        } else {
            Avatar.setFirstLetter(fromName: ShoofAPI.User.current?.name ?? "Shoof")
        }
        
        self.title = NSLocalizedString("updateProfile", comment: "")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate {
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            containerView.topAnchor.constraint(equalTo: view.topAnchor)
            
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor)
            
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30)
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10)
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30)
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        }
        
        if #available(iOS 11, *), let constant = UIApplication.shared.keyWindow?.safeAreaInsets.bottom, constant > 0 {
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant).isActive = true
        } else {
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    
    @objc func submit(sender: MainButton) {
        view.endEditing(true)
        
        guard let name = nameTextField.text, !name.isEmpty, let password = passwordTextField.text, let phone = phoneTextField.text, let username = usernameTextField.text else {
            sender.shake()
            return
        }
        
        navigationItem.hidesBackButton = true
        
        submitButton.showActivityIndicator()
        
        ShoofAPI.shared.updateUser(name: name, username: username, password: checkString(string: password), phone: phone, image: checkString(string: avatarBase64)) { [weak self] result in
            self?.handleUpdateUser(result: result)
        }
    }
    
    private func checkString(string: String) -> String? {
        return string.isEmpty ? nil : string
    }
    
    @objc func updateAvatar(sender: MainButton) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    
    
    private func handleUpdateUser(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            
            ShoofAPI.shared.currentUser { [weak self] result in
                self?.handleCurrentUser(result: result)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.navigationItem.hidesBackButton = false
                self.submitButton.hideActivityIndicator()
                self.tabBar?.alert.backendAPIError(message: error.localizedDescription)
            }
        }

    }
    
    private func handleCurrentUser(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            let user = response.body
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.submitButton.hideActivityIndicator()
            }
        } catch {
            DispatchQueue.main.async {
                self.tabBar?.alert.backendAPIError(message: error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = false
            submitButton.hideActivityIndicator()
        }
    }
}


extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let possibleImage = info[.editedImage] as? UIImage {
            Avatar.setImage(image: possibleImage)
            setAvatarBase64(avatar: possibleImage)
        } else if let possibleImage = info[.originalImage] as? UIImage {
            Avatar.setImage(image: possibleImage)
            setAvatarBase64(avatar: possibleImage)
        } else {
            return
        }

        dismiss(animated: true)
    }
    
    private func setAvatarBase64(avatar: UIImage) {
        let avatarData: NSData = avatar.jpegData(compressionQuality: 0.50)! as NSData
        let avatarString = avatarData.base64EncodedString(options: .init(rawValue: 0))
        self.avatarBase64 = avatarString
        
    }
    
}



