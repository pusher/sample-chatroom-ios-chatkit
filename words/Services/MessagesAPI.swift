//
//  MessagesAPI.swift
//  words
//
//  Created by Neo Ighodaro on 24/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class MessageAPI: MessagesStoreProtocol {
    
    static var messages = [
        Message(id: 1, room_id: "John Doe", message: "This is sample message that is very long so we can know if it will be cut off", created_at: Date()),
        Message(id: 2, room_id: "Jane Doe", message: "Sample message 2", created_at: Date()),
        Message(id: 3, room_id: "Sample Message", message: "Sample message 3", created_at: Date()),
    ]
    
    func fetchMessages(completionHandler: @escaping ([Message]) -> Void) {
        completionHandler(type(of: self).messages)
    }
}
