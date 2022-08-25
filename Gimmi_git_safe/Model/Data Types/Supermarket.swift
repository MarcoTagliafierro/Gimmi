//
//  Supermarket.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 08/12/21.
//

// Supermarket
struct Supermarket: FirebaseElement {
    
    // Properties
    var ID              : String
    
    var name            : String
    var address         : String
    var latitude        : Double
    var longitude       : Double
    var openingTime     : Int
    var closingTime     : Int
    
    var productsIDs     : [String]

    
    // Encode & Decode functions
    func encodeData() -> FirebaseEngine.FBEData {
        
        var dictionary = FirebaseEngine.FBEData()
        
        dictionary[DictionariesFields.name]         = self.name
        dictionary[DictionariesFields.address]      = self.address
        dictionary[DictionariesFields.latitude]     = self.latitude
        dictionary[DictionariesFields.longitude]    = self.longitude
        dictionary[DictionariesFields.openingTime]  = self.openingTime
        dictionary[DictionariesFields.closingTime]  = self.closingTime
        
        let productsIDsDictionary = FirebaseEngine.FBEData()
        dictionary[DictionariesFields.productsIDs] = productsIDsDictionary
        
        return dictionary
        
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        
        let ID                      = data[DictionariesFields.ID] as? String ?? .notSet
        
        let name                    = data[DictionariesFields.name] as? String ?? .notSet
        let address                 = data[DictionariesFields.address] as? String ?? .notSet
        let latitude                = data[DictionariesFields.latitude] as? Double ?? 0.00
        let longitude               = data[DictionariesFields.longitude] as? Double ?? 0.00
        let openingTime             = data[DictionariesFields.openingTime] as? Int ?? 0
        let closingTime             = data[DictionariesFields.closingTime] as? Int ?? 0
        let productIDs              = data[DictionariesFields.productsIDs] as? [String: String] ?? [String: String]()
        
        var productIDsArray = [String]()
        for index in 0 ..< productIDs.count {
            productIDsArray.append(productIDs[String(index)] ?? "")
        }
        
        return Supermarket(
            ID          : ID,
            name        : name,
            address     : address,
            latitude    : latitude,
            longitude   : longitude,
            openingTime : openingTime,
            closingTime : closingTime,
            productsIDs : productIDsArray
        )
        
    }
}

// Equatable conformance
extension Supermarket: Equatable {
    
    static func == (lhs: Supermarket, rhs: Supermarket) -> Bool {
        return lhs.ID == rhs.ID
    }
    
}
