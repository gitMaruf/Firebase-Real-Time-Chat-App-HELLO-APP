//
//  ChatViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/27/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
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
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmailCurrentUser = DatabaseManger.safeEmail(emailAddress: email)
        return Sender(senderId: safeEmailCurrentUser, displayName: "Me", senderPhoto: "")
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
        if let conversationId = conversationId{
            listenForMessage(id: conversationId, shouldScrolToBottom: true)
               }
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
        if isNewConverstion{
            print("Create Conversation in DB")
            let message: Message = Message(sender: selfSend, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessagse: message, completion: {success in
                if success{
                    print("New conversation created")
                }else{
                    print("New Conversation Creation Failed")
                }
            })
            
        }else{
            print("Append to existance DB")
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
