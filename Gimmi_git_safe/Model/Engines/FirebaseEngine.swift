//
//  FirebaseEngine.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 03/12/21.
//

import Foundation
import Firebase


class FirebaseEngine {
    
    
    // TypeAlias
    public typealias FBEData = Dictionary<String, Any>
    
    // Enums
    public enum Collections: String {
        case clientSessions     = "client_sessions"
        case categories         = "categories"
        case products           = "products"
        case supermarkets       = "supermarkets"
        case stripeCustomers    = "stripe_customers"
        case testCollection     = "test_collection"
    }
    
    // Singleton instance
    static let shared: FirebaseEngine = FirebaseEngine()
    
    // Properties
    private let firestore   : Firestore
    private let storage     : Storage
    private let functions   : Functions
    
    
    // Private init
    private init() {
        
        firestore   = Firestore.firestore()
        storage     = Storage.storage()
        functions   = Functions.functions()
        
    }
    
    
    // Methods
    
    // Returns the current timestamp in milliseconds
    private func getTimestamp() -> String {
        
        let now = Date()
        let timestamp = Timestamp(date: now)
        
        return String(timestamp.seconds)
        
    }
    
    /// Inserts a new document (data) in the specified collection
    public func addNewDocument(collectionPath: String, data: FBEData, onCompletion: @escaping (Error?) -> Void) -> DocumentReference {
        
        let reference = firestore.collection(collectionPath).addDocument(data: data) { error in
            onCompletion(error)
        }
        
        return reference

    }
    
    /// Retrieves all the documents contained in the specified collection that have the provided signature
    public func getAll(collectionPath: Collections, onCompletion: @escaping ([FBEData]?) -> Void) {
        
        // Uses the query
        firestore.collection(collectionPath.rawValue).getDocuments(source: .server) { (snapshot, error) in

            if let _ = error {
                onCompletion(nil)
            } else {

                // Creates an array of FBEData from the downloaded snapshot
                var retrievedData = [FBEData]()

                // Each document is copied and enriched with it's ID (which is not originally included in the dictionary itself)
                for document in snapshot!.documents {

                    var dataWithID = document.data()
                    dataWithID[DictionariesFields.ID] = document.documentID

                    retrievedData.append(dataWithID)

                }
                
                if retrievedData.isEmpty {
                    onCompletion(nil)
                } else {
                    onCompletion(retrievedData)
                }

            }

        }

    }
    
    /// Retrieves the specified image
    public func getImage(imageID: String, onCompletion: @escaping (Data?) -> Void) {
        
        let imageRef = storage.reference().child("products_images/\(imageID).png")

        let _ = imageRef.getData(maxSize: 2 * 1024 * 1024 /* 1 MB */) { data, error in

            if let error = error {
                print(error)
                onCompletion(nil)
            } else {
                if let data = data {
                    onCompletion(data)
                } else {
                    onCompletion(nil)
                }
            }

        }

    }
    
}
