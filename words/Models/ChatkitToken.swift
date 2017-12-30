//
//  ChatkitToken.swift
//  words
//
//  Created by Neo Ighodaro on 27/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit

class ChatkitToken: NSObject, NSCoding
{
    var access_token: String?
    var refresh_token: String?
    
    init(access_token: String?, refresh_token: String?) {
        self.access_token = access_token
        self.refresh_token = refresh_token
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(refresh_token, forKey: "refresh_token")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let access_token = aDecoder.decodeObject(forKey: "access_token") as! String
        let refresh_token = aDecoder.decodeObject(forKey: "refresh_token") as! String
        self.init(access_token: access_token, refresh_token: refresh_token)
    }
}
