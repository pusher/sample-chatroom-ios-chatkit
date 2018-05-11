//
//  CurrentUserIDDataStore.swif
//  words
//
//  Created by Neo Ighodaro on 27/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import Foundation

class CurrentUserIDDataStore {
    static var DATA_KEY = "WORDS_CURRENT_USER_ID"

    func getID() -> CurrentUserID {
        if let id = UserDefaults.standard.object(forKey: type(of: self).DATA_KEY) as! Data? {
            return NSKeyedUnarchiver.unarchiveObject(with: id) as! CurrentUserID
        }

        return CurrentUserID(id: nil)
    }

    func setID(_ id: CurrentUserID) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: id)
        UserDefaults.standard.set(encodedData, forKey: type(of: self).DATA_KEY)
    }
}
