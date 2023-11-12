//
//  LoginViewController.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/21/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

class LoginViewController: MasterVC {
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
        textField.isHidden = true
        textField.layer.cornerRadius = 16
        textField.tintColor = Theme.current.tintColor
        return textField
    }()
    
    private let emailTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .emailAddress
        }
        textField.autocorrectionType = .no
        textField.keyboardAppearance = .dark
        textField.keyboardType = .emailAddress
        textField.placeholder = NSLocalizedString("emailAddress", comment: "")
        textField.font = Fonts.almaraiBold(17)
        textField.textColor = .white
        textField.minimumFontSize = 17
        textField.backgroundColor = Theme.current.secondaryColor
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
    
    lazy var submitButton : MainButton = {
        let button = MainButton()
        button.setTitle(.loginTitle, for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = Fonts.almaraiBold(17)
//        button.backgroundColor = Colors.tint
        button.setBackgroundColor(Theme.current.tintColor, for: .normal)
        button.setBackgroundColor(Theme.current.tintColor.withAlphaComponent(0.6), for: .disabled)
        button.clipsToBounds = true
        
//        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)
        return button
    }()
    
    lazy var orLabel : UILabel = {
        let label = UILabel()
        label.font = Fonts.almarai(24)
        label.textColor = .white
        label.text = .orTitle
        label.textAlignment = .center
        return label
    }()
    
    lazy var switchModeButton : MainButton = {
        let button = MainButton()
        button.setTitle(.registerTitle, for: .normal)
        button.titleLabel?.font = Fonts.almaraiBold(15)
        button.setTitleColor(Theme.current.tintColor, for: .normal)
        button.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        return button
    }()
    
    lazy var forgotPasswordButton : MainButton = {
        let button = MainButton()
        button.setTitle("Forgot password?", for: .normal)
        button.titleLabel?.font = Fonts.almaraiBold(15)
        button.setTitleColor(Theme.current.tintColor, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .top
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
        return button
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = currentMode.message
        label.font = Fonts.almarai(17)
        label.textColor = .lightGray
        return label
    }()
    
    private var currentMode: Mode = .login {
        didSet {
            self.title = currentMode.title
            submitButton.setTitle(currentMode.title, for: .normal)
            switchModeButton.setTitle(currentMode.switchModeTitle, for: .normal)
            label.text = currentMode.message
            usernameTextField.isHidden = currentMode == .login
        }
    }
    
    lazy var logoStackView : UIStackView = {
        let imageView = UIImageView(image: UIImage(named: "ic-face-logo"))
        let label = UILabel()
        label.text = "SHOOF CINEMA"
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .lightGray
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            label.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        return stackView
    }()
    
    lazy var googleImageStack: UIStackView = {
        let imageView = UIImageView(image: UIImage(named: "google-logo"))
        imageView.contentMode = .scaleAspectFit
        
        let stackView = UIStackView(arrangedSubviews: [imageView])
        stackView.alignment = .center
        stackView.backgroundColor = .white
        stackView.distribution = .fill
        stackView.layer.cornerRadius = 2
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 52),
            stackView.widthAnchor.constraint(equalToConstant: 52),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return stackView
        
    }()
    
    lazy var textFieldsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, forgotPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.setCustomSpacing(3, after: passwordTextField)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            usernameTextField.heightAnchor.constraint(equalToConstant: 56),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
        ])
        
        return stackView
    }()
    
    lazy var facebookButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "facebook"), for: .normal)
        button.addTarget(self, action: #selector(signInWithFacebook), for: .touchUpInside)
        return button
    }()
    
    lazy var googleButton: UIButton = {
        let button = MainButton()
        button.setTitle(.signInWithGoogleTitle, for: .normal)
        button.titleLabel?.font = Fonts.almaraiBold(20)
        button.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 56)
        ])
        return button
    }()
    
    lazy var socialMediaStackView : UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [UIView(), googleImageStack, googleButton, UIView()])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.backgroundColor = Theme.current.tintColor
        stackView.spacing = 2
        stackView.layer.cornerRadius = 2
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    lazy var bottomStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), label, switchModeButton, UIView()])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        
        return stackView
    }()
    
    lazy var contentView : UIStackView = {
        
        var stackView = UIStackView(arrangedSubviews: [logoStackView, textFieldsStackView, submitButton])
        
        if appPublished {
            stackView.addArrangedSubview(orLabel)
            stackView.addArrangedSubview(socialMediaStackView)
        }
        
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
        let stackView = UIStackView(arrangedSubviews: [scrollView, bottomStackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        self.title = currentMode.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        view.addSubview(containerView)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            bottomStackView.removeFromSuperview()
            contentView.addArrangedSubview(bottomStackView)
        }
//        contentView.backgroundColor = .gray
//
//        view.backgroundColor = .blue
//
//        bottomStackView.backgroundColor = .yellow
//
//        containerView.backgroundColor = .red
        
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
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                bottomStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30)
                bottomStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30)
                scrollView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor)
            } else {
//                bottomStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
//                bottomStackView.widthAnchor.constraint(equalToConstant: 200)
//                bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30)
//                bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            }
            
//            bottomStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//            bottomStackView.heightAnchor.constraint(equalToConstant: 40),
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func switchMode(sender: MainButton) {
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) { [self] in
            currentMode.swtich()
            view.layoutIfNeeded()
            
            if #available(iOS 12.0, *) {
                switch currentMode {
                case .login:
                        passwordTextField.textContentType = .password
                case .register:
                    passwordTextField.textContentType = .newPassword
                }
            }
        }
    }
    
    @objc func forgotPassword(sender: MainButton) {
        let vc = ForgotPasswordViewController()
        if let sheet = vc.sheetPresentationController {
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(vc, animated: true, completion: nil)
    }
    
    @objc func submit(sender: MainButton) {
        view.endEditing(true)
        
        if currentMode == .login {
            guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
                sender.shake()
                return
            }
            
            navigationItem.hidesBackButton = true
            
            submitButton.showActivityIndicator()
            facebookButton.isEnabled = false
            googleButton.isEnabled = false
            switchModeButton.isEnabled = false
            
            ShoofAPI.shared.login(withEmail: email, password: password) { [weak self] result in
                print(result)
                self?.handleAuthentication(result: result)
            }
        } else { // currentMode == .register
            guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty, let userName = usernameTextField.text, !userName.isEmpty else {
                sender.shake()
                return
            }
            
            navigationItem.hidesBackButton = true
            
            submitButton.showActivityIndicator()
            facebookButton.isEnabled = false
            googleButton.isEnabled = false
            switchModeButton.isEnabled = false
            
            ShoofAPI.shared.register(withEmail: email, userName: userName, name: userName, password: password) { [weak self] result in
                self?.handleAuthentication(result: result)
            }
        }
    }
    
    @objc func signInWithFacebook(sender: UIButton) {
        view.endEditing(true)
        navigationItem.hidesBackButton = true
        
        submitButton.showActivityIndicator()
        facebookButton.isEnabled = false
        googleButton.isEnabled = false
        switchModeButton.isEnabled = false
        
        ShoofAPI.shared.signInWithFacebook(on: self) { [weak self] result in
            self?.handleAuthentication(result: result)
        }
    }
    
    @objc func signInWithGoogle(sender: UIButton) {
        view.endEditing(true)
        navigationItem.hidesBackButton = true
        
        submitButton.showActivityIndicator()
        facebookButton.isEnabled = false
        googleButton.isEnabled = false
        switchModeButton.isEnabled = false
        
        ShoofAPI.shared.signInWithGoogle(on: self) { [weak self] result in
            self?.handleAuthentication(result: result)
        }
    }
    
    private func handleAuthentication(result: Result<ShoofAPI.AccountEndpoint<ShoofAPI.User>.Response, Error>) {
        do {
            let response = try result.get()
            let user = response.body
                        
            DispatchQueue.main.async {
                guard !fakeDeletedAccounts.contains(user) else {
                    self.tabBar?.alert.backendAPIError(message: "No user associated with this email.")
                    ShoofAPI.shared.signOut()
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
                self.submitButton.hideActivityIndicator()
            }
        } catch ShoofAPI.Error.authenticationCancelled {
            print("Cancelled")
        } catch {
            DispatchQueue.main.async {
                self.tabBar?.alert.backendAPIError(message: error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = false
            submitButton.hideActivityIndicator()
            facebookButton.isEnabled = true
            googleButton.isEnabled = true
            switchModeButton.isEnabled = true
        }
    }
}

extension LoginViewController {
    enum Mode {
        case login, register
        
        var title: String {
            switch self {
            case .login: return .loginTitle
            case .register: return .registerTitle
            }
        }
        
        var switchModeTitle: String {
            switch self {
            case .login: return .registerTitle
            case .register: return .loginTitle
            }
        }
        
        var message: String {
            switch self {
            case .login: return .registerMessage
            case .register: return .loginMessage
            }
        }
        
        mutating func swtich() {
            switch self {
            case .login:
                self = .register
            case .register:
                self = .login
            }
        }
    }
}

fileprivate extension String  {
    static let loginTitle = NSLocalizedString("loginTitle", comment: "")
    static let registerTitle = NSLocalizedString("registerTitle", comment: "")
    static let loginMessage = NSLocalizedString("loginMessage", comment: "")
    static let registerMessage = NSLocalizedString("registerMessage", comment: "")
    static let orTitle = NSLocalizedString("or", comment: "")
    static let signInWithGoogleTitle = NSLocalizedString("signInWithGoogleTitle", comment: "")
}
