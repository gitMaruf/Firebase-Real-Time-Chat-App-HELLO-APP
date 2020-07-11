//
//  RegisterViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

     private let scrollView: UIScrollView = {
           let scrollView = UIScrollView()
           scrollView.clipsToBounds = true
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
           
           view.backgroundColor = .yellow
           view.addSubview(scrollView)
           scrollView.addSubview(imageView)
           scrollView.addSubview(emailFeild)
           scrollView.addSubview(passwordFeild)
           scrollView.addSubview(loginButton)
       }
       

       override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        setupLoginConstraint()
           let size = scrollView.frame.size.width
           imageView.frame = CGRect(x: size/4, y: size/4, width: size/2, height: size/4)
           emailFeild.frame = CGRect(x: size/4, y: size/4+imageView.frame.size.height + 50, width: size/2, height: 44)
           passwordFeild.frame = CGRect(x: size/4, y: size/4+imageView.frame.size.height + 120, width: size/2, height: 44)
           loginButton.frame = CGRect(x: size/3, y: size/4+imageView.frame.size.height + 190, width: size/3, height: 44)
       }
    
    fileprivate func setupLoginConstraint(){
        
    }

}
