//
//  ShoppingList.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 08/12/21.
//

import Foundation

// Shopping session
class ShoppingSession: FirebaseElement {
    
    typealias Entry = (item: Product, count: Int)
    
    // Properties
    var ID          : String
    var timestamp   : Double
    
    @Published var supermarket : Supermarket?
    @Published var entries     : [Entry]
    
    // Computed properties
    var entriesCount  : Int {
        get {
            var count = 0
            for entry in entries { count += entry.count }
            return count
        }
    }
    
    var totalCost   : Decimal {
        get {
            var totalCost = Decimal(0)
            
            for product in entries {
                totalCost += product.item.price * Decimal(product.count)
            }
            
            return totalCost
        }
    }
    
    var totalPoints : Int {
        get {
            return entries.map{$0.item.points * $0.count}.reduce(0, +)
        }
    }
    
    
    // Init
    init() {
        
        self.ID = .notSet
        
        self.supermarket = nil
        self.timestamp = NSDate().timeIntervalSince1970
        self.entries = [Entry]()
        
    }
    
    
    // Methods
    
    /// Add a product to the shopping session in the specified number
    ///
    /// - Parameter product: the product to be added
    /// - Parameter count: the istances of product to be added
    func add(product: Product, count: Int = 1) {
        
        guard count >= 1 else {
            assertionFailure("[Error in ShoppingSession] Count must be a positive number greater than 1")
            return
        }
        
        // Check if the product is already present, if so
        // it's count is incremented, otherwise a new entry
        // is created and appended to the array of entries
        if let index = entries.firstIndex(where: ({ $0.item == product })) {
            entries[index].count += count
        } else {
            let newEntry = (product, count)
            entries.insert(newEntry, at: 0)
        }
        
    }
    
    /// Decrease the count of a product
    ///
    ///  - Parameter product: product to be reduced in count
    func decrease(product: Product) {
      
        guard let index = entries.firstIndex(where: ({$0.item == product})) else {
            assertionFailure("[Error in ShoppingSession] There's no entry of such product")
            return
        }
        
        entries[index].count -= 1
        if entries[index].count == 0    {
            entries.remove(at: index)
        }

    }
    
    /// Set the selected supermarket
    ///
    func setSelectedSupermarket(to supermarket: Supermarket?) {
        self.supermarket = supermarket
    }
    
    /// Reset the current shopping session
    ///
    func resetSession() {
        
        timestamp = NSDate().timeIntervalSince1970
        entries = [Entry]()
        
    }
    
    /// Returns a string representing the price of the product
    static func stringTotalPrice(of entry: Entry) -> String {
        return stringTotalPrice(of: entry.item.price * Decimal(entry.count))
    }
    
    /// Returns a string representing the price passed as parameter
    static func stringTotalPrice(of value: Decimal) -> String {
        
        var normalizedPrice =  value.description
        let components = normalizedPrice.split(separator: ".")
            
        if components.count == 1 {
            normalizedPrice = components.first! + ".00"
        } else if components.last!.count != 2 {
            normalizedPrice = normalizedPrice + "0"
        }
        
        return normalizedPrice
        
    }
    
    /// Upload the current session to Firebase
    func uploadSession(onCompletion: @escaping (Error?)->()) {
        let collectionPath = FirebaseEngine.Collections.clientSessions.rawValue
        let _ = FirebaseEngine.shared.addNewDocument(collectionPath: collectionPath, data: encodeData()) { onCompletion($0) }
    }
    
    // Protocol conformance
    func encodeData() -> FirebaseEngine.FBEData {
        
        guard supermarket != nil else {
            assertionFailure("[Error in ShoppingSession] Supermarket must be defined")
            return FirebaseEngine.FBEData()
        }
        
        var dictionary = FirebaseEngine.FBEData()
        
        // Convert the list of (products, count) in a dictionary
        var entriesDictionary = FirebaseEngine.FBEData()
        for (index, entry) in entries.enumerated() {
            
            var entryData = FirebaseEngine.FBEData()
            
            entryData[DictionariesFields.product]   = entry.item.name
            entryData[DictionariesFields.count]     = entry.count
            
            entriesDictionary[String(index)] = entryData
            
        }
        
        // Add data to the main dictionary
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        let formattedDate = dateFormatter.string(from: date)
        
        dictionary[DictionariesFields.supermarket]  = self.supermarket!.name
        dictionary[DictionariesFields.entries]      = entriesDictionary
        dictionary[DictionariesFields.date]         = formattedDate
        dictionary[DictionariesFields.total]        = ShoppingSession.stringTotalPrice(of: self.totalCost)
        dictionary[DictionariesFields.points]       = self.totalPoints
        
        return dictionary
        
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        return ShoppingSession()
    }
    
}

// Shopping session data, used to retrieve past sessions
class ShoppingSessionData: FirebaseElement {
    
    
    typealias Entry = (item: String, count: Int)
    
    // Properties
    var ID          : String
    var timestamp   : String
    
    var supermarket : String
    var entries     : [Entry]
    
    var totalCost   : String
    var totalPoints : Int
    
    
    // Init
    init() {
        self.ID             = .notSet
        self.timestamp      = .notSet
        self.supermarket    = .notSet
        self.entries        = [Entry]()
        self.totalCost      = .notSet
        self.totalPoints    = 0
    }
    
    
    // Methods
    func encodeData() -> FirebaseEngine.FBEData {
        return FirebaseEngine.FBEData()
    }
    
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement {
        
        let shoppingSessionData = ShoppingSessionData()
        
        shoppingSessionData.ID          = data[DictionariesFields.ID] as? String ?? .notSet
        shoppingSessionData.timestamp   = data[DictionariesFields.date] as? String ?? .notSet
        shoppingSessionData.supermarket = data[DictionariesFields.supermarket] as? String ?? .notSet
        shoppingSessionData.totalCost   = data[DictionariesFields.total] as? String ?? .notSet
        shoppingSessionData.totalPoints = data[DictionariesFields.points] as? Int ?? 0
        
        let entriesData = data[DictionariesFields.entries] as? FirebaseEngine.FBEData ?? FirebaseEngine.FBEData()
        for index  in 0 ..< entriesData.count {
            let entryData = entriesData[String(index)] as? FirebaseEngine.FBEData ?? FirebaseEngine.FBEData()
            
            let name    = entryData[DictionariesFields.product] as? String
            let count   = entryData[DictionariesFields.count] as? Int
            
            if let name = name, let count = count {
                shoppingSessionData.entries.append(Entry(item: name, count: count))
            }
        }
        
        return shoppingSessionData
        
    }
    
}
