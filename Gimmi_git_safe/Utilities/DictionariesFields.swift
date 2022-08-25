//
//  DictionariesFields.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 03/12/21.
//

import Foundation

struct DictionariesFields {
    
    // Common
    static let ID           = "ID"
    
    // User
    static let clientID     = "clientID"
    
    // Product
    static let name         = "name"
    static let category     = "category"
    static let description  = "description"
    static let price        = "price"
    static let points       = "points"
    
    // Supermarkets
    static let address          = "address"
    static let latitude         = "latitude"
    static let longitude        = "longitude"
    static let openingTime      = "openingTime"
    static let closingTime      = "closingTime"
    static let productsIDs      = "productsIDs"
    
    // ShoppingSession
    static let user             = "user"
    static let supermarket      = "supermarket"
    static let entries          = "entries"
    static let product          = "product"
    static let count            = "count"
    static let date             = "date"
    static let total            = "total"
    //static let points           = "points"
    
}
