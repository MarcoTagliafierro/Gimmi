//
//  UserProfileView.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices


struct UserProfileView: View {
    
    // Properties
    @Environment(\.dismiss) var dismiss
                            var dismissable : Bool 
    
    @ObservedObject         var viewModel               : UserProfileViewModel
    @State                  var appleSignInDelegates    : AuthenticationEngine  = AuthenticationEngine.shared
    
    
    // Init
    init(viewModel: UserProfileViewModel, dismissable: Bool = true) {
        
        self.dismissable = dismissable
        self.viewModel = viewModel
        
        self.appleSignInDelegates.onCompletion = viewModel.onCompletion
        
    }
    
    
    // Body
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            //BackgroundColor
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack() {
                
                // Title
                if dismissable {
                    TitleBar(title: "User Profile") { dismiss() }
                } else {
                    TitleBar(title: "User Profile")
                }
                
                // Settings fields
                VStack(alignment: .leading, spacing: .stdBorder) {
                    
                    UserField(title: "First name", binding: $viewModel.name)
                    UserField(title: "Surname", binding: $viewModel.surname)
                    UserField(title: "Address", binding: $viewModel.address)
                    UserField(title: "Phone number", keyboard: .numberPad, binding: $viewModel.phoneNumber)
                    UserField(title: "Fidelity card number", placeholder: "xxxxxx", keyboard: .numberPad, binding: $viewModel.fidelityCard)
                    
//                    HStack(alignment: .center) {
//                        Image(systemName: "checkmark.circle")
//                            .resizable()
//                            .scaledToFill()
//                            .foregroundColor(.textColor)
//                            .frame(width: 18, height: 18, alignment: .center)
//                        ElementTitle(text: "You are logged in")
//                    }.opacity(viewModel.hideLoginButtons ? 1 : 0)
                    
                    if viewModel.hideLoginButtons {
                        HStack(alignment: .center) {
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(.textColor)
                                .frame(width: 18, height: 18, alignment: .center)
                            ElementTitle(text: "You are logged in")
                        }
                    } else {
                        HStack(alignment: .center) {
                            Image(systemName: viewModel.termsChecked ? "checkmark.square.fill" : "square")
                                .foregroundColor(viewModel.termsChecked ? Color(UIColor.systemBlue) : Color.secondary)
                                .onTapGesture {
                                    self.viewModel.termsChecked.toggle()
                                }
                            Link("Accept the terms and conditions", destination: URL(string: "https://www.google.com")!)
                                .foregroundColor(.textColor)
                        }
                    }
                    
                }
                    .padding(.leading, .stdBorder)
                    .padding(.trailing, .stdBorder)

                Spacer()
                
                // Buttons
                if viewModel.hideLoginButtons { // Save button showed
                    
                    StandardButton(title: "Save values", isActive: viewModel.userCanExit) {
                        self.viewModel.saveValues()
                        dismiss()
                    }
                    
                } else { // Login buttons showed
                    
                    Button(action: {    // Apple
                        showAppleLogin()
                    }, label: {
                        ElementSubtitle(text: " Sign in with Apple", color: .white)
                    })
                        .frame(maxWidth: .infinity, maxHeight: 60.0, alignment: .center)
                        .background(.black)
                        .cornerRadius(.radius)
                        .padding(.leading, .stdBorder)
                        .padding(.trailing, .stdBorder)
                    
                    Button(action: {    // Google
                        viewModel.requestSignInWithGoogle()
                    }, label: {
                        ElementSubtitle(text: "Sign in with Google", color: .black)
                    })
                        .frame(maxWidth: .infinity, maxHeight: 60.0, alignment: .center)
                        .background(.white)
                        .cornerRadius(.radius)
                        .padding(.leading, .stdBorder)
                        .padding(.trailing, .stdBorder)
                    
                }
                
            }
                .ignoresSafeArea(.keyboard)
                .onTapGesture {
                    // Whenever the user taps outside the text field the keyboard will be dismissed
                    UIApplication.shared.endEditing()
                }
                .alert("Login error", isPresented: $viewModel.showAlert) {
                    Button("Retry") { }
                } message: {
                    Text("An error occurred during the data retrival process, please retry later")
                }
            
        }
        // Needed for Google SignIn procedure
        .onOpenURL() { url in
            GIDSignIn.sharedInstance.handle(url)
        }
        
    }
    
    private func showAppleLogin() {
        
        let request = AuthenticationEngine.shared.forgeLoginWithAppleRequest()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = appleSignInDelegates
        controller.performRequests()
        
    }
    
}


private struct UserField: View  {
    
    var title       : String
    var placeholder : String            = "Required"
    var keyboard    : UIKeyboardType    = UIKeyboardType.default
    var onSubmit    : (()->())?         = nil
    
    var binding: Binding<String>
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 1) {
        
            HStack() {
                ElementTitle(text: title)
                Spacer()
            }
            
            TextField(
                placeholder,
                text: binding
            )
                .disableAutocorrection(true)
                .keyboardType(keyboard)
                .foregroundColor(.secondaryTextColor)
                .onSubmit {
                    if let onSubmit = onSubmit { onSubmit() }
                }
        
        }.frame(maxWidth: .infinity, minHeight: .stdBlock, maxHeight: .stdBlock, alignment: .topLeading)
    
    }
    
}
