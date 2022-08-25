//
//  ProductsListView.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 30/11/21.
//

import SwiftUI

struct ProductsListView: View {
    
    // ViewModel
    @ObservedObject var viewModel       : ProductsListViewModel
    
    // State variables
    @State var showMenu                 = false
    @State var showUserProfileView      = false
    @State var showScanView             = false
    
    
    // Init
    init(viewModel: ProductsListViewModel) {
        
        self.viewModel = viewModel
        
        // Modify UITableView appearence in order to have a custom background in the list
        UITableView.appearance().backgroundColor = .clear
        
    }
    
    
    // Body
    var body: some View {
        
        let closeMenuGesture = DragGesture()
            .onEnded { gesture in
                if gesture.translation.width < -100 {
                    withAnimation { self.showMenu = false }
                }
            }
        
        NavigationView {
            
            GeometryReader { geometry in
                
                ZStack(alignment: .leading) {
                    
                    // Background Color
                    //RadialGradient(gradient: Gradient(colors: [.backgroundColor, .secondaryDarkColor]), center: .center, startRadius: 100, endRadius: 1500).ignoresSafeArea()
                    Color.backgroundColor.ignoresSafeArea()
                    
                    // Menu bar and products list
                    let cellWidth = geometry.size.width / 3.2
                    let cellHeight = 190.0
                    
                    VStack(spacing: 0) {
                
                        MenuBar(title: viewModel.selectedSupermarket, obfuscateFields: viewModel.obfuscateFields, height: geometry.size.height * 0.1, safeAreaHeight: geometry.safeAreaInsets.top) {
                            withAnimation { self.showMenu.toggle() }
                        }
                        
                        // Products List
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            LazyVStack(alignment: .leading, spacing: .stdBorder) {
                                
                                ForEach(viewModel.categoriesRepresentables) { category in
                                    
                                    ElementTitle(text: category.categoryName)
                                        .padding(.leading, .stdBorder)
                                    
                                    // Elements of each section (horizontal scrollable)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: .stdBorder) {
                                            ForEach(category.categoryItems) { item in
                                                ProductCell(name: item.name, price: item.price, points: item.points, image: item.image, cellWidth: cellWidth)
                                                    .equatable()
                                                    .frame(width: cellWidth, height: cellHeight, alignment: .center)
                                                    .listRowInsets(.smallInsets)
                                            }
                                        }
                                            .padding(.leading, .stdBorder)
                                    }
                                    
                                }
                                
                            }
                                .padding(.top, 20.0)
                                .padding(.bottom, 100.0)
                            
                        }
                            .redacted(reason: (viewModel.obfuscateFields) ? .placeholder : [])
                            .shimmering(active: viewModel.obfuscateFields)
                        
                    }
                    
                    // Shopping button
                    VStack() {
                        
                        Spacer()
                        
                        StandardButton(title: "Start Shopping", isActive: viewModel.supermarketIsSelected) {
                            
                            if viewModel.showUserProfile {
                                self.showUserProfileView = true
                            } else if viewModel.supermarketIsSelected {
                                self.showScanView = true
                            }
                            
                        }
                            .unredacted()
                    
                    }
                    
                    // Lateral menu
                    if showMenu {
                        MenuView(viewModel: viewModel, menuIsVisible: $showMenu)
                            .frame(width: geometry.size.width * 0.6)
                            .transition(.move(edge: .leading))
                    }
                    
                }
                
                    .gesture(closeMenuGesture)
                
                    .alert("Connection Error", isPresented: $viewModel.showAlert) {
                        Button("Retry") { viewModel.downloadProducts() }
                    } message: {
                        Text("An error occurred during the data retrival process, please retry later")
                    }
                
                    .navigationBarHidden(true) // Hides the navigationView title bar
                
                NavigationLink(isActive: $showScanView, destination: { ScanView(viewModel: viewModel.getScanViewModel()) }, label: {})
            
            }
            
        } // Navigation view
        
        // Sheets
        .sheet(isPresented: $viewModel.showSupermarkets) {
            StoresView(viewModel: viewModel.getStoresViewModel(), dismissable: false)
                .interactiveDismissDisabled(true)
            
        }
        .sheet(isPresented: $showUserProfileView) {
            UserProfileView(viewModel: viewModel.getUserProfileViewModel(), dismissable: false)
                .interactiveDismissDisabled(true)
        }

    }
    
}

// Menu bar
private struct MenuBar: View {
    
    var title               : String
    var obfuscateFields     : Bool
    
    var height              : CGFloat
    var safeAreaHeight      : CGFloat
    
    var menuButtonAction    : () -> ()

    var body: some View {
        
        ZStack() {
            
            Rectangle()
                .fill(Color.primaryColor)
                .frame(maxWidth: .infinity, maxHeight: height + safeAreaHeight, alignment: .center)
                .shadow(radius: 3)
                .ignoresSafeArea()
            
            HStack(alignment: .center) {
                
                // Menu Button
                Button(action: {
                    menuButtonAction()
                }) {
                    Image(systemName: "line.2.horizontal.decrease.circle")
                        .resizable()
                        .renderingMode(.original)
                        .foregroundColor(Color.textColor)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: CGFloat(25.0), height: .buttonEdge, alignment: .center)
                        .padding(.leading, 20.0)
                        .padding(.trailing, 10.0)
                }
                
                // Title
                VStack(alignment: .leading, spacing: -5.0) {
                    PageTitle(text: title)
                        .redacted(reason: obfuscateFields ? .placeholder : [])
                        .shimmering(active: obfuscateFields)
                    
                    ElementText(text: "Now open")
                        .foregroundColor(Color.secondaryTextColor)
                        .redacted(reason: obfuscateFields ? .placeholder : [])
                        .opacity(title == "             " ? 0 : 1)
                }
            
                Spacer()
                
            }
            
        }
            .frame(maxWidth: .infinity, maxHeight: height)
        
    }
    
}

// Product Cell
private struct ProductCell: View, Equatable {
    
    var name        : String
    var price       : String
    var points      : String
    var image       : Data?
    var cellWidth   : CGFloat
    
    var body: some View {
        
         // Title and price
        VStack(alignment: .leading) {
            
            Spacer()
            
            ElementSubtitle(text: name, fontWeight: .medium, color: .white)
            
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                Text("€")
                    .font(Font.system(size: 13))
                    .foregroundColor(.white)
                Text(price)
                    .foregroundColor(.white)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                Text(points + " points")
                    .font(Font.system(size: 10))
                    .foregroundColor(.white)
            }
            
        }
            .frame(maxWidth: .infinity)
            .padding(.smallBorder)
            .background {
                if let image = image {
                    ZStack {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .scaledToFill()
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black]), startPoint: .top, endPoint: .bottom))
                    }

                } else {
                    Rectangle()
                        .redacted(reason: .placeholder)
                        .shimmering()
                }
            }
            .cornerRadius(.radius)
        
    }
    
    static func == (lhs: ProductCell, rhs: ProductCell) -> Bool {
        return lhs.name == rhs.name && lhs.image == rhs.image
    }
    
}



