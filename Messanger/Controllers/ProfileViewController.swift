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


final class ProfileViewController: UIViewController { // final class cant be inherited!

   
    @IBOutlet var tableView: UITableView!
//    let data = ["Sign Out"]
    var data = [ProfileView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(ProfileViewControllerCell.self, forCellReuseIdentifier: ProfileViewControllerCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
        guard let name = UserDefaults.standard.value(forKey: "name") as? String, let email = UserDefaults.standard.value(forKey: "email") as? String else{
           print("User Defaults Name is Nil")
            return
        }
        data.append(ProfileView(viewDataType: .info, title: name, handler: { [weak self] in
            let alert = UIAlertController(title: "", message: "Find more about yourself", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: email, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self?.present(alert, animated: true)
        }))
        
        data.append(ProfileView(viewDataType: .signout, title: "Sign out", handler: { [weak self] in
            guard let strongSelf = self else{ return }
            let alert = UIAlertController(title: "", message: "Sign Out from Hello Apps", preferredStyle: .actionSheet)
                   alert.addAction(UIAlertAction(title: "Sign Out",style: .destructive, handler: { [weak self] _ in
                       guard let strongSelf = self else {return}
                       //Facebook LogOut
                       FBSDKLoginKit.LoginManager().logOut()
                       //Google Logout
                       GIDSignIn.sharedInstance()?.signOut()
                       do{
                           
                           try FirebaseAuth.Auth.auth().signOut()
//                           UserDefaults.standard.removeObject(forKey: "email")
//                           UserDefaults.standard.removeObject(forKey: "name")
                        UserDefaults.standard.setValue(nil, forKey: "email")
                        UserDefaults.standard.setValue(nil, forKey: "name")
                           let vc = LoginViewController()
                           let nvc = UINavigationController(rootViewController: vc)
                           nvc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                           strongSelf.present(nvc, animated: true, completion: nil)
                       }
                       catch{
//                        print("Failed to logout")
                        fatalError("Failed to logout")
                       }
                   }))
                   alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            strongSelf.present(alert,animated: true)
        }))
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func createTableHeader() -> UIView?{
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
           print("User Defaults Name is Nil")
            return nil
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        let profilePicture = "\(safeEmail)_profile_picture.jpg";
        let path = "images/\(profilePicture)"
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
        headerView.backgroundColor = .secondarySystemFill
        let imageView = UIImageView(frame: CGRect(x: (view.frame.width-150)/2, y: 75, width: 150, height: 150))
        headerView.addSubview(imageView)
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        StorageManager.shared.downloadProfilePicture(with: path) { [weak self] (result) in
            switch(result){
            case .failure(let error):
                print("Failed to download URL:\(error)")
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
//                self?.downloadImage(imageView: imageView, url: url)
                print("Download URL is:", url)
            }
        }
        return headerView
    }
    func downloadImage(imageView: UIImageView, url: URL){
        //        URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
//            guard let data = data, error == nil else {
//                print("URLSession data task error \(String(describing: error))")
//                return
//            }
//            print("The Data is: ", data) // 4334 byte
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                imageView.image = image
//
//            }
//
//            }).resume()
    }
    
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileViewControllerCell.identifier, for: indexPath) as! ProfileViewControllerCell
        let model = data[indexPath.row]
//        cell.textLabel?.text = model.title
        cell.setUp(with: model)
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.textColor = .systemBlue
//        cell.textLabel?.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
    class ProfileViewControllerCell: UITableViewCell{
        static let identifier = "ProfileViewControllerCell"
        public func setUp(with viewDataType: ProfileView){
            self.textLabel?.text = viewDataType.title
            switch viewDataType.viewDataType{
            case .info:
                self.textLabel?.textColor = .systemBlue
                self.textLabel?.textAlignment = .left
            case .signout:
                self.textLabel?.textColor = .systemRed
                self.textLabel?.textAlignment = .center
            }
        }
    }
    
}



