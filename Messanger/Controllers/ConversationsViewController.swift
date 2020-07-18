//
//  ViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        //DatabaseManger.shared.test()
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let isLoginStatus = UserDefaults.standard.bool(forKey: "isLogin")
        validateAuth()
        print("viewDidAppear")
    }
    private func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(nvc, animated: true, completion: nil)
        }
        
    }

}

