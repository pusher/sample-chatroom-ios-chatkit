//
//  Authenticator.swift
//  
//
//  Created by Neo Ighodaro on 23/12/2017.
//

import UIKit

class Authenticator: NSObject {

    func isLoggedIn() -> Bool {
        let accessToken = (getJwt()["access_token"] ?? "") as! String
        
        let hasAccessToken = accessToken.count > 0
        
        return hasAccessToken
    }

    private func getJwt() -> [String : Any?] {
        return TokenDataStore().getToken()
    }
}
