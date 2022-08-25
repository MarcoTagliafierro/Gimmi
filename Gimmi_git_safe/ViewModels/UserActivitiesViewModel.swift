//
//  UserActivitiesViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import Foundation

// ViewModel for UserActivitiesView
class UserActivitiesViewModel: ObservableObject {
    
    // Properties
    private var appState    : AppState
    
    // Published properties
    @Published private(set) var activitiesRepresentables    : [ActivityRepresentable] = []
    
    
    // Init
    init(appState: AppState) {
        self.appState = appState
        downloadData()
    }
    
    
    // Methods
    
    private func downloadData() {
        
        FirebaseEngine.shared.getAll(collectionPath: .clientSessions) { data in
            
            if let data = data {
                
                var shoppingSessions = [ShoppingSessionData]()
                for datum in data {
                    let shoppingSessionData = ShoppingSessionData.decodeData(data: datum) as! ShoppingSessionData
                    shoppingSessions.append(shoppingSessionData)
                }
                
                for session in shoppingSessions {
                    var products = [ProductRepresentable]()
                    for entry in session.entries {
                        let productRepresentable = ProductRepresentable(name: entry.item, count: "\(entry.count) x")
                        products.append(productRepresentable)
                    }
                    
                    let activityRepresentable = ActivityRepresentable(date: session.timestamp, products: products, totalCost: session.totalCost, totalPoints: String(session.totalPoints))
                    self.activitiesRepresentables.append(activityRepresentable)
                }
                
            }
            
        }
        
    }
    
}

// View Representables
extension UserActivitiesViewModel {
    
    struct ProductRepresentable: Identifiable {
        var name        : String
        var count       : String
        
        var id: UUID = UUID()
    }
    
    struct ActivityRepresentable: Identifiable {
        var date        : String
        var products    : [ProductRepresentable]
        var totalCost   : String
        var totalPoints : String
        
        var id: UUID = UUID()
    }
    
}
