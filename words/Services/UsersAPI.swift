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
    
    static var contacts = [
        Contact(user: User(id: 1, name: "John Doe", email: "john@doe.com", chatkit_id: "john-at-cco"), room: Room(id: "sample", name:"john@doe.co")),
        Contact(user: User(id: 2, name: "Jane Doe", email: "jane@doe.com", chatkit_id: "john-at-cco"), room: Room(id: "sample", name:"john@doe.co")),
        Contact(user: User(id: 1, name: "Mary Doe", email: "mary@doe.com", chatkit_id: "john-at-cco"), room: Room(id: "sample", name:"john@doe.co"))
    ]
    
    // MARK: - Contacts
    
    func fetchContacts(completionHandler: @escaping ([Contact]) -> Void) {
        completionHandler(type(of: self).contacts)
    }
    
    func addContact(request: ListContacts.AddContact.Request, completionHandler: @escaping (ListContacts.AddContact.Response?, ContactsError?) -> Void) {
        let params: Parameters = ["user_id": request.user_id]
        
        makeRequest("/api/contacts", params: params, headers: nil) { data in
            if data == nil {
                completionHandler(nil, ContactsError.CannotAdd("Unable to add contact"))
            } else {
                completionHandler(ListContacts.AddContact.Response(data: data!), nil)
            }
        }
    }
    
    // MARK: - Authenticate
    
    func login(request: Login.Account.Request, completionHandler: @escaping (UserToken?, UsersStoreError?) -> Void) {
        let params: Parameters = [
            "username": request.email,
            "password": request.password,
            "grant_type": "password",
            "client_id": AppConstants.CLIENT_ID,
            "client_secret": AppConstants.CLIENT_SECRET,
        ]
        
        makeRequest("/oauth/token", params: params, headers: nil) { data in
            if data != nil {
                completionHandler(Login.Account.Response(data: data).userToken, nil)
            } else {
                completionHandler(nil, UsersStoreError.CannotLogin("Invalid username or password."))
            }
        }
    }
    
    func signup(request: Signup.Request, completionHandler: @escaping (User?, UsersStoreError?) -> Void) {
        let params: Parameters = [
            "name": request.name,
            "email": request.email,
            "password": request.password
        ]

        makeRequest("/api/users/signup", params: params, headers: nil) { data in
            if data != nil {
                return completionHandler(Signup.Response(data: data).user, nil)
            }
            
            completionHandler(nil, UsersStoreError.CannotSignup("Unable to create account."))
        }
    }
    
    func fetchChatkitToken(request: Login.Chatkit.Request, completionHandler: @escaping (ChatkitToken?, UsersStoreError?) -> Void) {
        let headers: HTTPHeaders = ["Authorization": "Bearer \(request.token.access_token!)"]
        
        makeRequest("/api/chatkit/token", params: nil, headers: headers) { data in
            if data != nil {
                return completionHandler(Login.Chatkit.Response(data: data!).token, nil)
            }
            
            completionHandler(nil, UsersStoreError.CannotFetchChatkitToken("Unable to fetch chatkit token"))
        }
    }
    
    // MARK: - Helpers
    
    private func makeRequest(_ url: String, params: Parameters?, headers: HTTPHeaders?, completionHandler: @escaping([String: Any?]?) -> Void) {
        let encoding = JSONEncoding.default
        
        Alamofire
                .request(self.url(url), method: .post, parameters: params, encoding: encoding, headers: headers)
                .validate()
                .responseJSON { response in
                    switch (response.result) {
                    case .success(let data):
                        completionHandler((data as! [String:Any?]))
                    case .failure(_):
                        completionHandler(nil)
                    }
                }
    }
    
    private func url(_ path: String) -> String {
        return AppConstants.ENDPOINT + path
    }
}
