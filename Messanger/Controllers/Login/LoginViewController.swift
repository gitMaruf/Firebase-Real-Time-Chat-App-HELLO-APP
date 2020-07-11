//
//  LoginViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

//    private let contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 400)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
//        scrollView.contentSize = contentViewSize
        scrollView.clipsToBounds = false
//        scrollView.bounces = true
        scrollView.backgroundColor = .purple
        return scrollView
    }()
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let emailFeild: UITextField = {
       let feild = UITextField()
        feild.autocorrectionType = .no
        feild.autocapitalizationType = .none
        feild.returnKeyType = .continue
        feild.placeholder = "Enter Your Emaill ..."
        feild.textAlignment = .center
        feild.backgroundColor = .white
        feild.layer.cornerRadius = 12
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.black.cgColor
        return feild
    }()
    private let passwordFeild: UITextField = {
       let feild = UITextField()
        feild.autocorrectionType = .no
        feild.autocapitalizationType = .none
        feild.returnKeyType = .done
        feild.placeholder = "Your Password ..."
        feild.isSecureTextEntry = true
        feild.backgroundColor = .white
        feild.textAlignment = .center
        feild.layer.cornerRadius = 12
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.black.cgColor
        return feild
    }()
    private let loginButton: UIButton = {
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
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Register", style: .plain, target: self, action: #selector(didTabRegister))
        view.backgroundColor = .yellow
        
        view.addSubview(scrollView)
        scrollView.frame = view.bounds ;
        setupLoginConstraint()
    }
    @objc func didTabRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        vc.view.backgroundColor = .orange
        //let nvc = UINavigationController(rootViewController: vc)
        //present(nvc, animated: true, completion: nil)
        //navigationController?.show(vc, sender: self)
        navigationController?.pushViewController(vc, animated: true)
    }

//    override func viewDidLayoutSubviews() {
 //       super.viewDidLayoutSubviews()
        
//        let size = scrollView.frame.size.width
//        scrollView.backgroundColor = .purple
//        imageView.frame = CGRect(x: size/4, y: size/4, width: size/2, height: size/4)
//        emailFeild.frame = CGRect(x: size/4, y: size/4+imageView.frame.size.height + 50, width: size/2, height: 44)
//        passwordFeild.frame = CGRect(x: size/4, y: size/4+imageView.frame.size.height + 120, width: size/2, height: 44)
//        loginButton.frame = CGRect(x: size/3, y: size/4+imageView.frame.size.height + 190, width: size/3, height: 44)

//    }
    fileprivate func setupLoginConstraint(){
         //view.bounds
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        emailFeild.translatesAutoresizingMaskIntoConstraints = false
//        passwordFeild.translatesAutoresizingMaskIntoConstraints = false
//        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let formStackView: UIStackView = UIStackView(arrangedSubviews: [emailFeild, passwordFeild, loginButton])
        formStackView.distribution = .fillEqually
        formStackView.spacing = 15
        formStackView.axis = .vertical
        formStackView.backgroundColor = .cyan
       
        imageView.translatesAutoresizingMaskIntoConstraints = false
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(imageView)
        scrollView.addSubview(formStackView)
        

        NSLayoutConstraint.activate([
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        imageView.heightAnchor.constraint(equalToConstant: 100),
        
        formStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 60),
        formStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
        formStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
        formStackView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
   
 

    
}
