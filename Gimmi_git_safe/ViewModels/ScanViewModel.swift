//
//  ScanViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import Combine

class ScanViewModel: ObservableObject {
    
    //Properties
    private var subscriptions   : [AnyCancellable] = [AnyCancellable]()
    private var appState        : AppState
    
    //Published Properties
    @Published              var showAlert       : Bool
    @Published private(set) var shoppingList    : [ProductCellRepresentable]
    @Published private(set) var canProceed      : Bool
    @Published private(set) var total           : String
    @Published private(set) var points          : String
    
    // Init
    init(appState: AppState) {
        
        self.appState = appState
    
        showAlert       = false
        shoppingList    = [ProductCellRepresentable]()
        canProceed      = false
        total           = "0.00"
        points          = "0"
        
        appState.shoppingSession.resetSession()
        setupSubscriptions()
        
    }
    
    
    // Methods
    
    ///  Sets up the subscriptions
    private func setupSubscriptions() {
        
        // Shopping session
        let subscription = appState.shoppingSession.$entries.sink() { entries in
            
            DispatchQueue.main.async {
                
                self.shoppingList = [ProductCellRepresentable]()
                for entry in entries {
                    
                    let product = entry.item
                    
                    self.shoppingList.append(ProductCellRepresentable(
                        productID   : product.ID,
                        productName : product.name,
                        productPrice: ShoppingSession.stringTotalPrice(of: entry),
                        productImage: product.image,
                        productCount: entry.count
                    ))
                    
                }
                
                self.canProceed = !self.shoppingList.isEmpty
                self.updateInfos()
                
            }
            
        }
        
        subscriptions.append(subscription)
        
    }
    
    /// Increase by one the quantity of a product
    /// - Parameter productCode: the code of the product to modify
    func addProduct(productCode: String) {
        
        if let product = appState.dataRepository.getProductById(id: productCode) {
            appState.shoppingSession.add(product: product)
        } else {
            print("[ERROR] ScanViewModel: error adding product, product non found (productCode: \(productCode)")
        }
        
    }
    
    /// Decrease of one the quantity of a product
    /// - Parameter productCode: the code of the product to modify
    func decreaseProduct(productCode: String) {
        
        if let product = appState.dataRepository.getProductById(id: productCode) {
            appState.shoppingSession.decrease(product: product)
        } else {
            print("[ERROR] ScanViewModel: error decreasing product quantity, product non found (productCode: \(productCode)")
        }
        
    }
    
    /// Updates the displayed order total and points
    /// Notes: AW is also updated
    private func updateInfos() {
        
        let totalAsDecimal = appState.shoppingSession.totalCost
        total = ShoppingSession.stringTotalPrice(of: totalAsDecimal)
        points = "\(appState.shoppingSession.totalPoints)"
        
        appState.awCommunication.setTotalAndPoints(total: total, points: points)
        
    }
    
    /// Resets apple watch state
    ///
    func resetAppleWatchState() {
        appState.awCommunication.setImage(data: Data())
        appState.awCommunication.setTotalAndPoints(total: .notSet, points: .notSet)
    }
    
    /// Used during test, adds some products to the shopping session
    func addTestProducts() {
//        #if DEBUG
//        self.addProduct(productCode: "I5PTmAcl0Dv1I5nKnxTT")
//        self.addProduct(productCode: "1NrWzOzxYBN8qQrZmgC1")
//        self.addProduct(productCode: "11OIIL7QOWpvSauUAWEB")
//        self.addProduct(productCode: "I5PTmAcl0Dv1I5nKnxTT")
//        #endif
    }
    
}

// Child ViewModel
extension ScanViewModel {
    
    func getCheckoutViewModel() -> CheckoutViewModel {
        return CheckoutViewModel(appState: appState)
    }
    
}

extension ScanViewModel {
    
    struct ProductCellRepresentable: Identifiable {
        var productID       : String
        
        var productName     : String
        var productPrice    : String
        var productImage    : Data?
        var productCount    : Int
        
        var id: UUID = UUID()
    }
    
}
