//
//  Authenticator.swift
//  
//
//  Created by Neo Ighodaro on 23/12/2017.
//

import UIKit

class Authenticator
{
    func isLoggedIn() -> Bool {
        return getAccessToken().count > 0
    }

    private func getAccessToken() -> String {
        guard let token = ChatkitTokenDataStore().getToken().access_token, token.count > 0 else {
            return ""
        }

        return token
    }
}
