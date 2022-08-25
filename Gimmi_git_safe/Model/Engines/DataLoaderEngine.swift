//
//  DataLoaderEngine.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 09/12/21.
//

import Foundation

// This class serves the purpose of loading data
// from Firebase into the AppState
//
// [FirebaseEngine]     <--> [DataLoaderEngine] --> [AppState]
// [UserDefaultEngine]  <--> [DataLoaderEngine] --> [AppState]

class DataLoaderEngine {
    
    /// Load products and supermarket data from Firebase into the AppState
    ///
    ///  - Parameter appState: the app's state
    ///  - Parameter onCompletion: the closure executed after the loading finishes
    static func loadData(appState: AppState, onCompletion: @escaping (Error?) -> ()) {
        
        let downloadGroup = DispatchGroup()
        var error: Error? = nil
        
        // Load all the categories
        downloadGroup.enter()
        
        FirebaseEngine.shared.getAll(collectionPath: .categories) { categoriesData in
            
            print("[CHECK] DataLoaderEngine: categories download finished. Data \(categoriesData == nil ? "is nil" : "is NOT nil")")
            
            if let categoriesData = categoriesData {
                appState.dataRepository.loadCategories(data: categoriesData)
                
                // After the categories, the products are loaded
                FirebaseEngine.shared.getAll(collectionPath: .products) { productsData in
                    
                    print("[CHECK] DataLoaderEngine: products download finished. Data \(productsData == nil ? "is nil" : "is NOT nil")")
                    
                    if let productsData = productsData {
                        
                        appState.dataRepository.loadProducts(data: productsData)
                        
                        // Load products images
                        for productData in productsData {
                            
                            let productID = productData[DictionariesFields.ID] as! String
                            let productCategory = productData[DictionariesFields.category] as! String
                            
                            FirebaseEngine.shared.getImage(imageID: productID) { imageData in
                                if let imageData = imageData {
                                    appState.dataRepository.setProductImage(productID: productID, categoryID: productCategory, imageData: imageData)
                                }
                            }
                            
                        }
                        
                    } else {
                        error = GenericError()
                    }
                    
                }
                
            } else {
                error = GenericError()
            }
            
            downloadGroup.leave()
            
        }
        
        
        // Load all the supermarkets. Once the data is downloaded, if the user
        // previously selected a supermarket the preference is restored
        downloadGroup.enter()
        
        FirebaseEngine.shared.getAll(collectionPath: .supermarkets) { supermarketsData in
            
            print("[CHECK] DataLoaderEngine: supermarkets download finished. Data \(supermarketsData == nil ? "is nil" : "is NOT nil")")
            
            if let supermarketsData = supermarketsData {
                
                appState.dataRepository.loadSupermarkets(data: supermarketsData)
                
                let selectedSupermarketID = appState.userProfileManager.getSupermarketID()
                let selectedSupermarket = appState.dataRepository.supermarkets.first(where: { $0.ID == selectedSupermarketID })
                
                appState.shoppingSession.setSelectedSupermarket(to: selectedSupermarket)
                appState.dataRepository.setSelectedSupermarket(to: selectedSupermarket)
                
                print("[CHECK] DataLoaderEngine: previously selected supermarket set. Supermaket name: \(selectedSupermarket?.name ?? "nil")")
                
            } else {
                error = GenericError()
            }
            
            downloadGroup.leave()
            
        }
        
        // DownloadGroup completion
        downloadGroup.notify(queue: DispatchQueue.global()) { onCompletion(error) }
        
    }
    
    /// Load user and supermarket data from userDefaults into the AppState
    ///
    /// - Parameter appState: the app's state
    static func getUserDefaultsData(appState: AppState) {
        
        if let userProfile = UserDefaultsEngine.getUserData() {
            appState.userProfileManager.setValues(profile: userProfile)
        }
        
        if let supermarketID = UserDefaultsEngine.getSupermarketData() {
            appState.userProfileManager.setSupermarketID(to: supermarketID)
        }
        
        print("[CHECK] DataLoaderEngine: data from UserDefaults restored")
        
    }
    
    /// Saves user data to userDefaults
    ///
    ///  - Parameter appState: the app's state
    static func saveUserData(appState: AppState) {
        
        let userProfile = appState.userProfileManager.userProfile
        UserDefaultsEngine.saveUserData(userProfile: userProfile)
        
    }
    
    /// Saves supermaket name into userDefaults
    ///
    ///  - Parameter appState: the app's state
    static func saveSupermaketName(appState: AppState) {
        
        guard let supermarket = appState.shoppingSession.supermarket  else {
            assertionFailure("[Error in DataLoaderEngine] Supermarket must be set before calling saveUserData")
            return
        }
        
        UserDefaultsEngine.saveSupermaketData(supermarket: supermarket.ID)
        
    }
    
}
