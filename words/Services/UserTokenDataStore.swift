//
//  UserTokenDataStore.swift
//  words
//
//  Created by Neo Ighodaro on 27/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class UserTokenDataStore {
    static var DATA_KEY = "WORDS_API_TOKEN"
    
    func getToken() -> UserToken {
        if let token = UserDefaults.standard.object(forKey: type(of: self).DATA_KEY) as! Data? {
            return NSKeyedUnarchiver.unarchiveObject(with: token) as! UserToken
        }

        return UserToken(token_type: nil, access_token: nil, refresh_token: nil, expires_in: nil)
    }
    
    func setToken(_ token: UserToken) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: token)
        UserDefaults.standard.set(encodedData, forKey: type(of: self).DATA_KEY)
    }
}
