//
//  StoresView.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 04/12/21.
//

import SwiftUI
import MapKit

struct StoresView: View {

    @Environment(\.dismiss) var dismiss
                            var dismissable : Bool
    
    // ViewModel
    @ObservedObject         var viewModel   : StoresViewModel
    
    // State variables
    @State private          var region       : MKCoordinateRegion
    
    @State private          var storeName    : String?
    @State private          var openingHour  : String?
    @State private          var closingHour  : String?
    
    
    // Init
    init(viewModel: StoresViewModel, dismissable: Bool = true) {
        
        self.dismissable    = dismissable
        self.viewModel      = viewModel
        
        // Properties initialization
        _region = State(initialValue:
                            MKCoordinateRegion(
                                center: viewModel.mapCenter,
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        )
        
        self.viewModel.requestLocationAuthorization()
        self.viewModel.createStoreAnnotations()
        
    }

    
    // Body
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                
                // Background Color
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: .stdBorder) {
                    
                    // Title
                    if dismissable {
                        TitleBar(title: "Our Stores", subTitle: "Please select the store where you would like to shop in") { dismiss() }
                    } else {
                        TitleBar(title: "Our Stores", subTitle: "Please select the store where you would like to shop in")
                    }
                    
                    // Map
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.storesAnnotations) { item in
                        
                        MapAnnotation(coordinate: item.coordinate) {
                            Button {
                                storeName = item.name
                                openingHour = "Opening hour: " + item.openingHour
                                closingHour = "Closing hour: " + item.closingHour
                               } label: {
                                   VStack() {
                                       Image(systemName: "mappin.circle.fill").foregroundColor(.accentColor)
                                       Text(item.name).foregroundColor(.textColor)
                                   }
                               }
                               .symbolRenderingMode(.multicolor)
                            
                           }
                            
                    }
                        .frame(width: geometry.size.width - .stdBorder * 2, height: geometry.size.height * 0.4)
                        .cornerRadius(.radius)
                        .padding(.top, .stdBorder)
                    
                    // Selected store infos
                    HStack() {
                        
                        if let storeName = storeName, let openingHour = openingHour, let closingHour = closingHour {
                            VStack(alignment: .leading) {
                                PageSubtitle(text: storeName)
                                Text(openingHour)
                                Text(closingHour)
                            }
                        
                            Spacer()
                            
                            Button {
                                viewModel.navigateToStoreWithName(name: storeName)
                            } label: {
                                Image(systemName: "figure.walk")
                            }
                                .frame(width: 45, height: 45, alignment: .center)
                                .background(Color.accentColor)
                                .foregroundColor(Color.textColor)
                                .cornerRadius(CGFloat(10))
                        }
                        
                    }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.stdInsets)
                    
                    Spacer()
                    
                    // Select Store Button
                    StandardButton(title: "Select Store", isActive: storeName != nil) {
                        if let storeName = storeName {
                            viewModel.setSelectedStore(name: storeName)
                            dismiss()
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
}
