//
//  PaymentEngine.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 22/03/22.
//

import Foundation
import Firebase
import Stripe

class PaymentEngine: ObservableObject {
    
    func preparePayment(uid: String, amountInDecimal: Decimal, currency: String, onCompletion: @escaping (PaymentSheet) -> ()) {
        
        // The amount must be an integer number, eg. 8.50 euros becames 850
        let amount = NSDecimalNumber(decimal: amountInDecimal * Decimal(100)).intValue
        
        // Add a new document with a generated ID
        let data: FirebaseEngine.FBEData = [
            "currency": currency,
            "amount": amount
        ]
        
        var reference: DocumentReference? = nil
        reference = FirebaseEngine.shared.addNewDocument(collectionPath: ("\(FirebaseEngine.Collections.stripeCustomers.rawValue)/\(uid)/payments"), data: data) { error in
            if let error = error {
                print("[ERROR] PaymentEngine: error adding document: \(error)")
            } else {
                print("[CHECK] PaymentEngine: document added with ID: \(reference!.documentID)")
            }
        }
        
        reference?.addSnapshotListener { documentSnapshot, error in
            
            guard let document = documentSnapshot else {
                print("[ERROR] PaymentEngine: error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("[ERROR] PaymentEngine: document data was empty.")
                return
            }
            
            print("[CHECK] PaymentEngine: current data: \(data)")
            
            let customer = data["customer"]
            let ephemeralKey = data["ephemeralKey"]
            let clientSecret = data["client_secret"]
            
            // If all the checks are met, a PaymentSheet instance is created
            if (customer != nil && ephemeralKey != nil && clientSecret != nil) {
                
                var configuration = PaymentSheet.Configuration()
                configuration.customer = .init(id: customer as! String, ephemeralKeySecret: ephemeralKey as! String)
                
                // When a payment sheet is available, the loading is terminated
                DispatchQueue.main.async {
                    let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret as! String, configuration: configuration)
                    onCompletion(paymentSheet)
                }
                
            }
            
        }
    }
    
}
