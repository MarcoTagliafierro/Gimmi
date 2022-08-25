//
//  ReceiptViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import UIKit
import Combine
import CoreMedia

class ReceiptViewModel: ObservableObject {
    
    // Properties
               private      var appState                    : AppState
                            var supermarketRepresentable    : SupermarketRepresentable  = SupermarketRepresentable()
                            var sessionRepresentable        : SessionRepresentable      = SessionRepresentable()
    @Published private(set) var shoppingList                : [EntryCellRepresentable]  = []

    
    // Init
    init(appState: AppState) {
        
        self.appState = appState
        setupRepresentables()
        
    }
    
    
    // Methods
    private func setupRepresentables() {
        
        // Supermarket
        let supermarket                     = appState.shoppingSession.supermarket
        supermarketRepresentable.name       = supermarket?.name ?? ""
        supermarketRepresentable.address    = supermarket?.address ?? ""
        
        // Shopping list
        shoppingList = [EntryCellRepresentable]()
        for entry in appState.shoppingSession.entries {
            
            let product = entry.item
            
            shoppingList.append(EntryCellRepresentable(
                name : product.name,
                price: ShoppingSession.stringTotalPrice(of: entry),
                count: "\(entry.count)"
            ))
                
        }
        
        // Update apple watch state
        let imageData = UIImage(named: "qr-code")!.pngData()!
        appState.awCommunication.setImage(data: imageData)
        appState.awCommunication.setTotalAndPoints(total: .notSet, points: .notSet)
        
        // Session
        let totalAsDecimal          = appState.shoppingSession.totalCost
        sessionRepresentable.total  = ShoppingSession.stringTotalPrice(of: totalAsDecimal)
        sessionRepresentable.points = appState.shoppingSession.totalPoints.description
    
    }
    
}

extension ReceiptViewModel {
    
    struct EntryCellRepresentable: Identifiable {
        var name        : String
        var price       : String
        var count       : String
        
        var id: UUID = UUID()
    }
    
    struct SupermarketRepresentable {
        var name        : String = ""
        var address     : String = ""
    }
    
    struct SessionRepresentable {
        var total       : String = ""
        var points      : String = ""
    }
    
}
