//
//  CashPaymentView.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 28/03/22.
//

import SwiftUI

struct CashPaymentView: View {
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                // Background color
                Color.backgroundColor.ignoresSafeArea()
                
                VStack(alignment: .center, spacing: .bigBorder) {
                    
                    let qrCodeWidth = geometry.size.width * 0.7
                    
                    PageSubtitle(text: "Scan the following QR Code in one of the checkout points of the store")
                    Image("qr-code")
                        .resizable()
                        .scaledToFill()
                        .frame(width: qrCodeWidth, height: qrCodeWidth, alignment: .center)
                    
                }
                    .padding(.stdBorder)
                
            }
            
        }
        
    }
    
}
