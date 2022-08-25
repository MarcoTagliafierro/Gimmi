//
//  ClientSession.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 07/07/22.
//

import Foundation

// ClientSession
struct ClientSession: FirebaseElement {
    
    // Properties
    var ID              : String
    
    var clientID        : String
    var supermarket     : Supermarket?
    var date            : String
    
    var productIDs      : [String]

    
    // Encode & Decode functions
    func encodeData() -> FirebaseEngine.FBEData {
        
        var dictionary = FirebaseEngine.FBEData()
        
        dictionary[DictionariesFields.clientID]     = self.clientID
        dictionary[DictionariesFields.supermarket]  = self.supermarket?.ID ?? .notSet
        dictionary[DictionariesFields.date]         = self.date
        
        var productsIDsDictionary = FirebaseEngine.FBEData()
        for (index, productID) in productIDs.enumerated() {
            productsIDsDictionary["\(index)"] = productID
        }
        dictionary[DictionariesFields.productsIDs] = productsIDsDictionary
        
        return dictionary
        
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        
        let ID                      = data[DictionariesFields.ID] as? String ?? .notSet
        
        let clientID                = data[DictionariesFields.clientID] as? String ?? .notSet
        let date                    = data[DictionariesFields.date] as? String ?? .notSet
        let productIDs              = data[DictionariesFields.productsIDs] as? [String: String] ?? [String: String]()
        
        var productIDsArray = [String]()
        for index in 0 ..< productIDs.count {
            productIDsArray.append(productIDs[String(index)] ?? "")
        }
        
        return ClientSession(
            ID          : ID,
            clientID    : clientID,
            supermarket : nil,
            date        : date,
            productIDs  : productIDsArray
        )
        
    }
}
