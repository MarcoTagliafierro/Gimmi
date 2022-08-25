//
//  CheckoutView.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import Stripe

struct CheckoutView: View {
    
    // Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel           : CheckoutViewModel
    @State          var showCashPaymentView : Bool                  = false
    
    
    // Init
    init(viewModel: CheckoutViewModel) {
        
        self.viewModel = viewModel
        
    }
    
    
    // Body
    var body: some View {
        ZStack(alignment: .leading) {
            
            // Background color
            Color.backgroundColor.ignoresSafeArea()
            
            VStack() {
                
                TitleBar(title: "Checkout", subTitle: "Here there is the recap of your shopping session") {
                    dismiss()
                }
                
                List() {
                    ForEach(viewModel.shoppingList) { product in
                        VerticalProductCell(name: product.productName, price: product.productPrice, count: product.productCount, image: product.productImage, editable: false) {
                            isIncrement in

                            if isIncrement {
                                self.viewModel.addProduct(productCode: product.productID)
                            } else  {
                                self.viewModel.decreaseProduct(productCode: product.productID)
                            }
                        }
                    }
                }

                Spacer()
                
                VStack(spacing: 0.0) {
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
                    if let paymentSheet = viewModel.paymentSheet {      // [2nd] Pay button
                        PaymentSheet.PaymentButton(
                            paymentSheet: paymentSheet,
                            onCompletion: viewModel.onPaymentCompletion
                        ) {
                            StandardButtonLabel(title: "Pay", isActive: viewModel.disablePayButton == false)
                        }.disabled(viewModel.disablePayButton)
                    } else {                                            // [1st] Proceed to payment button(s)
                        
                        HStack(spacing: .stdBorder) {
                            
                            // Cash payment
                            Button(action: {
                                self.showCashPaymentView = true
                            }, label: {
                                Image(systemName: "banknote")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .padding(.stdBorder)
                            })
                                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .button)
                                .background(viewModel.disableReqButton ? Color.gray : Color.green)
                                .foregroundColor(Color.textColor)
                                .cornerRadius(CGFloat(10))
                                .shadow(radius: 3)
                                .padding(.top, .stdBorder)
                                .padding(.bottom, .stdBorder)
                                .padding(.leading, .stdBorder)
                                .frame(maxHeight: CGFloat(90))
                                .disabled(viewModel.disableReqButton)
                            
                            // Card payment
                            Button(action: {
                                viewModel.requestPayment()
                            }, label: {
                                // While loading the rotating icon is showed
                                if (viewModel.disableReqButton) {
                                    ProgressView()
                                } else {
                                    Image(systemName: "creditcard")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(.stdBorder)
                                }
                            })
                                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .button)
                                .background(viewModel.disableReqButton ? Color.gray : Color.secondaryColor)
                                .foregroundColor(Color.textColor)
                                .cornerRadius(CGFloat(10))
                                .shadow(radius: 3)
                                .padding(.top, .stdBorder)
                                .padding(.bottom, .stdBorder)
                                .padding(.trailing, .stdBorder)
                                .frame(maxHeight: CGFloat(90))
                                .disabled(viewModel.disableReqButton)
                        }
                    }
                    
                }
                
            }
        }
            
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.alertMessage),
                    primaryButton: .destructive(Text("Proceed")) {
                        dismiss()
                    },
                    secondaryButton: .cancel(Text("Cancel")))
            }
        
            .navigationBarHidden(true) // Hides the navigationView title bar
        
            NavigationLink(isActive: $showCashPaymentView, destination: { NavigationLazyView(ReceiptViewCash(viewModel: viewModel.getReceiptViewModel())) }, label: {})
            NavigationLink(isActive: $viewModel.showReceiptView, destination: { NavigationLazyView(ReceiptView(viewModel: viewModel.getReceiptViewModel())) }, label: {})
        
    }
    
}

