//
//  StoresViewModel.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 04/12/21.
//

import Combine
import MapKit

// ViewModel for StoresView
class StoresViewModel: ObservableObject {
    
    // Properties
    private var subscriptions   : [AnyCancellable] = [AnyCancellable]()
    private var appState        : AppState
    
    public var mapCenter        = CLLocationCoordinate2D(latitude: 45.4691009, longitude: 9.1683217)
    public var locationManager  = CLLocationManager()
    
    // Published properties
    @Published private(set) var storesAnnotations =  [StoreAnnotation]()
    
    
    // Init
    init(appState: AppState) {
        
        self.appState = appState
        
    }
    
    
    // Methods
    
    /// Loads the store annotations
    ///
    public func createStoreAnnotations() {
        
        let subscription = appState.dataRepository.$supermarkets.sink() { supermarkets in
            
            self.storesAnnotations = [StoreAnnotation]()
            
            for supermarket in supermarkets {
                let supermarketCoordinates = CLLocationCoordinate2D(
                    latitude: supermarket.latitude,
                    longitude: supermarket.longitude
                )
                
                let storeAnnotation = StoreAnnotation(
                    name: supermarket.name,
                    openingHour: "8:00",
                    closingHour: "23:30",
                    coordinate: supermarketCoordinates
                )
                
                self.storesAnnotations.append(storeAnnotation)
            }
            
        }
        
        subscriptions.append(subscription)
        
    }
    
    /// Triggers the request for location services utilization
    ///
    public func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Selects the store tapped by the user and sets it in the ShoppingSession
    ///
    /// - Parameter name: name of the selected supermarket
    public func setSelectedStore(name: String) {
        
        if let selectedSupermarket = appState.dataRepository.supermarkets.first(where: { $0.name == name }) {
            appState.shoppingSession.setSelectedSupermarket(to: selectedSupermarket)
            appState.userProfileManager.setSupermarketID(to: selectedSupermarket.ID)
            DataLoaderEngine.saveSupermaketName(appState: appState)
        }
        
    }
    
    /// Triggers the opening of maps with the specified destination
    ///
    public func navigateToStoreWithName(name: String) {
        
        guard let selectedStore = storesAnnotations.first(where: { $0.name == name }) else { return }
        
        let coordinate  = selectedStore.coordinate
        let mapItem     = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name    = selectedStore.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
}

extension StoresViewModel {

    struct StoreAnnotation: Identifiable {
        let id          = UUID()
        var name        : String
        var openingHour : String
        var closingHour : String
        var coordinate  : CLLocationCoordinate2D
    }
    
}
