//
//  UsersWorker.swift
//  words
//
//  Created by Neo Ighodaro on 24/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import UIKit
import Foundation

class UsersWorker {

    var usersStore: UsersStoreProtocol
    
    init(usersStore: UsersStoreProtocol) {
        self.usersStore = usersStore
    }
    
    // MARK: - Contacts
    
    func fetchContacts(completionHandler: @escaping ([Contact]) -> Void) {
        usersStore.fetchContacts { contacts in
            DispatchQueue.main.async {
                completionHandler(contacts)
            }
        }
    }
    
    func addContact(request: ListContacts.AddContact.Request, completionHandler: @escaping (ListContacts.AddContact.Response?, ContactsError?) -> Void) {
        usersStore.addContact(request: request) { (response, error) in
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    
    // MARK: - Authenticate
    
    func login(request: Login.Account.Request, completionHandler: @escaping(UserToken?, UsersStoreError?) -> Void) {
        usersStore.login(request: request) { (token, error) in
            DispatchQueue.main.async {
                completionHandler(token, error)
            }
        }
    }
    
    func signup(request: Signup.Request, completionHandler: @escaping(User?, UsersStoreError?) -> Void) {
        usersStore.signup(request: request) { (user, error) in
            DispatchQueue.main.async {
                completionHandler(user, error)
            }
        }
    }
    
    func fetchChatkitToken(request: Login.Chatkit.Request, completionHandler: @escaping(ChatkitToken?, UsersStoreError?) -> Void) {
        usersStore.fetchChatkitToken(request: request) { (chatkitToken, error) in
            DispatchQueue.main.async {
                completionHandler(chatkitToken, error)
            }
        }
    }
}

// MARK: Users API

protocol UsersStoreProtocol {
    func fetchContacts(completionHandler: @escaping ([Contact]) -> Void)
    func addContact(request: ListContacts.AddContact.Request, completionHandler: @escaping (ListContacts.AddContact.Response?, ContactsError?) -> Void)
    func login(request: Login.Account.Request, completionHandler: @escaping(UserToken?, UsersStoreError?) -> Void)
    func signup(request: Signup.Request, completionHandler: @escaping(User?, UsersStoreError?) -> Void)
    func fetchChatkitToken(request: Login.Chatkit.Request, completionHandler: @escaping(ChatkitToken?, UsersStoreError?) -> Void)
}

// MARK: Contact Error

enum ContactsError: Error {
    case CannotAdd(String)
}

// MARK: Users Error

enum UsersStoreError: Error {
    case CannotLogin(String)
    case CannotSignup(String)
    case CannotFetchChatkitToken(String)
}
