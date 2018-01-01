//
//  MessagesWorker.swift
//  words
//
//  Created by Neo Ighodaro on 01/01/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import MessageKit

class MessagesWorker {

    var messagesStore: MessagesStoreProtocol

    init(messagesStore: MessagesStoreProtocol) {
        self.messagesStore = messagesStore
    }
    
    func fetchMessages(completionHandler: @escaping (Chatroom.Messages.Fetch.Response?, MessagesError?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.messagesStore.fetchMessages { (response, error) in
                DispatchQueue.main.async {
                    completionHandler(response, error)
                }
            }
        }
    }
}

// MARK: Messages API

protocol MessagesStoreProtocol {
    func fetchMessages(completionHandler: @escaping (Chatroom.Messages.Fetch.Response?, MessagesError?) -> Void)
}


// MARK: Messages Error

enum MessagesError: Error {
    case CannotFetch(String)
}
