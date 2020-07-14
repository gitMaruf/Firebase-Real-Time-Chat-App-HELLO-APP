//
//  ProfileViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

   lazy var imageView: UIImageView = {
       let imageView = UIImageView()
       imageView.image = UIImage(named: "logo")
       imageView.frame.size.height = 100
       imageView.contentMode = .scaleAspectFit
       return imageView
   }()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.frame = CGRect(x: view.center.x-100, y: view.center.y, width: 200, height: 100)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        print(tappedImage.frame.size.width)
        // Your action
    }

}
