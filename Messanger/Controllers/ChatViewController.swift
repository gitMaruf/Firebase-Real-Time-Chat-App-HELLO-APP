//
//  ChatViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/27/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import Foundation
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var senderPhoto: String
}
extension MessageKind{
    var messageKindString: String{
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed Text"
        case .photo(_):
            return "photo"
        case .video(_):
            return " video"
        case .location(_):
            return "location"
        case .emoji(_):
            return " emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {

    public static let dateFormater: DateFormatter? = {
       let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .long
        dateformater.locale = .current
        return dateformater
    }()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
        let name = UserDefaults.standard.value(forKey: "name") as? String else{
            return nil
        }
        let safeEmailCurrentUser = DatabaseManger.safeEmail(emailAddress: email)
//        print("User Default Name: \(name) and emain: \(email)")
        return Sender(senderId: safeEmailCurrentUser, displayName: name, senderPhoto: "")
    }

//        var message: [Message] = []
          var message = [Message]()
    
    //let message: [Message] = [Message(sender: senderOne, messageId: "m1", sentDate: Date(), kind: .text("This is my first Message to you.")), Message(sender: senderOne, messageId: "m2", sentDate: Date(), kind: .text("This is my first Message to you. This is my first Message to you. This is my first Message to you. This is my first Message to you.")),]
    
    public var isNewConverstion = false
    public let otherUserEmail: String
    private let conversationId: String?

    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        if let conversationId = conversationId{
            listenForMessage(id: conversationId, shouldScrolToBottom: true)
               }
    }
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: true)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside{_ in
            self.presentActionSheet()
        }
        print("button is working!")
        self.messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
    }
    private func presentActionSheet(){
        let alert = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self]_ in
            self?.presentPhotoActionSheet()
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: {_ in
            
        }))
        alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: {_ in
            
        }))
        alert.addAction(UIAlertAction(title: "Calcel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func listenForMessage(id: String, shouldScrolToBottom: Bool){
        DatabaseManger.shared.getAllMessageForConversation(with: id, completion: {[weak self] result in
            switch result{
            case .success(let message):
                guard !message.isEmpty else{
                    return
                }
                self?.message = message
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrolToBottom{
                        self?.messagesCollectionView.scrollToLastItem() //scrollToBottom()
                    }
                }
            case .failure(let error):
                print("Get all message for conversation is failed: \(error)")
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.becomeFirstResponder()
        //messageInputBar.blurView.effect = UIBlurEffect(style: .dark)
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSend = self.selfSender, let messageId = createMessageId() else{
            return
        }
        print("Sending: \(text)")
        // Send Message
         let message: Message = Message(sender: selfSend, messageId: messageId, sentDate: Date(), kind: .text(text))
        if isNewConverstion{
            print("Create Conversation in DB")
           
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessagse: message, completion: {[weak self] success in
                if success{
                    print("New conversation created")
                    self?.isNewConverstion = false
                }else{
                    print("New Conversation Creation Failed")
                }
            })
            
        }else{
            print("Append to existance DB")
            guard let conversationId = conversationId, let name = self.title else{
                return
            }
           
            DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessasge: message, completion: {success in
                if success{
                    print("messagse sent")
                }else{
                    print("Message send failed")
                }
            })
            
        }
        
    }
    
    
    private func createMessageId() -> String? {
        
        
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, let  dateString = Self.dateFormater?.string(from: Date()) else{
            return nil
        }
        let safeCurrentUserEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentUserEmail)_\(dateString)"
        return newIdentifier
    }
    
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let alert = UIAlertController(title: "Add Photo", message: "How would you like to select a picture", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let photoInfo = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return}
        //imageView.image = photoInfo
        print("Selected Photo is: ", photoInfo)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image Picker Cancel")
    }
}
