//
//  AppState.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 08/12/21.
//

import Foundation
import Combine


// Class to manage the app's state: all instances of state
// related classes/structs are saved here
class AppState {
    
    // Properties
    var userProfileManager      : UserProfileManager
    var dataRepository          : DataRepository
    var shoppingSession         : ShoppingSession
    
    var awCommunication         : AWCommunicationModule
    
    // Init
    init() {
        
        userProfileManager      = UserProfileManager()
        dataRepository          = DataRepository()
        shoppingSession         = ShoppingSession()
        
        awCommunication         = AWCommunicationModule()
        
    }
    
}
