//
//  ChatViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/27/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import MessageKit

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var senderPhoto: String
}
let senderOne: Sender = Sender(senderId: "s1", displayName: "Salman Khan", senderPhoto: "")

let message: [Message] = [Message(sender: senderOne, messageId: "m1", sentDate: Date(), kind: .text("This is my first Message to you.")), Message(sender: senderOne, messageId: "m2", sentDate: Date(), kind: .text("This is my first Message to you. This is my first Message to you. This is my first Message to you. This is my first Message to you.")),]

class ChatViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        // Do any additional setup after loading the view.
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
    }
 
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        return senderOne
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}
