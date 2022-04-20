//
//  ContactViewModel.swift
//  DiffableContacts
//
//  Created by Oluwabusayo Adebayo on 4/19/22.
//

import Foundation

class ContactViewModel: ObservableObject {
    @Published var name = " "
    @Published var isFavorite = false
}
