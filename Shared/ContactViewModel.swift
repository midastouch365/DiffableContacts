//
//  ContactViewModel.swift
//  DiffableContacts
//
//  Created by Oluwabusayo Adebayo on 4/19/22.
//

import Foundation
import SwiftUI

class ContactViewModel: ObservableObject {
    @Published var name = " "
    @Published var isFavorite = false
}
