//
//  FirebaseUploaderModel.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 04/12/21.
//

import Foundation

// Helper class to upload stuff on Firebase
class FirebaseUploaderModel {
    
    // Init
    init() { }
    
    
    // Methods
    
    // Upload some fake products
    static func uploadProducts() {
        
//        var products = [Product]()
//        
//        products.append(contentsOf: [
//            Product(ID: .notSet, name: "Pennette", category: "Pasta", description: "Italian pennette, 500g", price: Decimal(1.50)),
//            Product(ID: .notSet, name: "Ravioli", category: "Pasta", description: "Italian ravioli, 500g", price: Decimal(2.00)),
//            Product(ID: .notSet, name: "Rigatoni", category: "Pasta", description: "Italian rigatoni, 500g", price: Decimal(2.00)),
//            
//            Product(ID: .notSet, name: "Chocolate cereals", category: "Cereals", description: "", price: Decimal(1.30)),
//            Product(ID: .notSet, name: "Vanilla cereals", category: "Cereals", description: "", price: Decimal(1.30)),
//            Product(ID: .notSet, name: "Honey cereals", category: "Cereals", description: "", price: Decimal(1.50)),
//            
//            Product(ID: .notSet, name: "Digestive", category: "Biscuits", description: "", price: Decimal(1.00)),
//            Product(ID: .notSet, name: "Tea biscuits", category: "Biscuits", description: "Italian rigatoni, 500g", price: Decimal(2.00)),
//            Product(ID: .notSet, name: "Chocolate cookies", category: "Biscuits", description: "", price: Decimal(1.80)),
//        ])
//            
//        for product in products {
//            FirebaseEngine.shared.addNewDocument(collectionPath: .products, data: product.encodeData()) { _ in print("ok") }
//        }
        
    }
    
    // Upload some fake supermarkets
    func uploadSupermarkets() {
        
        /*var supermarkets = [Supermarket]()
        
        supermarkets.append(contentsOf: [
            Supermarket(ID: .notSet, name: "Porta Volta", address: "Porta Volta 12", latitude: 45.4617493, longitude: 9.2120628, openingTime: 1230, closingTime: 4059, productsIDs: []),
            Supermarket(ID: .notSet, name: "Molino", address: "Via Molino delle Armi 13a", latitude: 45.456188, longitude: 9.1845853, openingTime: 1230, closingTime: 4059, productsIDs: []),
            Supermarket(ID: .notSet, name: "Gaudenzio", address: "Via Gaudenzio Ferrai 36", latitude: 45.456299, longitude: 9.174731, openingTime: 1230, closingTime: 4059, productsIDs: []),
            Supermarket(ID: .notSet, name: "Curtatone", address: "Via Curtatone 5-3", latitude: 45.456772, longitude: 9.202281, openingTime: 1230, closingTime: 4059, productsIDs: [])
        ])
        
        for supermarket in supermarkets {
            FirebaseEngine.shared.addNewDocument(collectionPath: .supermarkets, data: supermarket.encodeData()) { _ in }
        }*/
        
    }
    
}
