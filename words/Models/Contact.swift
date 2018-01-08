//
//  User.swift
//  words
//
//  Created by Neo Ighodaro on 24/12/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//

import PusherChatkit

struct Contact {
    var user: User
    var room: PCRoom
}

class ContactsOnline {
    static let shared = ContactsOnline()
    
    var contacts: [ListContacts.Fetch.ViewModel.DisplayedContact] = []
    
    private init() {
        self.contacts = []
    }
    
    func addContact(contact: ListContacts.Fetch.ViewModel.DisplayedContact) {
        contacts.append(contact)
    }
    
    func removeContact(contact: ListContacts.Fetch.ViewModel.DisplayedContact) {
        guard let index = contacts.index(of: contact) else { return }
        contacts.remove(at: index)
    }
}
