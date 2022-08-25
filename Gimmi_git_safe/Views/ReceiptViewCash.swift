//
//  ReceiptViewCash.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 14/07/22.
//

import SwiftUI

struct ReceiptViewCash: View {
    
    // Properties
    @Environment(\.dismiss) var dismiss
    
    // ViewModel
    @ObservedObject var viewModel           : ReceiptViewModel
    
    
    // Init
    init(viewModel: ReceiptViewModel) {
        self.viewModel = viewModel
    }
    
    
    // Body
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                
                // Background color
                Color.backgroundColor.ignoresSafeArea()
                
                VStack() {
                    TitleBar(title: "Receipt", subTitle: "Use the QrCode at the bottom to pay at the automatic cashier") {
                        NavigationUtil.popToRootView()
                    }
                    
                    ScrollView() {
                        
                        ZStack() {
                            
                            // Background color
                            Color.white.ignoresSafeArea()
                            
                            VStack(alignment: .center) {
                                
                                // Top part
                                Text(viewModel.supermarketRepresentable.name)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.black)
                                Text(viewModel.supermarketRepresentable.address)
                                    .font(.footnote)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.black)
                                    .padding(.bottom, 20.0)
                                
                                // Products
                                ForEach(viewModel.shoppingList) { product in
                                    ReceiptCell(count: product.count, productName: product.name, price: product.price)
                                }
                                
                                // Bottom part
                                HStack() {
                                    
                                    Text("Total")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.black)
                                    
                                    Text(viewModel.sessionRepresentable.total + " €")
                                        .font(.headline)
                                        .frame(width: 60, alignment: .trailing)
                                        .foregroundColor(.black)
                                }
                                    .padding(.top, 10.0)
                                
                                HStack() {
                                    
                                    Text("Points")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.black)
                                    
                                    Text(viewModel.sessionRepresentable.points)
                                        .font(.subheadline)
                                        .frame(width: 60, alignment: .trailing)
                                        .foregroundColor(.black)
                                }
                                    .padding(.bottom, 40.0)
                                
                                let qrCodeSize = geometry.size.width * 0.65
                                Image("qr-code")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: qrCodeSize, height: qrCodeSize, alignment: .center)
                                
                            }.padding(.stdBorder)
                            
                        }
                            .padding(.leading, .bigBorder)
                            .padding(.trailing, .bigBorder)
                    }
                
                }
                    .navigationBarHidden(true) // Hides the navigationView title bar

            }
        }
    }
    
}

// Product Cell
private struct ReceiptCell: View {
    
    var count       : String
    var productName : String
    var price       : String
    
    var body: some View {
        
        HStack() {
            Text(count + " x")
                .font(.footnote)
                .frame(width: 40.0, alignment: .leading)
                .foregroundColor(.black)
            Text(productName)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.black)
            Text(price + " €")
                .font(.body)
                .frame(width: 50.0, alignment: .trailing)
                .foregroundColor(.black)
        }
    
    }
    
}
