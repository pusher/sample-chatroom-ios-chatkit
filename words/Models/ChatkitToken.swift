//
//  ChatkitToken.swift
//  words
//
//  Created by Neo Ighodaro on 27/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import Foundation

class ChatkitToken: NSObject, NSCoding {

    var access_token: String?
    
    init(access_token: String?) {
        self.access_token = access_token
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let accessToken = aDecoder.decodeObject(forKey: "access_token") as! String
        
        self.init(access_token: accessToken)
    }
}
