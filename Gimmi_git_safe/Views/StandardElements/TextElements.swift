//
//  TextElements.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 30/11/21.
//

import SwiftUI


// Pages' title
struct PageTitle: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .font(Font.system(size: 35))
            .fontWeight(.bold)
            .foregroundColor(.textColor)
    }
    
}


// Pages' subtitle
struct PageSubtitle: View {
    
    var text        : String
    var fontWeight  : Font.Weight = .bold
    var color       : Color = .textColor
    
    var body: some View {
        Text(text)
            .font(Font.system(size: 26))
            .fontWeight(.bold)
            .foregroundColor(color)
    }
    
}

// Big text element
struct ElementTitle: View {
    
    var text        : String
    var fontWeight  : Font.Weight = .medium
    var color       : Color = .textColor
    
    var body: some View {
        Text(text)
            .font(Font.system(size: 22))
            .fontWeight(fontWeight)
            .foregroundColor(color)
    }
    
}

// Relevant text element
struct ElementSubtitle: View {
    
    var text        : String
    var fontWeight  : Font.Weight = .medium
    var color       : Color = .textColor
    
    var body: some View {
        Text(text)
            .font(Font.system(size: 19))
            .fontWeight(fontWeight)
            .foregroundColor(color)
    }
    
}

// Text element
struct ElementText: View {
    
    var text        : String
    var fontWeight  : Font.Weight = .regular
    var color       : Color = .textColor
    
    var body: some View {
        Text(text)
            .font(Font.system(size: 17))
            .fontWeight(fontWeight)
            .foregroundColor(color)
    }
    
}
