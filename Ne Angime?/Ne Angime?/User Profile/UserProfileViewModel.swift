//
//  UserProfileViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/21/21.
//

import Foundation

protocol UserProfileViewModelDelegate: class {
    func showErrorAlert(title: String, message: String)
}

class UserProfileViewModel {
    
    var delegate: UserProfileViewModelDelegate?
    
}
