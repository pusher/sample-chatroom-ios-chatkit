//
//  UsersAPI.swift
//  words
//
//  Created by Neo Ighodaro on 25/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import Alamofire

class UsersAPI: UsersStoreProtocol {
    
    // MARK: - Contacts
    
    func fetchContacts(completionHandler: @escaping ([Contact]?, ContactsError?) -> Void) {
        let url = AppConstants.ENDPOINT + "/api/contacts"
        let headers = authorizationHeader(token: nil)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch (response.result) {
                case .success(let data):
                    let data = data as! [[String:Any]?]
                    let res = ListContacts.Fetch.Response(data: data)
                    
                    completionHandler(res.contacts, nil)
                case .failure(_):
                    completionHandler(nil, ContactsError.CannotFetch("Unable to fetch contacts"))
                }
            }
    }
    
    func addContact(request: ListContacts.Create.Request, completionHandler: @escaping (Contact?, ContactsError?) -> Void) {
        let params = ["user_id": request.user_id]
        let headers = authorizationHeader(token: nil)

        makeRequest("/api/contacts", method: .post, params: params, headers: headers) { data in
            guard data != nil else {
                return completionHandler(nil, ContactsError.CannotAdd("Unable to add contact"))
            }

            let response = ListContacts.Create.Response(data: data!)
            completionHandler(response.contact, nil)
        }
    }
    
    // MARK: - Authenticate
    
    func login(request: Login.Account.Request, completionHandler: @escaping (UserToken?, UsersStoreError?) -> Void) {
        let params: Parameters = [
            "grant_type": "password",
            "username": request.email,
            "password": request.password,
            "client_id": AppConstants.CLIENT_ID,
            "client_secret": AppConstants.CLIENT_SECRET,
        ]
        
        makeRequest("/oauth/token", method: .post, params: params, headers: nil) { data in
            guard data != nil else {
                return completionHandler(nil, UsersStoreError.CannotLogin("Invalid username or password."))
            }
            
            let response = Login.Account.Response(data: data!)
            let request = Login.Chatkit.Request(username: request.email, password: request.password, token: response.userToken)
            
            self.fetchChatkitToken(request: request) { token, error in
                guard error == nil else {
                    return completionHandler(nil, UsersStoreError.CannotFetchChatkitToken)
                }

                ChatkitTokenDataStore().setToken(token!)
                UserTokenDataStore().setToken(response.userToken)

                completionHandler(response.userToken, nil)
            }
        }
    }
    
    func signup(request: Signup.Request, completionHandler: @escaping (User?, UsersStoreError?) -> Void) {
        let params: Parameters = [
            "name": request.name,
            "email": request.email,
            "password": request.password
        ]

        makeRequest("/api/users/signup", method: .post, params: params, headers: nil) { data in
            guard data != nil else {
                return completionHandler(nil, UsersStoreError.CannotSignup("Can't create account."))
            }
            
            let response = Signup.Response(data: data!)
            let request = Login.Account.Request(email: request.email, password: request.password)
            
            self.login(request: request) { token, error in
                guard error == nil else {
                    return completionHandler(nil, UsersStoreError.CannotLogin("Can't login."))
                }
                
                completionHandler(response.user, nil)
            }
        }
    }
    
    func fetchChatkitToken(request: Login.Chatkit.Request, completionHandler: @escaping (ChatkitToken?, UsersStoreError?) -> Void) {
        let headers = authorizationHeader(token: request.token.access_token!)
        
        makeRequest("/api/chatkit/token", method: .post, params: nil, headers: headers) { data in
            guard data != nil else {
                return completionHandler(nil, UsersStoreError.CannotFetchChatkitToken)
            }
            
            let response = Login.Chatkit.Response(data: data!)
            completionHandler(response.token, nil)
        }
    }
    
    // MARK: - Helpers
    
    private func makeRequest(_ url: String, method: HTTPMethod, params: Parameters?, headers: HTTPHeaders?, completion: @escaping([String:Any]?) -> Void) {
        let enc = JSONEncoding.default
        let url = AppConstants.ENDPOINT + url

        Alamofire.request(url, method: .post, parameters: params, encoding: enc, headers: headers)
                 .validate()
                 .responseJSON { response in
                     switch (response.result) {
                         case .success(let data): completion((data as! [String:Any]))
                         case .failure(_): completion(nil)
                     }
                 }
    }
    
    private func authorizationHeader(token: String?) -> HTTPHeaders {
        let accessToken = (token == nil) ? UserTokenDataStore().getToken().access_token : token
        return ["Authorization": "Bearer \(accessToken!)"]
    }
}
