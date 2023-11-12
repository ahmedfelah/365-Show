//
//  ForgotPasswordViewController.swift
//  ShoofCinema
//
//  Created by mac on 4/6/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

//
//  LoginViewController.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 2/21/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit


class ForgotPasswordViewController: MasterVC {
    
    var token: String?
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    private let usernameTextField : MainTextField = {
        let textField = MainTextField()
        if #available(iOS 11, *) {
            textField.textContentType = .username
        }
        textField.placeholder = NSLocalizedString("code", comment: "")
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
        textField.isHidden = true
        textField.tintColor = Theme.current.tintColor
        textField.layer.cornerRadius = 16
        return textField
    }()
    
    lazy var submitButton : MainButton = {
        let button = MainButton()
        button.setTitle("submit", for: .normal)
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
    
    
    
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = currentMode.message
        label.numberOfLines = 3
        label.font = Fonts.almarai(17)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var Titlelabel: UILabel = {
        let label = UILabel()
        label.text = currentMode.title
        label.font = Fonts.almaraiBold(20)
        label.textColor = .white
        return label
    }()
    
    private var currentMode: Mode = .forgetPassword {
        didSet {
            self.Titlelabel.text = currentMode.title
            //submitButton.setTitle("sfgsfsg", for: .normal)
            label.text = currentMode.message
            usernameTextField.isHidden = currentMode == .forgetPassword
            passwordTextField.isHidden = currentMode == .forgetPassword
            emailTextField.isHidden = currentMode == .updatePassword
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
    
    
    lazy var textFieldsStackView : UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [Titlelabel, label, emailTextField, usernameTextField, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.setCustomSpacing(3, after: passwordTextField)
        stackView.setCustomSpacing(5, after: Titlelabel)
        stackView.setCustomSpacing(50, after: label)
        stackView.alignment = .fill
        //stackView.distribution = .fillEqually
        
        NSLayoutConstraint.activate([
            usernameTextField.heightAnchor.constraint(equalToConstant: 56),
            emailTextField.heightAnchor.constraint(equalToConstant: 56),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
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
        
        self.title = currentMode.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        view.addSubview(containerView)
        
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
            
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
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
        }
    }
    
    @objc func submit(sender: MainButton) {
        view.endEditing(true)
        
        if currentMode == .forgetPassword {
            guard let email = emailTextField.text, !email.isEmpty else {
                sender.shake()
                return
            }
            
            navigationItem.hidesBackButton = true
            submitButton.showActivityIndicator()
            
            ShoofAPI.shared.forgetPassword(withEmail: email) {  result in
                self.handleForgetPassword(result: result)
            }
        } else {
            guard let password = passwordTextField.text, !password.isEmpty, let token = token, let userName = usernameTextField.text, !userName.isEmpty else {
                sender.shake()
                return
            }
            
            navigationItem.hidesBackButton = true
            
            submitButton.showActivityIndicator()
            
            ShoofAPI.shared.changePassword(code: userName, password: password, token: token) { [weak self] result in
                self?.handleChangePassword(result: result)
            }
        }
    }
    
    private func showCancelableAlert(_ title:String, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancelAlertButton", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func backendAPIError (message: String) {
        let title = NSLocalizedString("genericErrorTitle", comment: "")
        let message = message.isEmpty ? NSLocalizedString("genericErrorMessage", comment: "") : message
        showCancelableAlert(title, message)
    }
    
    func showAlertWithDone (_ title:String, _ message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("doneAlertButton", comment: ""), style: .default, handler: { _ in self.dismiss()}))
        alert.view.tintColor = Theme.current.tintColor
        self.present(alert, animated: true)
    }

    
    
    private func handleForgetPassword(result: Result<ShoofAPI.AccountEndpoint<String>.Response, Error>) {
        do {
            let response = try result.get()
            token = response.body
            
            DispatchQueue.main.async {
                self.currentMode = .updatePassword
                self.submitButton.hideActivityIndicator()
            }
        } catch ShoofAPI.Error.authenticationCancelled {
            print("Cancelled")
        } catch {
            DispatchQueue.main.async {
                self.backendAPIError(message: error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = false
            submitButton.hideActivityIndicator()
        }
    }
    
    private func handleChangePassword(result: Result<ShoofAPI.AccountEndpoint<String>.Response, Error>) {
        do {
            let response = try result.get()
            token = response.body
            
            DispatchQueue.main.async {
                self.submitButton.hideActivityIndicator()
                self.showAlertWithDone(.passwordUpdatedTitle, .passwordUpdatedMessage)
            }
        } catch ShoofAPI.Error.authenticationCancelled {
            print("Cancelled")
        } catch {
            DispatchQueue.main.async {
                self.backendAPIError(message: error.localizedDescription)
            }
        }
        
        DispatchQueue.main.async { [self] in
            navigationItem.hidesBackButton = false
            submitButton.hideActivityIndicator()
        }
    }
}

extension ForgotPasswordViewController {
    enum Mode {
        case forgetPassword, updatePassword
        
        var title: String {
            switch self {
            case .forgetPassword: return .forgetPasswordTitle
            case .updatePassword: return .updatePasswordTitle
            }
        }
        
        var switchModeTitle: String {
            switch self {
            case .forgetPassword: return .sendCode
            case .updatePassword: return .updatePassword
            }
        }
        
        var message: String {
            switch self {
            case .forgetPassword: return .forgetPasswordMessage
            case .updatePassword: return .updatePasswordMessage
            }
        }
        
        mutating func swtich() {
            switch self {
            case .forgetPassword:
                self = .updatePassword
            case .updatePassword:
                self = .forgetPassword
            }
        }
    }
}

fileprivate extension String  {
    static let forgetPasswordTitle = NSLocalizedString("forgetPasswordTitle", comment: "")
    static let updatePasswordTitle = NSLocalizedString("updatePasswordTitle", comment: "")
    static let forgetPasswordMessage = NSLocalizedString("forgetPasswordMessage", comment: "")
    static let updatePasswordMessage = NSLocalizedString("updatePasswordMessage", comment: "")
    static let forgetPassword = NSLocalizedString("forgetPassword", comment: "")
    static let updatePassword = NSLocalizedString("updatePassword", comment: "")
    static let passwordUpdatedTitle = NSLocalizedString("passwordUpdatedTitle", comment: "")
    static let passwordUpdatedMessage = NSLocalizedString("passwordUpdatedMessage", comment: "")
    static let sendCode = NSLocalizedString("sendCode", comment: "")
}

