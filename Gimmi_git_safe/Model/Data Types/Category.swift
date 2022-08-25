//
//  Category.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 18/04/22.
//

import Foundation

// Category
struct Category: FirebaseElement {
    
    // Properties
    var ID              : String
    var name            : String
    
    
    // Encode & Decode functions
    func encodeData() -> FirebaseEngine.FBEData {
        
        var dictionary = FirebaseEngine.FBEData()
        dictionary[DictionariesFields.name] = self.name
        return dictionary
        
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        
        let ID      = data[DictionariesFields.ID] as? String ?? .notSet
        let name    = data[DictionariesFields.name] as? String ?? .notSet
        
        return Category(
            ID: ID,
            name: name
        )
        
    }

}

// Equatable conformance
extension Category: Equatable {
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}
