//
//  LoginViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
   lazy var scrollView: UIScrollView = {
       let scrollView = UIScrollView(frame: .zero)
       scrollView.backgroundColor = .orange
       scrollView.frame = self.view.bounds // device display size
       scrollView.contentSize = contentViewSize // total content size
       scrollView.autoresizingMask = .flexibleHeight
       scrollView.clipsToBounds = true
       return scrollView
   }()
   lazy var containerView: UIView = {
      let containerView = UIView()
       containerView.frame.size = contentViewSize
       containerView.backgroundColor = .brown
       return containerView
   }()
   lazy var copyrightLable: UILabel = {
       let copyrightLable = UILabel()
       copyrightLable.text = "Lable Text"
       return copyrightLable
   }()
   lazy var imageView: UIImageView = {
       let imageView = UIImageView()
       imageView.image = UIImage(named: "logo")
       imageView.frame.size.height = 100
       imageView.contentMode = .scaleAspectFit
       return imageView
   }()
   
   lazy var emailFeild: UITextField = {
       let feild = UITextField()
       feild.autocorrectionType = .no
       feild.autocapitalizationType = .none
       feild.returnKeyType = .continue
       feild.placeholder = "Emaill ..."
       feild.textAlignment = .center
       feild.backgroundColor = .white
       feild.layer.cornerRadius = 12
       feild.layer.borderWidth = 1
       feild.layer.borderColor = UIColor.black.cgColor
       return feild
   }()
   
   lazy var passwordFeild: UITextField = {
       let feild = UITextField()
       feild.autocorrectionType = .no
       feild.autocapitalizationType = .none
       feild.returnKeyType = .done
       feild.placeholder = "Password ..."
       feild.isSecureTextEntry = true
       feild.backgroundColor = .white
       feild.textAlignment = .center
       feild.layer.cornerRadius = 12
       feild.layer.borderWidth = 1
       feild.layer.borderColor = UIColor.black.cgColor
       return feild
   }()
   lazy var loginButton: UIButton = {
       let loginBtn = UIButton()
       loginBtn.setTitle("Login", for: .normal)
       loginBtn.backgroundColor = .red
       loginBtn.setTitleColor(.white, for: .normal)
       loginBtn.layer.cornerRadius = 12
       loginBtn.layer.masksToBounds = true
       loginBtn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
       return loginBtn
   }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        emailFeild.delegate = self
        passwordFeild.delegate = self
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Register", style: .plain, target: self, action: #selector(didTapRegister))
        view.backgroundColor = .yellow
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        setupLoginConstraint()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController() //ProfileViewController() 
        vc.title = "Create Account"
        vc.view.backgroundColor = .orange
        //let nvc = UINavigationController(rootViewController: vc)
        //present(nvc, animated: true, completion: nil)
        //navigationController?.show(vc, sender: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    fileprivate func setupLoginConstraint(){
                 
                let formStackView: UIStackView = UIStackView(arrangedSubviews: [emailFeild, passwordFeild, loginButton])
                formStackView.distribution = .fillEqually
                formStackView.spacing = 15
                formStackView.axis = .vertical
                formStackView.backgroundColor = .cyan
               
                containerView.addSubview(imageView)
                containerView.addSubview(formStackView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                formStackView.translatesAutoresizingMaskIntoConstraints = false
            
                NSLayoutConstraint.activate([
                    
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 60),
                imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
                imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
                imageView.heightAnchor.constraint(equalToConstant: 100),
                
                formStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
                formStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
                formStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
                formStackView.heightAnchor.constraint(equalToConstant: 150)
                ])
            }
        
        
        
    @objc private func loginButtonTapped(){
        emailFeild.resignFirstResponder()
        passwordFeild.resignFirstResponder()
            guard let email = emailFeild.text, let password = passwordFeild.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
            }
            //MARK: Firebase Login
            print("Login Button Tapped")
        }
        func alertUserLoginError(){
            let alert = UIAlertController(title: "Opps", message: "Please enter Log in information correctly", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }

    extension LoginViewController: UITextFieldDelegate{
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == emailFeild{
                passwordFeild.becomeFirstResponder()
            }else if textField == passwordFeild{
                loginButtonTapped()
            }
            print("You cliked on return button")
            return true
        }
    }

