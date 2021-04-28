//
//  LoginController.swift
//  Bee
//
//  Created by Abraham Estrada on 4/13/21.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private var formIsValid: Bool {
        return emailTextField.text != "" && passwordTextField.text != ""
    }
    
    private let beeLabel: UILabel = {
        let label = UILabel()
        label.text = "Bee"
        label.font = UIFont.boldSystemFont(ofSize: 36)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        tf.spellCheckingType = .no
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = #colorLiteral(red: 0.812174499, green: 0.8045112491, blue: 0.03356609866, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.setWidth(175)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardOnTap()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        AuthService.logUserIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.showMessage(withTitle: "Error", message: "Failed to login user: \(error.localizedDescription)")
                return
            }
            self.delegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        updateForm()
    }
    
    func updateForm() {
        loginButton.backgroundColor = formIsValid ? #colorLiteral(red: 0.6662066579, green: 0.6599221826, blue: 0.05032981187, alpha: 1) : #colorLiteral(red: 0.812174499, green: 0.8045112491, blue: 0.03356609866, alpha: 1).withAlphaComponent(0.5)
        loginButton.setTitleColor(formIsValid ? .white : UIColor.white.withAlphaComponent(0.5), for: .normal)
        loginButton.isEnabled = formIsValid
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        configureGradientLayer()
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(beeLabel)
        beeLabel.centerX(inView: view)
        beeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: beeLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(signUpButton)
        signUpButton.centerX(inView: view)
        signUpButton.anchor(top: stack.bottomAnchor, paddingTop: 32)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}
