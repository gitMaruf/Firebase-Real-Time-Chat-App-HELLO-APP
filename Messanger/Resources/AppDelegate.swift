//
//  AppDelegate.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
          
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
          
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      
      if let error = error {
        print("Google Sign In Failed -\(error)")
        return
      }
        print("Did sign in using google -\(String(describing: user))")
        guard let email = user.profile.email, let firstName = user.profile.givenName, let lastName = user.profile.familyName else{
            return
        }
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

        let chatAppUser = DatabaseManger.ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
        DatabaseManger.shared.userExist(with: email, completion: { exists in
            if !exists{
                DatabaseManger.shared.insertUser(with: chatAppUser, completion: { success in
                    if success{
                        if user.profile.hasImage{
                            guard let url = user.profile.imageURL(withDimension: 200) else {return}
                            URLSession.shared.dataTask(with: url, completionHandler:  { (data, _, error) in
                                // Upload Image
                                let fileName = chatAppUser.profilePictureURL
                                guard let data = data, error == nil else{
                                    print("URL Session data task Error: \(String(describing: error))")
                                    return
                                }
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: {result in
                                    switch(result){
                                    case .success(let downloadURL) :
                                        print("Upload Successfull: \(downloadURL)")
                                        UserDefaults.standard.set(downloadURL, forKey: "profilePictureURL")
                                    case .failure(let error):
                                        print("Storage Manager Error: \(error)")
                                    }
                                })
                                
                                }).resume() // URLSession dataTask begains from here
                            
                        }
                       
                        
                        
                    }
                })
            }
        })
      guard let authentication = user.authentication else {
        print("Missing Google Authentication")
        return        
        }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
        Firebase.Auth.auth().signIn(with: credential, completion:  { authResult, error in
            guard error == nil else {
                print("Sign in using google failed. -\(String(describing: error))")
                return
            }
            print("Gogle Log in Success")
            if Firebase.Auth.auth().currentUser != nil{
                print(Firebase.Auth.auth().currentUser?.displayName! as Any)
            }
            NotificationCenter.default.post(
            name: Notification.Name("SuccessfulSignInNotification"), object: nil, userInfo: nil)
            
            
        })
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
        print("Google user did diesconnected")
    }

}

    
