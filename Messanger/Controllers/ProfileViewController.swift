//
//  ProfileViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let data = ["Sign Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func createTableHeader() -> UIView?{
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
           print("User Defaults Email is Nil")
            return nil
        }
        print("User Defaults Email \(email)")
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let profilePicture = "\(safeEmail)_profile_picture.jpg";
        let path = "images/\(profilePicture)"
        print("Requested Path is: ", path)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (view.frame.width-150)/2, y: 75, width: 150, height: 150))
        headerView.addSubview(imageView)
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        StorageManager.shared.downloadProfilePicture(with: path) { [weak self] (result) in
            switch(result){
            case .failure(let error):
                print("Failed to download URL:\(error)")
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
                print("Download URL is:", url)
            }
        }
        return headerView
    }
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
            guard let data = data, error == nil else {
                print("URLSession data task error \(String(describing: error))")
                return
            }
            print("The Data is: ", data)
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
           
            }).resume()
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
        let alert = UIAlertController(title: "", message: "Sign Out from Hello Apps", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign Out",style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            //Facebook LogOut
            FBSDKLoginKit.LoginManager().logOut()
            //Google Logout
            GIDSignIn.sharedInstance()?.signOut()
            do{
                
                try FirebaseAuth.Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: "email")
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
