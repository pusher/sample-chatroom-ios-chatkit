//
//  TokenDataStore.swift
//  words
//
//  Created by Neo Ighodaro on 22/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class TokenDataStore: NSObject
{
    private var token: [String : Any?] {
        get {
            if let token = UserDefaults.standard.object(forKey: "words_jwt") as! [String: Any?]? {
                return token
            }
            
            return [:]
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "words_jwt")
        }
    }
    
    func getToken() -> [String : Any?] {
        return self.token
    }
    
    func setToken(_ newValue: [String : Any?]) {
        self.token = newValue
    }
}
