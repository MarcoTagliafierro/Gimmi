//
//  CheckoutViewModel.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 04/12/21.
//

import SwiftUI
import Combine
import Stripe

class CheckoutViewModel: ObservableObject {
    
    // Properties
    private var subscriptions   : [AnyCancellable]  = [AnyCancellable]()
    private var appState        : AppState
    public  var paymentEngine   : PaymentEngine
    
    // Published properties
    @Published private(set) var shoppingList        : [ProductCellRepresentable]
    @Published private(set) var paymentSheet        : PaymentSheet?
    @Published              var disablePayButton    : Bool
    @Published              var disableReqButton    : Bool
    @Published private(set) var total               : String
    @Published private(set) var points              : String
    
    @Published              var showAlert           : Bool
               private(set) var alertMessage        : String
    @Published              var showReceiptView     : Bool
    
    // Init
    init(appState: AppState) {
        
        self.appState   = appState
        paymentEngine   = PaymentEngine()
        total           = ShoppingSession.stringTotalPrice(of: appState.shoppingSession.totalCost)
        points          = String(appState.shoppingSession.totalPoints)
        
        shoppingList        = [ProductCellRepresentable]()
        paymentSheet        = nil
        disablePayButton    = false
        disableReqButton    = false
        
        showAlert       = false
        alertMessage    = ""
        showReceiptView = false
        
        setupSubscriptions()
        
    }
    
    // Methods
    
    ///Setup subscriptions
    private func setupSubscriptions() {
        
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
            
            }
            
        }
        
        subscriptions.append(subscription)
        
    }
    
    func addProduct(productCode: String) {
        
        if let product = appState.dataRepository.getProductById(id: productCode) {
            appState.shoppingSession.add(product: product)
        } else {
            print("[!] Error adding product, product non found (productCode: \(productCode))")
        }
        
    }
    
    func decreaseProduct(productCode: String) {
        
        if let product = appState.dataRepository.getProductById(id: productCode) {
            appState.shoppingSession.decrease(product: product)
        } else {
            print("[!] Error decreasing product quantity, product non found (productCode: \(productCode))")
        }
        
    }
    
    // Payment functions
    
    /// Request a payment instance to Stripe
    func requestPayment() {
        
        paymentSheet = nil
        disableReqButton = true
        
        let uid = appState.userProfileManager.userProfile.uid
        let amount = appState.shoppingSession.totalCost
        
        paymentEngine.preparePayment(uid: uid, amountInDecimal: amount, currency: "eur") { paymentSheet in
            self.paymentSheet = paymentSheet
            self.disableReqButton = false
        }
        
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        
        paymentSheet = nil
        disablePayButton = true
        
        switch result {
        case .canceled:
            print("[ALERT] CheckoutViewModel: user cancelled the payment")
            disablePayButton = false
        case .failed(error: let error):
            showAlert = true
            disablePayButton = false
            alertMessage = error.localizedDescription
        case .completed:
            appState.shoppingSession.uploadSession(onCompletion: { _ in
                self.showReceiptView = true
            })
        }
        
    }
    
}

// Child ViewModel
extension CheckoutViewModel {
    
    func getReceiptViewModel() -> ReceiptViewModel {
        return ReceiptViewModel(appState: appState)
    }
    
}

// Representables
extension CheckoutViewModel {
    
    struct ProductCellRepresentable: Identifiable {
        var productID       : String
        
        var productName     : String
        var productPrice    : String
        var productImage    : Data?
        var productCount    : Int
        
        var id: UUID = UUID()
    }
    
}
