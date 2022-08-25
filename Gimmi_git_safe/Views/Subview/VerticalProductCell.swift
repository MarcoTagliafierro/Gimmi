//
//  VerticalProductCell.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 24/03/22.
//

import SwiftUI


// Product cell
struct VerticalProductCell: View {
    
    var name        : String
    var price       : String
    var count       : Int
    var image       : Data?
    var highlight   = true
    var editable    = true
    
    var onAction    : (_ isIncrement: Bool) -> ()
    
    
    var body: some View {
        
        HStack(alignment: .center) {
                
            // Photo and info
            if let image = image {
                Image(uiImage: UIImage(data: image)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: CGFloat(60.0), height: CGFloat(75.0), alignment: .center)
                    .cornerRadius(.radius)
            }
            
            VStack(alignment: .leading) {
                ElementSubtitle(text: name, fontWeight: .medium)
                
                Spacer()
                
                Text("\(count) item\(count == 1 ? "" : "s")")
                
                HStack {
                    Text("€")
                        .font(Font.system(size: 13))
                    Text(price)
                }
            }
            
            Spacer()
        
            // Increment/decrement button
            if editable {
                VStack(alignment: .trailing) {
                    Spacer()
                    Stepper("", onIncrement: {
                        onAction(true)
                    }, onDecrement: {
                        onAction(false)
                    }).labelsHidden()
                }
            }
            
        }
            .listRowInsets(.smallInsets)
        
    }
}
