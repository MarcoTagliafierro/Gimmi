//
//  Product.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 30/11/21.
//

import SwiftUI

// Product
struct Product: FirebaseElement {
    
    // Properties
    var ID              : String
    
    var name            : String
    var category        : String 
    var description     : String
    var price           : Decimal
    var points          : Int
    var image           : Data?    = nil
    
    init(ID: String, name: String, category: String, description: String, price: Decimal, points: Int, image: Data? = nil) {
        
        self.ID = ID
        self.name = name
        self.category = category
        self.description = description
        self.price = price
        self.points = points
        self.image = image
        
    }
    
    // Encode & Decode functions
    func encodeData() -> FirebaseEngine.FBEData {
        
        var dictionary = FirebaseEngine.FBEData()
        
        dictionary[DictionariesFields.name]         = self.name
        dictionary[DictionariesFields.category]     = self.category
        dictionary[DictionariesFields.description]  = self.description
        dictionary[DictionariesFields.price]        = self.price
        dictionary[DictionariesFields.points]       = self.points
        
        return dictionary
        
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        
        let ID              = data[DictionariesFields.ID] as? String ?? .notSet
        
        let name            = data[DictionariesFields.name] as? String ?? .notSet
        let category        = data[DictionariesFields.category] as? String ?? .notSet
        let description     = data[DictionariesFields.description] as? String ?? .notSet
        let priceAsDouble   = data[DictionariesFields.price] as? Double ?? 0.00
        let priceAsDecimal  = Decimal(priceAsDouble)
        let points          = data[DictionariesFields.points] as? Int ?? 0
        
        return Product(
            ID: ID,
            name: name,
            category: category,
            description: description,
            price: priceAsDecimal,
            points: points
        )
        
    }
    
}

// Equatable conformance
extension Product: Equatable {
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}
