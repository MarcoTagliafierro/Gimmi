//
//  MenuView.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 13/12/21.
//

import SwiftUI

struct MenuView: View {
    
    // ViewModel
    @ObservedObject var viewModel: ProductsListViewModel
    
    // State variables
    @Binding var menuIsVisible          : Bool
    
    @State var showingUserProfile       = false
    @State var showingUserActivities    = false
    @State var showingStoresView        = false
    
    // Body
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
                
                PageSubtitle(text: "Menu")
                    .padding(.top, .stdBorder)
                
                MenuElement(imageName: "person", title: "User profile")
                    .padding(.top, .stdBorder)
                    .onTapGesture {
                        showingUserProfile.toggle()
                    }
                    .sheet(isPresented: $showingUserProfile) {
                        UserProfileView(viewModel: viewModel.getUserProfileViewModel())
                    }
                
                MenuElement(imageName: "archivebox", title: "Activities")
                    .onTapGesture {
                        showingUserActivities.toggle()
                    }
                    .sheet(isPresented: $showingUserActivities) {
                        UserActivitiesView(viewModel: viewModel.getUserActivitiesViewModel())
                    }
                
                MenuElement(imageName: "location.magnifyingglass", title: "Supermarkets")
                    .onTapGesture {
                        showingStoresView.toggle()
                    }
                    .sheet(isPresented: $showingStoresView) {
                        StoresView(viewModel: viewModel.getStoresViewModel())
                    }
                
                Spacer()
                
            }
                .padding(.leading, 20)
                .background(.ultraThinMaterial)
            
        }
        
    }
    
}

private struct MenuElement: View {
    
    var imageName   : String
    var title       : String
    
    var body: some View {
        
        HStack {
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .foregroundColor(Color.textColor)
            
            ElementTitle(text: title, fontWeight: .regular)
            
            Spacer()
            
        }
        .padding(.bottom, .stdBorder)
        
    }
    
}
