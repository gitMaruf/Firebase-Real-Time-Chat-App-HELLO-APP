//
//  ProfileViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let data = ["Sign Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign Out",style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nvc = UINavigationController(rootViewController: vc)
                nvc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                strongSelf.present(nvc, animated: true, completion: nil)
            }
            catch{
                print("Failed to logout")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert,animated: true)
    }
}
