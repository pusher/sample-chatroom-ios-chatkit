//
//  Token.swift
//  words
//
//  Created by Neo Ighodaro on 25/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class UserToken: NSObject, NSCoding
{
    var token_type: String?
    var expires_in: Int?
    var access_token: String?
    var refresh_token: String?
    
    init(token_type: String?, access_token: String?, refresh_token: String?, expires_in: Int?) {
        self.token_type = token_type
        self.access_token = access_token
        self.refresh_token = refresh_token
        self.expires_in = expires_in
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(expires_in, forKey: "expires_in")
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(refresh_token, forKey: "refresh_token")
        aCoder.encode(token_type, forKey: "token_type")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let expires_in = aDecoder.decodeObject(forKey: "expires_in") as! Int
        let token_type = aDecoder.decodeObject(forKey: "token_type") as! String
        let access_token = aDecoder.decodeObject(forKey: "access_token") as! String
        let refresh_token = aDecoder.decodeObject(forKey: "refresh_token") as! String
        self.init(token_type: token_type, access_token: access_token, refresh_token: refresh_token, expires_in: expires_in)
    }
}
