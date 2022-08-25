//
//  GimmiApp.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 30/11/21.
//

import SwiftUI
import Firebase
import Stripe

@main
struct GimmiApp: App {
    
    // Properties
    let appState = AppState()
    
    
    // Inits
    init() {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "test_key"
    }
    
    
    // Main screen
    var body: some Scene {
        WindowGroup {

            let viewModel = ProductsListViewModel(appState: appState)
            ProductsListView(viewModel: viewModel)

        }
    }
    
}
