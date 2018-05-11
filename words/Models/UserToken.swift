//
//  UserToken.swift
//  words
//
//  Created by Neo Ighodaro on 06/01/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import Foundation

class UserToken: NSObject, NSCoding {
    
    var token_type: String?
    var expires_in: Int?
    var access_token: String?
    
    init(token_type: String?, access_token: String?, expires_in: Int?) {
        self.expires_in = expires_in
        self.token_type = token_type
        self.access_token = access_token
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token_type, forKey: "token_type")
        aCoder.encode(expires_in, forKey: "expires_in")
        aCoder.encode(access_token, forKey: "access_token")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let expires = aDecoder.decodeObject(forKey: "expires_in") as! Int
        let tokenType = aDecoder.decodeObject(forKey: "token_type") as! String
        let accessToken = aDecoder.decodeObject(forKey: "access_token") as! String
        
        self.init(token_type: tokenType, access_token: accessToken, expires_in: expires)
    }
}
