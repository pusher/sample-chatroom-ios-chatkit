//
//  MessagesWorker.swift
//  words
//
//  Created by Neo Ighodaro on 24/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class MessagesWorker {

    var messagesStore: MessagesStoreProtocol
    
    init(messagesStore: MessagesStoreProtocol) {
        self.messagesStore = messagesStore
    }
    
    func fetchMessages(completionHandler: @escaping ([Message]) -> Void) {
        messagesStore.fetchMessages { messages in
            DispatchQueue.main.async {
                completionHandler(messages)
            }
        }
    }
}

// MARK: Store API

protocol MessagesStoreProtocol
{
    func fetchMessages(completionHandler: @escaping ([Message]) -> Void)
}
