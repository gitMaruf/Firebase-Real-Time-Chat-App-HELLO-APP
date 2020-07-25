//
//  LoginViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

extension UIButton {

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
        super.touchesBegan(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        super.touchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false
        super.touchesCancelled(touches, with: event)
    }

}

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
    let loginBtn = UIButton(type: .system)
       loginBtn.setTitle("Login", for: .normal)
       loginBtn.backgroundColor = .red
       loginBtn.setTitleColor(.white, for: .normal)
       loginBtn.layer.cornerRadius = 12
       loginBtn.layer.masksToBounds = true
       loginBtn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
       return loginBtn
   }()
    let fbLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Facebook Login Button
//        let fbLoginButton = FBLoginButton()
//        fbLoginButton.center = view.center
//        view.addSubview(fbLoginButton)
        
        emailFeild.delegate = self
        passwordFeild.delegate = self
        fbLoginButton.delegate = self
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
                 
        fbLoginButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        let formStackView: UIStackView = UIStackView(arrangedSubviews: [emailFeild, passwordFeild, loginButton, fbLoginButton])
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
                formStackView.heightAnchor.constraint(equalToConstant: 200)
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
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            guard let result = authResult, error == nil else {
                return
            }
            let user = result.user
            print("Login Successful \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
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

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email"],tokenString: token, version: nil, httpMethod: .get)
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any], error == nil else{
                print("Failed to make facebook graphrequest -\(String(describing: error))")
                return
            }
            print("Graph Result: \(result)")
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
            let email = result["email"] as? String else {
                return
            }
            // If not exist insert into database and authentication
            DatabaseManger.shared.userExist(with: "email") { exists in
                if !exists{
                    DatabaseManger.shared.insertUser(with: DatabaseManger.ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else{
                    return
                }
                guard result != nil, error == nil else{
                    if let error = error {
                        print("Facebook credential log in failed, MFA may be needed -\(error)")
                    }
                    return
                }
                print("Facebook log in successfull!")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
            
        })
        
    }
    
//
//    func returnUserData()
//    {
//        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, friends, birthday, cover, devices, picture.type(large)"])
//
//        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
//        if ((error) != nil)
//        {
//              // Process error
//              print("Error: \(error)")
//        }
//        else
//        {
//              print(result)
//
//        }
//       })
//    }

    
}
