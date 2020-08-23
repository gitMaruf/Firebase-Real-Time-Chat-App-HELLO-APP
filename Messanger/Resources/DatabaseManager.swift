//
//  DatabaseManager.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/18/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MessageKit

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
        
        
        let safeEmail = DatabaseManger.safeEmail(emailAddress: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshoot in
            print("safeEmail: \(safeEmail), snapshoot.value \(String(describing: snapshoot.value)) Snapsho eists: \(snapshoot.exists())")
//            guard snapshoot.value as? [String: Any] !=nil else{ return }
            guard snapshoot.exists() else{
                completion(false)
                print("user not exist,  com: false") 
                return
            }
            print("User already exist, com: true")
            completion(true)
        })
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
                    completion(.failure(DatabaseError.FailedToFetch))
                    return
                }
                completion(.success(users))
        })
    }
    private enum DatabaseError: Error{
        case FailedToFetch
        case CastingError
        case NothingFound
    }
}

extension DatabaseManger{
    public func getUser(with path: String, completion: @escaping (Result<Any, Error>) ->Void ){
        self.database.child(path).observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

extension DatabaseManger{
    /// Create new messagse with target email and first conversation
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessagse: Message, completion: @escaping (Bool) -> Void){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else{
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: {[weak self] snapshot in
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
            let recipent_conversationData: [String : Any] = [
                "id": convId,
                "other_user_email": safeEmail,
                "name": currentUserName,
                "lates_message": [
                    "date": dateString!,
                    "message": messageMedia,
                    "is_read": false
                ]
            ]
            // Update recipent user conversation
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]]{
                    //appent
                    conversations.append(recipent_conversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else{
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipent_conversationData])
                }
                
            })
            // Update current user conversation entry
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
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherEmail = dictionary["other_user_email"] as? String,
                    let latestMessasge = dictionary["lates_message"] as? [String: Any],
                    let text = latestMessasge["message"] as? String,
                    let date = latestMessasge["date"] as? String,
                    let isRead = latestMessasge["is_read"] as? Bool else{
                        completion(.failure(DatabaseError.CastingError))
                        print("Conversation array conpact map failed")
                        return nil
                }
                let latestMessageObject = LatestMessasge(text: text, date: date, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherEmail: otherEmail, latestMessasge: latestMessageObject)
            })
            completion(.success(conversations))
            
        })
    }
    /// Get all conversation 
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        
        
        database.child("\(id)/message").observe(.value, with: { snapshot in
            //print("The Message id is: \(id)/message and snapshot is \(String(describing: snapshot.value))")
            
            if snapshot.hasChildren() {
                guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            print("The value is", value)
//            value = [[
//                      "date": "Aug 20, 2020 at 11:27:01 AM GMT+6",
//                      "content": "Emoji",
//                      "sender_email": "maruf-dhaka2010-gmail-com",
//                "name": "Home Made",
//                "id": "resina-akter2004-gmail-com_maruf-dhaka2010-gmail-com_Aug 20, 2020 at 5:08:23 PM GMT+6",
//                "is_read": 0,
//                "type": "text"
//                ]]
            
            let message: [Message] = value.compactMap({dictionary in
                
                guard let messageId = dictionary["id"] as? String,
                    let type = dictionary["type"] as? String,
                    let content = dictionary["content"] as? String,
                    let date = dictionary["date"] as? String,
                    let sender_email = dictionary["sender_email"] as? String,
                    let name = dictionary["name"] as? String,
                    //let is_read = dictionary["is_read"] as? Bool,
                    let dateString = ChatViewController.dateFormater?.date(from: date)
                    else{
                        print("Message array conpact map failed")
                        completion(.failure(DatabaseError.CastingError))
                        return nil
                }
                let sender = Sender(senderId: sender_email, displayName: name, senderPhoto: "")
                var kind: MessageKind?
                if type == "photo"{
                    guard let url = URL(string: content) else{return nil}

                let media = mediaItem(url: url, image: nil, placeholderImage: UIImage(systemName: "photo")!, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }else if type == "video"{
                    guard let url = URL(string: content) else{return nil}
                let media = mediaItem(url: url, image: nil, placeholderImage: UIImage(systemName: "play")!, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }else{
                    kind = .text(content)
//                    print("the text message is \(content)")
                }
                guard let finalKind = kind else{ return nil}
                return Message(sender: sender, messageId: messageId, sentDate: dateString, kind: finalKind)
            })
            completion(.success(message))   
            }
        })
        
    }
    /// Send a message with targer conversation and message
    public func sendMessage(to conversationId: String, otherUserEmail: String, name: String, newMessasge: Message, completion: @escaping (Bool) -> Void){
        // update new messasge to message
        // update sender latest message
        // update recipent latest messagse
        database.child("\(conversationId)/message").observeSingleEvent(of: .value, with: {[weak self] snapshot in
            guard var currentMessage = snapshot.value as? [[String: Any]], let strongSelf = self else{
                completion(false)
                return
            }
            
            
            let messageDate = newMessasge.sentDate
            let dateString = ChatViewController.dateFormater?.string(from: messageDate)
            guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else{
                return
            }
            let safeCurrentUserEmail = DatabaseManger.safeEmail(emailAddress: currentUser)
            var messageMedia = ""
            switch newMessasge.kind{
            case .text(let messageText):
                messageMedia = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetString = mediaItem.url?.absoluteString{
                    messageMedia = targetString
                }
            case .video(let mediaItem):
                if let targetString = mediaItem.url?.absoluteString{
                    messageMedia = targetString
                }
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
            
            let newMessasge: [String: Any] = [
                "id": newMessasge.messageId,
                "type": newMessasge.kind.messageKindString,
                "content": messageMedia,
                "date": dateString!,
                "sender_email": safeCurrentUserEmail,
                "name": name,
                "is_read": false
            ]
            
            //                let value: [String: Any] = [
            //                    "message": [newMessasge]
            //                ]
            
            currentMessage.append(newMessasge)
            strongSelf.database.child("\(conversationId)/message").setValue(currentMessage, withCompletionBlock: {error,_ in
                guard error == nil else{
                    print("New message set value error: \(String(describing: error))")
                    completion(false)
                    return
                }
                print("Create new message into messasge is success")
                
                // Update latest message for sender
                strongSelf.database.child(("\(safeCurrentUserEmail)/conversations")).observeSingleEvent(of: .value, with: {snapshot in
                    var databaseEntryConversation = [[String: Any]]()
                    let updateMessageValue: [String: Any] = [
                                               "date": dateString!,
                                               "is_read": false,
                                               "message": messageMedia
                                           ]
                    if var currentUserConversation = snapshot.value as? [[String: Any]] {
                        // we created new entry
                        
                       
                        var position = 0
                        var targetConversation: [String: Any]?
                        for item in currentUserConversation{
                            if let targetId = item["id"] as? String, targetId == conversationId{
                                //item["lates_message"] = updateMessageValue
                                targetConversation = item
                                break
                            }
                            position += 1
                        }
                        if var targetConversation = targetConversation{
                            targetConversation["lates_message"] = updateMessageValue
                            currentUserConversation[position] = targetConversation
                            databaseEntryConversation = currentUserConversation
                        }else{
                                            let conversationData: [String : Any] = [
                                                "id": conversationId,
                                                "other_user_email": DatabaseManger.safeEmail(emailAddress: otherUserEmail),
                                                "name": name,
                                                "lates_message": updateMessageValue
                                            ]
                            currentUserConversation.append(conversationData)
                            databaseEntryConversation = currentUserConversation

                    }
//                        completion(false)
//                        return
                    }else{
                        
                        let conversationData: [String : Any] = [
                            "id": conversationId,
                            "other_user_email": DatabaseManger.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "lates_message": updateMessageValue
                        ]
                        
                        databaseEntryConversation = [
                        conversationData
                        ]
                    }
                    
                    
                    
                    strongSelf.database.child(("\(safeCurrentUserEmail)/conversations")).setValue(databaseEntryConversation, withCompletionBlock: {error,_ in
                        guard error == nil else{
                            print("Failed conversation for current user: \(String(describing: error))")
                            completion(false)
                            return
                        }
                        print("Insert conversation for current user")

                        // Update latest message for receiving
                        strongSelf.database.child(("\(otherUserEmail)/conversations")).observeSingleEvent(of: .value, with: {snapshot in
                            guard var otherUserConversation = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                return
                            }
                            var position = 0
                            var targetConversation: [String: Any]?
                            for item in otherUserConversation{
                                if let targetId = item["id"] as? String, targetId == conversationId{
                                    //item["lates_message"] = updateMessageValue
                                    targetConversation = item
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["lates_message"] = updateMessageValue
                            guard let finalLatestMessage = targetConversation else{
                                completion(false)
                                return
                            }
                            otherUserConversation[position] = finalLatestMessage
                            strongSelf.database.child(("\(otherUserEmail)/conversations")).setValue(otherUserConversation, withCompletionBlock: {error,_ in
                                guard error == nil else{
                                    print("Failed conversation for other user: \(String(describing: error))")
                                    completion(false)
                                    return
                                }
                                print("Insert conversation for other user")
                                completion(true)
                            })
                        })
                        
                        

                        completion(true)
                    })
                })
                
                completion(true)
            })
            
            
            
        })
    }
    
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void){
           guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
               return
           }
           let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
           let ref = database.child("\(safeEmail)/conversations")
            print("Preparate for delete conversation for \(conversationId)")
           ref.observeSingleEvent(of: .value, with: {snapshot in
               guard var conversations = snapshot.value as? [[String: Any]] else{
                   print("User not found, may fetch error")
                   completion(false)
                   return
               }
            
            var positionToRemove = 0
            for conversation in conversations{
                if let id = conversation["id"] as? String, id == conversationId{
                    print("May position  \(positionToRemove) found to remove")
                    break
                }
                positionToRemove += 1
            }
            conversations.remove(at: positionToRemove)
            
            ref.setValue(conversations, withCompletionBlock: { error,_ in
                guard error == nil else{
                    completion(false)
                    print("Conversation deleting failed \(String(describing: error))")
                    return
                }
                print("Conversation successfully deleted")
                completion(true)
            })
            
                
            
        })
    }
    
    public func conversationExist(with otherUserEmail: String, completion: @escaping (Result<String, Error>) ->Void ){
        let safeOtherUserEmail = DatabaseManger.safeEmail(emailAddress: otherUserEmail)
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeCurrentUserEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value, with: {snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.FailedToFetch))
                return
            }
            if let existantConversation = collection.first(where: {
                guard let targetSendEmail = $0["other_user_email"] as? String else{
                    return false
                }
                return safeCurrentUserEmail == targetSendEmail
            }){
                guard let conversationId = existantConversation["id"] as? String else{
                    completion(.failure(DatabaseError.CastingError))
                    return
                }
                completion(.success(conversationId))
                return
            }
            completion(.failure(DatabaseError.NothingFound))
            return
        })
    
    }
    
    
}
