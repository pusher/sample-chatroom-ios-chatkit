//
//  MessagesAPI.swift
//  words
//
//  Created by Neo Ighodaro on 01/01/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import Alamofire
import MessageKit

class MessagesAPI: MessagesStoreProtocol {
    
    static var messages: [[String:Any]] = [
        [
            "id": 1234,
            "text": "Hello",
            "user": [
                "chatkit_id": "foobar",
                "name": "Neo Ighodaro"
            ]
        ]
    ]
    
    func fetchMessages(completionHandler: @escaping (Chatroom.Messages.Fetch.Response?, MessagesError?) -> Void) {
//        let response = Chatroom.Messages.Fetch.Response(data: type(of: self).messages)
//        completionHandler(response, nil)
    }
}
