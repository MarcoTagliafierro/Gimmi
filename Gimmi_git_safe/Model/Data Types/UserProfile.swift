//
//  User.swift
//  Pods
//
//  Created by Marco Tagliafierro on 08/12/21.
//

import Foundation
import FirebaseAuth

// User
struct UserProfile {
    
    // Properties
    var name                : String?
    var surname             : String?
    
    var address             : String?
    var phoneNumber         : String?
    var fidelityCard        : String?
    var lastSupermarketID   : String?
    
    var auth                : FirebaseAuth.User?
    
    
    // Computed properties
    var uid         : String {
        get {
            return auth?.uid ?? .notSet
        }
    }
    
}

// Equatable conformance
extension UserProfile: Equatable {
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.surname == rhs.surname &&
            lhs.address == rhs.address &&
            lhs.phoneNumber == rhs.phoneNumber &&
            lhs.fidelityCard == rhs.fidelityCard &&
            lhs.lastSupermarketID == rhs.lastSupermarketID 
    }
    
}
