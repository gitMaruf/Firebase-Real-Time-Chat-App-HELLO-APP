//
//  PhotoViewerViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        return imageView
    }()
    private let url: URL
     init(url: URL) {
//        let url = URL(string: urlString)
        self.url = url
        //imageView.sd_setImage(with: url, completed: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        self.title = "Photo"
        self.navigationItem.largeTitleDisplayMode = .never
        imageView.sd_setImage(with: url, completed: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
}
