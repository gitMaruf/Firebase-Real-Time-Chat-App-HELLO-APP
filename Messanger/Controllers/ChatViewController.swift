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
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation
import MapKit

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
            return "video"
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
struct mediaItem: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
struct Location: LocationItem{
    var location: CLLocation
    var size: CGSize
}
class ChatViewController: MessagesViewController {
    
    public static let dateFormater: DateFormatter? = {
        let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .long
        dateformater.locale = Locale(identifier: "en_US")//.current
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
        messagesCollectionView.messageCellDelegate = self
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
        self.messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: true)
    }
    private func presentActionSheet(){
        let alert = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self]_ in
            self?.presentPhotoActionSheet()
        }))
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: {[weak self]_ in
            self?.presentVideoActionSheet()
        }))
        alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: {_ in
            
        }))
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: {_ in
            self.presentLocationPicker()
               }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    private func presentLocationPicker(){
        let vc = LocationViewController(coordinates: nil)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Pick Location"
        vc.completion = {[weak self] coordinates in
            let latitude: Double = coordinates.latitude
            let logitude: Double = coordinates.longitude
            print(" Latitide: \(latitude) | Logitude \(logitude)")
            let targetLocation = Location(location: CLLocation(latitude: latitude, longitude: logitude), size: .zero)
            
            guard let strongSelf = self, let selfSend = strongSelf.selfSender, let messageId = strongSelf.createMessageId(), let name = strongSelf.title, let conversationId = strongSelf.conversationId else{
                return
            }
            // Send Message
            let message: Message = Message(sender: selfSend, messageId: messageId, sentDate: Date(), kind: .location(targetLocation))
            
                DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessasge: message, completion: {success in
                    if success{
                        print("Location messagse sent")
                    }else{
                        print("Location message sending failed")
                    }
                })
                
            
            
        }
        navigationController?.pushViewController(vc, animated: true)
        
        


        
        
    }
    private func listenForMessage(id: String, shouldScrolToBottom: Bool){
        DatabaseManger.shared.getAllMessageForConversation(with: id, completion: {[weak self] result in
            switch result{
            case .success(let message):
//                guard !message.isEmpty else{
//                    return
//                }
//                print("Fetched Message is: \(message)")
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
//        print("message[indexPath.section]: ", message[indexPath.section])
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("Message Count: \(message.count)")
        return message.count
    }
    
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let alert = UIAlertController(title: "Add Photo", message: "How would you like to select a picture", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    func presentPhotoCamera(){
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
    func presentVideoActionSheet(){
        let alert = UIAlertController(title: "Add Video", message: "How would you like to select a video from?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Shoot a Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { [weak self] _ in
            self?.presentVideoPicker()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func presentVideoCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.mediaTypes = ["public.movie"]
        vc.videoQuality = .typeMedium
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentVideoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.mediaTypes = ["public.movie"]
        vc.videoQuality = .typeLow
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
            let conversationId = conversationId,
            let name = self.title else {
                return
        }
        if let photoInfo = info[.editedImage] as? UIImage, let data = photoInfo.pngData(){
            //imageView.image = photoInfo
                   print("Selected Photo is: ", photoInfo)
                   let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
                   StorageManager.shared.uploadMessagePhoto(with: data, fileName: fileName, completion: {[weak self] result in
                       guard let strongSelf = self, let selfSender = strongSelf.selfSender else{return}
                       switch result{
                       case .failure(let error):
                           print("Message photo inser error: \(error)")
                       case .success(let urlString):
                           // now upload url string to database and change kind to .photo
                           print(" Url String is: \(urlString)")
                           let url = URL(string: urlString)
                           let currentMediaItem = mediaItem(url: url, image: nil, placeholderImage: UIImage(systemName: "photo")!, size: .zero)
                           let message: Message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(currentMediaItem))
                           DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessasge: message, completion: {success in
                               if success{
                                   print("Photo Message Sent")
                               }else{
                                   print("Photo Message send failed")
                               }
                           })
                       }
                   })
        }else if let videoUrl = info[.mediaURL] as? URL{
            //imageView.image = photoInfo
                   print("Selected Video Url is: ", videoUrl)
                   let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
                   StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: {[weak self] result in
                       guard let strongSelf = self, let selfSender = strongSelf.selfSender else{ return}
                       switch result{
                       case .failure(let error):
                           print("Message Video inser error: \(error)")
                       case .success(let urlString):
                           // now upload url string to database and change kind to .photo
                           print("Video Url String is: \(urlString)")
                           let url = URL(string: urlString)
                           let currentMediaItem = mediaItem(url: url, image: nil, placeholderImage: UIImage(systemName: "play")!, size: .zero)
                           let message: Message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(currentMediaItem))
                           DatabaseManger.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessasge: message, completion: {success in
                               if success{
                                   print("Video Message Sent")
                               }else{
                                   print("Video Message send failed")
                               }
                           })
                       }
                   })
            
        }
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image Picker Cancel")
    }
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else{
            return
        }
        switch message.kind{
        case .photo(let media):
            guard let url = media.url else{ return }
            imageView.sd_setImage(with: url, completed: nil)
        case .video(let media):
            guard let url = media.url else{ return }
            imageView.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
}
extension ChatViewController: MessageCellDelegate{
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        //        print("i am here\(cell.hashValue)")
        guard let indexpath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = self.message[indexpath.section]
        switch message.kind{
        case .location(let fetchLocationData):
            let coordinate = fetchLocationData.location.coordinate
            let vc = LocationViewController(coordinates: coordinate)
            vc.title = "Location"
                self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexpath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = self.message[indexpath.section]
        
        switch message.kind{
        case .photo(let media):
            guard let url = media.url else{ return }
            print(url)
            let vc = PhotoViewerViewController(url: url)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else{ return }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
}
