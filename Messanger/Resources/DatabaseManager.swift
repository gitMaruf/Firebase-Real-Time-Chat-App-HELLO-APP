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
    
    static func safeEmail(emailAddress: String)->String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
            database.child(user.safeEmail).setValue([
                "firstname": user.firstName,
                "lastname": user.lastName,
                //"emailaddress": user.safeEmail,
                //"password": user.password
                ],withCompletionBlock: {error,_ in
                    guard error == nil else{
                        print("Failed to write on database \(String(describing: error))")
                        completion(false)
                        return
                    }
                    self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                        if var usersCollection = snapshot.value as? [[String: String]]{
                         let newUser = [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                            ]
                            usersCollection.append(newUser)
                            self.database.child("users").setValue(usersCollection, withCompletionBlock: { error,_ in
                                guard error == nil else{
                                    print("Users Collection Error \(String(describing: error))")
                                    return
                                }
                                completion(true)

                            })
                        }else{
                            
                            let newCollection: [[String: String]] = [
                                [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                            ]
                            ]
                            self.database.child("users").setValue(newCollection, withCompletionBlock: { error,_ in
                                guard error == nil else{
                                    print("New User Collection Error \(String(describing: error))")
                                    return
                                }
                                completion(true)
                        })
                        }
                    })
                    //completion(true)
            })
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
            var profilePictureURL: String{
                return "\(safeEmail)_profile_picture.jpg"
            }
        }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>)->Void){
        database.child("users").observeSingleEvent(of: .value
            , with: {snapshot in
                guard let users = snapshot.value as? [[String: String]] else{
                    completion(.failure(DatabaseError.FetchToFetch))
                    return
                }
                completion(.success(users))
        })
    }
    private enum DatabaseError: Error{
        case FetchToFetch
    }
}
