//
//  UserProfileViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import Combine
import FirebaseAuth

class UserProfileViewModel: ObservableObject {
    
    // Properties
    private var subscriptions               : [AnyCancellable] = [AnyCancellable]()
    private var appState                    : AppState
    
    // Published Properties
    @Published              var name                : String = ""
    @Published              var surname             : String = ""
    @Published              var address             : String = ""
    @Published              var phoneNumber         : String = ""
    @Published              var fidelityCard        : String = ""
    @Published              var termsChecked        : Bool = false
    
    @Published              var showAlert           : Bool = false
    
    @Published private(set) var hideLoginButtons    : Bool = false
    @Published private(set) var userCanExit         : Bool = false
    
    var onCompletion: ((User?) -> ())!
    
    // Init
    init(appState: AppState) {
        
        self.appState = appState
        setupSubscriptions()
        
        onCompletion = { user in
            if let user = user {
                self.appState.userProfileManager.setAuthenticationToken(user: user)
                self.checkInputValues()
            } else {
                self.showAlert = true
            }
        }
        
    }
    
    
    // Methods
    
    ///  Sets up the subscriptions
    private func setupSubscriptions() {
        
        var subscription = appState.userProfileManager.$userProfile.sink() { profile in
            
            if let name         = profile.name          { self.name = name                  }
            if let surname      = profile.surname       { self.surname = surname            }
            if let address      = profile.address       { self.address = address            }
            if let phoneNumber  = profile.phoneNumber   { self.phoneNumber = phoneNumber    }
            if let fidelityCard = profile.fidelityCard  { self.fidelityCard = fidelityCard  }
            
            let userIsAnonymous = profile.auth?.isAnonymous ?? true
            self.hideLoginButtons = !userIsAnonymous
            
        }
        
        subscriptions.append(subscription)
        
        subscription = $name.sink() { _ in
            self.checkInputValues()
        }
        subscriptions.append(subscription)
        
        subscription = $surname.sink() { _ in
            self.checkInputValues()
        }
        subscriptions.append(subscription)
        
        subscription = $address.sink() { _ in
            self.checkInputValues()
        }
        subscriptions.append(subscription)
        
        subscription = $phoneNumber.sink() { _ in
            self.checkInputValues()
        }
        subscriptions.append(subscription)
        
        subscription = $fidelityCard.sink() { _ in
            self.checkInputValues()
            DispatchQueue.main.async {
                if self.fidelityCard.count > 6 { self.fidelityCard.removeLast() }
            }
        }
        subscriptions.append(subscription)
        
        
    }
    
    /// Checks values
    private func checkInputValues() {
        
        var conditions = [Bool]()
        
        // Conditions on mandatory user input
        conditions.append(name.isEmpty)
        conditions.append(surname.isEmpty)
        conditions.append(address.isEmpty)
        conditions.append(phoneNumber.isEmpty)
        
        // Check phone number length
        conditions.append(phoneNumber.count != 10)
        
        // Condition on authentication
        //conditions.append(appState.userProfileManager.isUserTemporary())
        
        for condition in conditions {
            if condition {
                userCanExit = false
                return
            }
        }
        
        userCanExit = true
        
    }
    
    /// Sign in with Google
    func requestSignInWithGoogle() {
        AuthenticationEngine.shared.requestGoogleSignIn(onCompletion: onCompletion)
    }
    
    /// Saves the values inserted by the user
    func saveValues() {
        
        let fidelityCardValue = fidelityCard.isEmpty ? nil : fidelityCard
        appState.userProfileManager.setValues(
            name        : name,
            surname     : surname,
            address     : address,
            phoneNumber : phoneNumber,
            fidelityCard: fidelityCardValue
        )
        DataLoaderEngine.saveUserData(appState: appState)
        
    }
    
}

extension UserProfileViewModel {
    
    struct UserDataRepresentable {
        var name: String
        var surname: String
        var address: String
        var phoneNumber: String
    }
    
}


