//
//  ChatModel.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/26/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

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
