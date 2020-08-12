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
extension DatabaseManger{
    /// Create new messagse with target email and first conversation
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessagse: Message, completion: @escaping (Bool) -> Void){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: {snapshot in
            guard var userNode = snapshot.value as? [String: Any?] else{
                print("User not found")
                completion(false)
                return
            }
            completion(true)
            print(userNode)
            let messageDate = firstMessagse.sentDate
            let dateString = ChatViewController.dateFormater?.string(from: messageDate)
            var messageMedia = ""
            switch firstMessagse.kind{
            case .text(let messageText):
                messageMedia = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
//            @unknown default:
//                break
            }
            
            let convId = "coversations_\(firstMessagse.messageId)"
            let conversationData: [String : Any] = [
                "id": convId,
                               "other_user_email": otherUserEmail,
                               "name": name,
                               "lates_message": [
                                "date": dateString!,
                                   "message": messageMedia,
                                   "is_read": false
                               ]
                               ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                // coversation array exit for current user
                // you should append
                conversations.append(conversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                                   guard error == nil else{
                                       completion(false)
                                       print("create new conversation failed")
                                       return
                                   }
                    self?.finishingCoversation(conversationId: convId, name: name, firstMessagse: firstMessagse, completion: completion)
                                   //completion(true)
                               })
            }else{
                // coversation does not exist
                //create new conversation
                userNode["conversations"] = [
                conversationData
                ]
                ref.setValue(userNode, withCompletionBlock: {[weak self]error, _ in
                    guard error == nil else{
                        completion(false)
                        print("create new conversation failed")
                        return
                    }
                    self?.finishingCoversation(conversationId: convId, name: name, firstMessagse: firstMessagse, completion: completion)
                    //completion(true)
                })
            }
//            self.inserIntoMessage(messageId: convId, messageContent: message, completion: { success in
//                if success{
//                    print("messasge insert success")
//                }else{
//                    print("message insert failed")
//                }
//            })
        })
        
    }
    private func finishingCoversation(conversationId: String, name: String, firstMessagse: Message, completion: @escaping (Bool) -> Void){
        
        let messageDate = firstMessagse.sentDate
        let dateString = ChatViewController.dateFormater?.string(from: messageDate)
        guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeCurrentUserEmail = DatabaseManger.safeEmail(emailAddress: currentUser)
                    var messageMedia = ""
                    switch firstMessagse.kind{
                    case .text(let messageText):
                        messageMedia = messageText
                    case .attributedText(_):
                        break
                    case .photo(_):
                        break
                    case .video(_):
                        break
                    case .location(_):
                        break
                    case .emoji(_):
                        break
                    case .audio(_):
                        break
                    case .contact(_):
                        break
                    case .custom(_):
                        break
        //            @unknown default:
        //                break
                    }
        
        let collectionOfMessage: [String: Any] = [
            "id": firstMessagse.messageId,
            "type": firstMessagse.kind.messageKindString,
            "content": messageMedia,
            "date": dateString!,
            "sender_email": safeCurrentUserEmail,
            "name": name,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "message": [collectionOfMessage]
        ]
        database.child("\(conversationId)").setValue(value, withCompletionBlock: {error,_ in
            guard error == nil else{
                               print("Messasge set value error: \(String(describing: error))")
                               completion(false)
                               return
                           }
                           print("insert in Messasge success")
                           completion(true)
        })
    }
    
    
    /// Fetch and return all conversation for the user with passed in email
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        
    }
    /// Get all conversation 
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    /// Send a message with targer conversation and message
    public func sendMessage(to conversation: String, completion: @escaping (Bool) -> Void){
        
    }
}
