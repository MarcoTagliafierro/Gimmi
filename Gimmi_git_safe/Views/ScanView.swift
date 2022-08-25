//
//  ScanView.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI


struct ScanView: View {
    
    // Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel   : ScanViewModel
    
    // State variables
    @State var showScannerView      = false
    @State var showCheckoutView     = false
    @State var showAlert            = false
    
    // Properties
    struct ScannerSheet: View {
        
        @Binding var isPresentingScanner    : Bool
                 var onScan                 : (String) -> ()
        
        var body: some View {
            
            CodeScannerView(
                codeTypes: [.qr, .code128],
                completion: { result in
                    
                    switch result {
                    case .success(let result):
                        self.onScan(result.string)
                        self.isPresentingScanner = false
                    case .failure(_):
                        print("Error")
                    
                    }
                    
                }
            )
            
        }
        
    }
    
    // Init
    init(viewModel: ScanViewModel)  {
        self.viewModel = viewModel
    }
    
    // Body
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            // Background Color
            Color.backgroundColor.ignoresSafeArea()
            
            VStack() {
                
                TitleBar(title: "Shopping List", subTitle: "Scan the products you want to buy") {
                    self.showAlert = true
                }
                
                // Items list
                List {
                    
                    ForEach(viewModel.shoppingList) { product in
                        
                        VerticalProductCell(name: product.productName, price: product.productPrice, count: product.productCount, image: product.productImage) { isIncrement in
                            if isIncrement {
                                self.viewModel.addProduct(productCode: product.productID)
                            } else {
                                self.viewModel.decreaseProduct(productCode: product.productID)
                            }
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 0.0) {
                
                    // Shopping infos
                    VStack(spacing: 10.0) {
                        
                        // Points
                        HStack(alignment: .center) {
                            ElementText(text: "Points")
                            Spacer()
                            ElementText(text: viewModel.points, fontWeight: .medium)
                        }
                            .padding(.top, .stdBorder)
                            .padding(.leading, .stdBorder)
                            .padding(.trailing, .stdBorder)
                            .padding(.bottom, .smallBorder)
                        
                        // Total
                        HStack(alignment: .center) {
                            ElementSubtitle(text: "Total")
                            Spacer()
                            ElementText(text: "€ ")
                            ElementText(text: viewModel.total, fontWeight: .bold)
                        }
                        .padding(.leading, .stdBorder)
                        .padding(.trailing, .stdBorder)
                        .padding(.bottom, .stdBorder)
                        
                    }
                        .frame(maxWidth: .infinity, minHeight: 0)
                        .background(Color.secondaryDarkColor)
                        .cornerRadius(.radius)
                        .shadow(radius: 3)
                        .padding(.leading, .stdBorder)
                        .padding(.trailing, .stdBorder)
                    
                    
                    // Buttons
                    HStack(spacing: 0.0) {
                        
                        StandardButton(title: "Scan") {
                            self.showScannerView = true
                            viewModel.addTestProducts() // Does something only in DEBUG
                        }
                        
                        Button(action: {
                            self.showCheckoutView = true
                        }, label: {
                            Image(systemName: "arrow.forward")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .padding(.stdBorder)
                        })
                            .frame(maxWidth: .button, maxHeight: .button)
                            .background(viewModel.canProceed ? Color.secondaryColor : Color.gray)
                            .foregroundColor(Color.textColor)
                            .cornerRadius(CGFloat(10))
                            .shadow(radius: 3)
                            .padding(.top, .stdBorder)
                            .padding(.bottom, .stdBorder)
                            .padding(.trailing, .stdBorder)
                            .frame(maxHeight: CGFloat(90))
                            .disabled(!viewModel.canProceed)
                        
                    }
                    
                }
                
            }
            
        }
            // Scanner
            .sheet(isPresented: $showScannerView) {
                ScannerSheet(isPresentingScanner: $showScannerView) { productCode in
                    viewModel.addProduct(productCode: productCode)
                }
            }
        
            // Go back alert
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Attention"),
                    message: Text("By going back your current shopping list will be removed"),
                    primaryButton: .destructive(Text("Proceed")) {
                        viewModel.resetAppleWatchState()
                        dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancel")))
            }
            
            .navigationBarHidden(true) // Hides the navigationView title bar
        
            NavigationLink(isActive: $showCheckoutView, destination: { CheckoutView(viewModel: viewModel.getCheckoutViewModel()) }, label: {})
        
    }
    
}


