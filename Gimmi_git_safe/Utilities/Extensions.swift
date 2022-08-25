//
//  Extensions.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 03/12/21.
//

import SwiftUI

// String extensions:
// - added notSet standard string to be used whit non
//   optional strings
extension String {
    static let notSet = "notSet"
}

// Color extensions:
// - added the application palette with color sampled
//   from the assets folder
extension Color {
    
    static let backgroundColor      = Color("BackgroundColor")
    static let darkBackgroundColor  = Color("DarkBackgroundColor")
    
    static let textColor            = Color("TextColor")
    static let secondaryTextColor   = Color("SecondaryTextColor")
    
    static let primaryColor         = Color("PrimaryColor")
    //static let primaryLightColor    = Color("PrimaryLightColor")
    static let secondaryColor       = Color("SecondaryColor")
    static let secondaryDarkColor   = Color("SecondaryDarkColor")
    
    static let shadowColor          = Color("ShadowColor")
    
}

// UIApplication extensions
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
