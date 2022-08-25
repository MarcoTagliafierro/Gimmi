//
//  ProductsListViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import Combine

// ViewModel for ProductsListView
class ProductsListViewModel: ObservableObject {
    
    // Properties
    private var subscriptions   : [AnyCancellable] = [AnyCancellable]()
    private var appState        : AppState
    
    // Published Properties
    @Published private(set) var obfuscateFields             : Bool                    = true
    @Published              var showAlert                   : Bool                    = false
    @Published              var showSupermarkets            : Bool                    = false
                            var showUserProfile             : Bool                    = false
    
    @Published private(set) var selectedSupermarket         : String                  = ""
    @Published private(set) var supermarketIsSelected       : Bool                    = false
    @Published private(set) var categoriesRepresentables    : [CategoryRepresentable] = []
    
    private var productsIndexes                             : [String: (category: Int, product: Int)]    = [:]
    
    
    // Init
    init(appState: AppState) {
        
        self.appState = appState
        
        setupPlaceholderRepresentables()
        setupSubscriptions()
        
        manageLogin() { error in
            if error == nil {
                self.downloadProducts()
            } else {
                print("[ERROR] Login failed")
            }
        }
        
    }
    
    
    // Methods
    
    /// Sets up same fake products and categories to fill up the view
    /// during the loading
    private func setupPlaceholderRepresentables() {
        
        selectedSupermarket = "             "
        
        let numberOfSections = Int.random(in: 6..<9)
        for _ in 0...numberOfSections  {
            
            let numberOfProducts = Int.random(in: 2..<5)
            var productsRepresentables = [ProductCellRepresentable]()
            
            for _ in 0...numberOfProducts {
                
                var productName = " "
                let nameLenght = Int.random(in: 10...20)
                for _ in 0...nameLenght {
                    productName = productName + " "
                }
                productsRepresentables.append(ProductCellRepresentable(
                    name    : productName,
                    price   : "   ",
                    points  : "   ",
                    id      : .notSet)
                )
                
            }
            
            categoriesRepresentables.append(
                CategoryRepresentable(
                    categoryName    : "             ",
                    categoryItems   : productsRepresentables,
                    id              : .notSet
                )
            )
            
        }
        
    }
    
    ///  Sets up the subscriptions
    private func setupSubscriptions() {
        
        // Data Download
        var subscription = appState.dataRepository.$products.dropFirst().sink() { productsCategories in
            
            if !productsCategories.isEmpty {
                
                if self.categoriesRepresentables.isEmpty || self.obfuscateFields {
                    self.setupCategoriesRepresentables(productsCategories: productsCategories)
                    self.obfuscateFields = false
                } else {
                    self.updateCategoriesRepresentablesImages(productsCategories: productsCategories)
                }
                
            }
            
        }
        
        subscriptions.append(subscription)
        
        // Shopping Session - Selected supermaket
        // Note: dropFirst allows to avoid getting the first default value of the publisher
        //       which is always nil
        subscription = appState.shoppingSession.$supermarket.sink() { supermarket in
            
            if self.appState.dataRepository.supermarkets.isEmpty {
                print("Empty supermarket")
                return
            }
            
            // If a supermaket has been previously selected by the user it is loaded,
            // otherwise the supermaket selection screen is presented
            if let supermarket = supermarket {
                self.selectedSupermarket    = supermarket.name
                self.supermarketIsSelected  = true
                
                self.categoriesRepresentables = [CategoryRepresentable]()
                self.appState.dataRepository.setSelectedSupermarket(to: supermarket)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.showSupermarkets = true
                }
            }
            
        }
        
        subscriptions.append(subscription)
        
        // User Profile Manager - User data
        subscription = appState.userProfileManager.$userProfile.sink() { userProfile in
            
            let userIsTemporary = userProfile.auth?.isAnonymous ?? true
            let userProfileIsComplete =
                    userProfile.name        != nil &&
                    userProfile.surname     != nil &&
                    userProfile.phoneNumber != nil &&
                    userProfile.address     != nil &&
                    userProfile.auth        != nil
            self.showUserProfile = userIsTemporary || !userProfileIsComplete
            
        }
        
        subscriptions.append(subscription)
        
    }
    
    /// Manages the authentication of the user. If present, the previous auth token
    /// is retrieved, otherwise a temporary one is created
    ///
    /// - Parameter onCompletion: completion closure
    private func manageLogin(onCompletion: @escaping (Error?)->()) {
        
        AuthenticationEngine.shared.manageExistingAuthenticationToken() { user in
            
            if user != nil {
                self.appState.userProfileManager.setAuthenticationToken(user: user!)
                onCompletion(nil)
            } else {
                onCompletion(GenericError())
            }
            
        }
        
    }
    
    /// Download all the products using DataLoaderEngine. After the download is finished,
    /// user's defaults are loaded from the the memory
    ///
    public func downloadProducts() {
        
        DataLoaderEngine.getUserDefaultsData(appState: self.appState)
        
        DataLoaderEngine.loadData(appState: appState) { error in
            
            // Tell the view to show an alert if any error is present
            if let _ = error {
                DispatchQueue.main.async {
                    self.showAlert = true
                }
            }
            
        }
        
    }
    
    /// Setup cell representables, beware that the whole array is recreated.
    /// productIndexes dictionary is also created and populated.
    ///
    /// - Parameter productsCategories: array of categories and products
    private func setupCategoriesRepresentables(productsCategories: [DataRepository.CategoryAndProducts]) {
        
        var categoriesRepresentablesCopy = [CategoryRepresentable]()
        
        for (categoryIndex, productCategory) in productsCategories.enumerated() {
            
            var productsCellsRepresentables = [ProductCellRepresentable]()
            for (productIndex, product) in productCategory.products.enumerated() {
                
                // Normalize price lenght
                var productPrice    = product.price.description
                let components      = productPrice.split(separator: ".")
                
                if components.count == 1 {          // Integer price
                    productPrice = productPrice + ".00"
                } else {
                    
                    if components[1].count == 1 {   // Floating point price with only one char after the point
                        productPrice = productPrice + "0"
                    }
                    
                }
                
                let productCellRepresentable = ProductCellRepresentable(
                    name    : product.name,
                    price   : productPrice,
                    points  : String(product.points),
                    image   : product.image,
                    id      : product.ID
                )
                
                productsCellsRepresentables.append(productCellRepresentable)
                
                // Save product index
                productsIndexes[product.ID] = (categoryIndex, productIndex)
                
            }
            
            if !productsCellsRepresentables.isEmpty {
                let categoryRepresentable = CategoryRepresentable(
                    categoryName    : productCategory.category.name,
                    categoryItems   : productsCellsRepresentables,
                    id              : productCategory.category.ID
                )
                
                categoriesRepresentablesCopy.append(categoryRepresentable)
            }
            
        }
        
        categoriesRepresentables = categoriesRepresentablesCopy
        
    }
    
    /// Updates cell representables's images
    ///
    /// - Parameter productsCategories: map of categories and products
    private func updateCategoriesRepresentablesImages(productsCategories: [DataRepository.CategoryAndProducts]) {
        
        for productCategory in productsCategories {
            
            for product in productCategory.products {
                
                if product.image != nil {
                    if let indexes = productsIndexes[product.ID] {
                        categoriesRepresentables[indexes.category].categoryItems[indexes.product].image = product.image
                    }
                }
                
            }
            
        }
        
    }
    
}

// Child ViewModel
extension ProductsListViewModel {
    
    func getUserProfileViewModel() -> UserProfileViewModel {
        return UserProfileViewModel(appState: appState)
    }
    
    func getUserActivitiesViewModel() -> UserActivitiesViewModel {
        return UserActivitiesViewModel(appState: appState)
    }
    
    func getStoresViewModel() -> StoresViewModel {
        return StoresViewModel(appState: appState)
    }
    
    func getScanViewModel() -> ScanViewModel {
        return ScanViewModel(appState: appState)
    }
    
}

// View Representables
extension ProductsListViewModel {
    
    struct ProductCellRepresentable: Identifiable {
        var name            : String
        var price           : String
        var points          : String
        var image           : Data?
        
        var id              : String
    }
    
    struct CategoryRepresentable: Identifiable {
        var categoryName    : String
        var categoryItems   : [ProductCellRepresentable]
        
        var id              : String
    }
    
}
