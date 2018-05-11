//
//  CurrentUserID.swift
//  words
//
//  Created by Neo Ighodaro on 27/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import Foundation

class CurrentUserID: NSObject, NSCoding {

    var id: String?

    init(id: String?) {
        self.id = id
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String

        self.init(id: id)
    }
}
