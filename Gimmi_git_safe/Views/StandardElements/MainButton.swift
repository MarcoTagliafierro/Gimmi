//
//  MainButton.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 22/12/21.
//

import SwiftUI

struct StandardButton: View {
    
    var title       : String
    var isActive    : Bool = true
    var action      : () -> ()
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            StandardButtonLabel(title: title, isActive: isActive)
        })
            .disabled(!isActive)
    }
    
}

struct StandardButtonLabel: View {
    
    var title       : String
    var isActive    : Bool
    
    var body: some View {
       ElementTitle(text: title)
            .frame(maxWidth: .infinity, maxHeight: .button)
            .background(isActive ? Color.secondaryColor : Color.gray)
            .foregroundColor(Color.textColor)
            .cornerRadius(CGFloat(10))
            .shadow(radius: 3)
            .padding(.stdBorder)
            .frame(maxWidth: .infinity, maxHeight: CGFloat(90))
    }
    
}
