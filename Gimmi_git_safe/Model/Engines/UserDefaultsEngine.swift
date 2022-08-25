//
//  UserDefaultsEngine.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 19/12/21.
//

import Foundation


class UserDefaultsEngine {
    
    private enum Keys: String {
        case isSet          = "isSet"
        case name           = "name"
        case surname        = "surname"
        case address        = "address"
        case phoneNumber    = "phonenumber"
        case fidelityCard   = "fidelitycard"
        
        case supermarketID  = "supermaketID"
    }
    
    
    // User's data related functions
    static func getUserData() -> UserProfile? {
        
        let defaults = UserDefaults.standard
        
        if let _ = defaults.value(forKey: Keys.isSet.rawValue) {
            
            let name            = defaults.value(forKey: Keys.name.rawValue) as! String
            let surname         = defaults.value(forKey: Keys.surname.rawValue) as! String
            let address         = defaults.value(forKey: Keys.address.rawValue) as! String
            let phoneNumber     = defaults.value(forKey: Keys.phoneNumber.rawValue) as! String
            let fidelityCard    = defaults.value(forKey: Keys.fidelityCard.rawValue) as? String
            
            return UserProfile(
                name: name,
                surname: surname,
                address: address,
                phoneNumber: phoneNumber,
                fidelityCard: fidelityCard
            )
            
        } else {
            return nil
        }
    
    }
    
    static func saveUserData(userProfile: UserProfile) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(true, forKey: Keys.isSet.rawValue)
        defaults.set(userProfile.name, forKey: Keys.name.rawValue)
        defaults.set(userProfile.surname, forKey: Keys.surname.rawValue)
        defaults.set(userProfile.address, forKey: Keys.address.rawValue)
        defaults.set(userProfile.phoneNumber, forKey: Keys.phoneNumber.rawValue)
        if let fidelityCard = userProfile.fidelityCard {
            defaults.set(fidelityCard, forKey: Keys.fidelityCard.rawValue)
        }
    
    }
    
    // Supermaket's data related functions
    static func getSupermarketData() -> String? {
        
        let defaults = UserDefaults.standard
        return defaults.value(forKey: Keys.supermarketID.rawValue) as? String
    
    }
    
    static func saveSupermaketData(supermarket ID: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(ID, forKey: Keys.supermarketID.rawValue)
        
    }
    
}
