//
//  UserProfileManager.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 09/03/22.
//

import Foundation
import FirebaseAuth

class UserProfileManager {
    
    // Properties
    @Published var userProfile: UserProfile = UserProfile()
    
    
    // Init
    init() { }
    
    
    // Methods
    
    /// Sets user values
    func setValues(name: String, surname: String, address: String, phoneNumber: String, fidelityCard: String? = nil) {
        
        // By replacing the entire object we are sure only one update is sent
        // via the publisher
        let newUserProfile = UserProfile(
            name:               name,
            surname:            surname,
            address:            address,
            phoneNumber:        phoneNumber,
            fidelityCard:       fidelityCard,
            lastSupermarketID:  userProfile.lastSupermarketID,
            auth:               userProfile.auth
        )
        
        userProfile = newUserProfile
        
    }
    
    func setValues(profile: UserProfile) {
        
        let auth                = self.userProfile.auth
        self.userProfile        = profile
        self.userProfile.auth   = auth
        
    }
    
    func setSupermarketID(to supermarketID: String) {
        self.userProfile.lastSupermarketID = supermarketID
    }
    
    func getSupermarketID() -> String? {
        return self.userProfile.lastSupermarketID
    }
    
    func setAuthenticationToken(user: User) {
        userProfile.auth = user
    }
    
    /// Returns a boolean indicating whether the user is temporary or not
    func isUserTemporary() -> Bool {
        return userProfile.auth?.isAnonymous ?? true
    }
    
    /// Returns a boolean indicating whether the userProfile is complete or not
    func isUserProfileComplete() -> Bool {
        
        return  userProfile.name        != nil &&
                userProfile.surname     != nil &&
                userProfile.phoneNumber != nil &&
                userProfile.address     != nil &&
                userProfile.auth        != nil
        
    }
    
    
}
