//
//  RegisterViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
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
        feild.placeholder = "Enter Your Emaill ..."
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
        feild.placeholder = "Your Password ..."
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
        
        view.backgroundColor = .yellow
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
//        containerView.addSubview(copyrightLable)
//        copyrightLable.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 55, height: 44)
        setupLoginConstraint()
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
    
    
    
}
