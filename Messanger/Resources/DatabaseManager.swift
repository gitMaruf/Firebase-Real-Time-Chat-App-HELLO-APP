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
    
    public func insertUser(with user: ChatAppUser){
        database.child(user.emailAddress).setValue([
            "firstname": user.firstName,
            "lastname": user.lastName,
            "emailaddress": user.emailAddress,
            "password": user.password
        ])
    }
    public struct ChatAppUser{
         let firstName: String
         let lastName: String
         let emailAddress: String
         let password: String
//        let profilePictureURL: String
    }
//    public func test(){
//        database.child("uniqueId2").setValue(["Name":"Opu", "Age":29])
//    }
}
extension DatabaseManger{
    public func userExist(with email: String, completion: @escaping ((Bool) -> Void)){
        database.child(email).observeSingleEvent(of: .value) { (snapshoot) in
            guard snapshoot.value as? String != nil else{
                completion(false)
                return
                
            }
            completion(true)
        }
    }
}
