//
//  RegisterViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import Foundation

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
        imageView.image = UIImage(named: "monto") //(systemName: "person")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.layer.borderWidth = 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    lazy var firstNameFeild: UITextField = {
        let feild = UITextField()
        feild.autocorrectionType = .no
        feild.autocapitalizationType = .none
        feild.returnKeyType = .continue
        feild.placeholder = "First Name ..."
        feild.textAlignment = .center
        feild.backgroundColor = .white
        feild.layer.cornerRadius = 12
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.black.cgColor
        return feild
    }()
    lazy var lastNameFeild: UITextField = {
        let feild = UITextField()
        feild.autocorrectionType = .no
        feild.autocapitalizationType = .none
        feild.returnKeyType = .continue
        feild.placeholder = "Last Name ..."
        feild.textAlignment = .center
        feild.backgroundColor = .white
        feild.layer.cornerRadius = 12
        feild.layer.borderWidth = 1
        feild.layer.borderColor = UIColor.black.cgColor
        return feild
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
    lazy var registerButton: UIButton = {
        let RegisterBtn = UIButton()
        RegisterBtn.setTitle("Register Now", for: .normal)
        RegisterBtn.backgroundColor = .red
        RegisterBtn.setTitleColor(.white, for: .normal)
        RegisterBtn.layer.cornerRadius = 12
        RegisterBtn.layer.masksToBounds = true
        RegisterBtn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return RegisterBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailFeild.delegate = self
        passwordFeild.delegate = self
        view.backgroundColor = .yellow
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
//        containerView.addSubview(copyrightLable)
//        copyrightLable.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 55, height: 44)
         
        setupRegisterConstraint()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    fileprivate func setupRegisterConstraint(){
             
            let formStackView: UIStackView = UIStackView(arrangedSubviews: [firstNameFeild, lastNameFeild, emailFeild, passwordFeild, registerButton])
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
            //imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            //imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            formStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            formStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            formStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            formStackView.heightAnchor.constraint(equalToConstant: 250)
            ])
        }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
//        print(tappedImage.frame.size.width)
        presentPhotoActionSheet()
        
    }

    
@objc private func registerButtonTapped(){
    firstNameFeild.resignFirstResponder(); lastNameFeild.resignFirstResponder(); emailFeild.resignFirstResponder(); passwordFeild.resignFirstResponder()
    guard let firstName = firstNameFeild.text, let lastName = lastNameFeild.text, let email = emailFeild.text, let password = passwordFeild.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserRegisterError()
            return
        }
        //MARK: Firebase Register
        print("Register Button Tapped")
    }
    func alertUserRegisterError(){
        let alert = UIAlertController(title: "Opps", message: "Please enter your information correctly", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameFeild{
            lastNameFeild.becomeFirstResponder()
        }else if textField == lastNameFeild{
            emailFeild.becomeFirstResponder()
        }else if textField == emailFeild{
            passwordFeild.becomeFirstResponder()
        }else if textField == passwordFeild{
            registerButtonTapped()
        }
        print("You cliked on return button")
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
       let alert = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let photoInfo = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return}
        imageView.image = photoInfo
        print("Selected Photo is: ", photoInfo)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image Picker Cancel")
    }
}
