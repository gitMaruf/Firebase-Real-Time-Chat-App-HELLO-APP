//
//  ConversationModel.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/26/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation


public struct Conversation{
    let id: String
    let name: String
    let otherEmail: String
    let latestMessasge: LatestMessasge
}
public struct LatestMessasge {
    let text: String
    let date: String
    let isRead: Bool
}
