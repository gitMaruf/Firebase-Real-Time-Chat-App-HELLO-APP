//
//  DatabaseManager.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/18/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DatabaseManger{
    
    static let shared = DatabaseManger()
    private var database = Database.database().reference()
    
   
//    public func test(){
//        database.child("uniqueId2").setValue(["Name":"Opu", "Age":29])
//    }
}
extension DatabaseManger{
    public func userExist(with email: String, completion: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshoot) in
            guard snapshoot.value as? String != nil else{
                completion(false)
                return
                
            }
            completion(true)
        }
    }
    
     public func insertUser(with user: ChatAppUser){
            database.child(user.safeEmail).setValue([
                "firstname": user.firstName,
                "lastname": user.lastName,
                //"emailaddress": user.safeEmail,
                //"password": user.password
            ])
        }
        public struct ChatAppUser{
             let firstName: String
             let lastName: String
             let emailAddress: String
             //let password: String
    //        let profilePictureURL: String
           
            var  safeEmail: String {
                var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
                safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
                return safeEmail
            }
        }
    
}
