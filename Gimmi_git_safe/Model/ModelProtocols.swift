//
//  ModelProtocols.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 30/11/21.
//

import Foundation


protocol FirebaseElement {
    
    // ID
    var ID: String { get set }
    
    // Code & Decode functions
    func encodeData() -> FirebaseEngine.FBEData
    static func decodeData(data: FirebaseEngine.FBEData) -> FirebaseElement
    
}


