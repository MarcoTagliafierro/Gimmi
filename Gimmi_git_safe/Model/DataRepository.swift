//
//  ProductsList.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 09/12/21.
//

import SwiftUI
import Combine

// Class to manage the lists of products and supermarkets
class DataRepository {
    
    struct CategoryAndProducts {
        
        var category: Category
        var products: [Product]
        
        init(category: Category) {
            self.category = category
            self.products = []
        }
        
    }
    
    // Properties
    @Published var products             : [CategoryAndProducts]
    @Published var supermarkets         : [Supermarket]
    
    private var categoryIndex           : [String: Int] // associates to each cateogory its index in the data structure
    private var productIndexes          : [String: (category: Int, product: Int)] // associates the product ID to its indexes
    
    private var selectedSupermarket     : Supermarket?
    private var backupProducts          : [CategoryAndProducts]
    
    
    // Init
    init() {
        
        products        = []
        supermarkets    = []
        
        categoryIndex   = [String: Int]()
        productIndexes  = [String: (category: Int, product: Int)]()
        
        backupProducts  = []
        
    }
    
    
    // Methods
    
    /// Load all the categories creating an entry for each one
    ///
    /// - Parameter data: data of the categories
    func loadCategories(data: [FirebaseEngine.FBEData]) {
            
        // Sort the data by name
        let sortedData = data.sorted(by: {
            ($0[DictionariesFields.name] as! String) < ($1[DictionariesFields.name] as! String)
        })
        
        for (index, datum) in sortedData.enumerated() {
            let category = Category.decodeData(data: datum) as! Category
            products.append(CategoryAndProducts(category: category))
            categoryIndex[category.ID] = index
        }
        
    }
    
    
    /// Load all the products inside products
    ///
    /// - Parameter data: data of the product to be added
    func loadProducts(data: [FirebaseEngine.FBEData]) {
        
        // Using a copy in order to avoid publishing lots of updates
        var productsCopy = products
        
        // Sort the data before adding it to the product structure
        let sortedData = data.sorted(by: {
            ($0[DictionariesFields.name] as! String) < ($1[DictionariesFields.name] as! String)
        })
        
        for datum in sortedData {
            
            let product = Product.decodeData(data: datum) as! Product
            
            let categoryID = product.category
            let categoryIndex = categoryIndex[categoryID]!
            
            productsCopy[categoryIndex].products.append(product)
            
            let productIndex = productsCopy[categoryIndex].products.count - 1
            productIndexes[product.ID] = (category: categoryIndex, product: productIndex)
            
        }
        
        backupProducts = productsCopy
        filterProducts()
        
    }
    
    /// Set the image of a given product
    ///
    /// - Parameter productID: product's ID
    /// - Parameter categoryID: product's category
    /// - Parameter imageData: product's image
    func setProductImage(productID: String, categoryID: String, imageData: Data) {
        
        let categoryIndex = categoryIndex[categoryID]!
        
        if let index = backupProducts[categoryIndex].products.firstIndex(where: ({ $0.ID == productID })) {
            backupProducts[categoryIndex].products[index].image = imageData
            filterProducts()
        }
        
    }
    
    /// Load the supermarkets inside supermarkets
    ///
    /// - Parameter data: data of the supermarkets to be loaded
    func loadSupermarkets(data: [FirebaseEngine.FBEData]) {
        
        // Using a copy in order to avoid publishing lots of updates
        var supermarketCopy = [Supermarket]()
        
        for datum in data {
            let supermarket = Supermarket.decodeData(data: datum) as! Supermarket
            supermarketCopy.append(supermarket)
        }
        
        supermarkets = supermarketCopy
        
    }
    
    /// Set the selected supermarket and calls the filter function to
    /// select only the products available to that supermarket
    func setSelectedSupermarket(to supermarket: Supermarket?) {
        
        self.selectedSupermarket = supermarket
        filterProducts()
        
    }
    
    /// Return the selected supermarket
    func getSelectedSupermarket() -> Supermarket? {
        return selectedSupermarket
    }
    
    /// Filters the products of a specific supermaket
    ///
    private func filterProducts() {
        
        if let selectedSupermarket = selectedSupermarket {
        
            var filteredProducts = [CategoryAndProducts]()
            
            for productCategory in backupProducts {
                
                // Get all the product for the current category present in the supermarket
                var categoryAndProducts = CategoryAndProducts(category: productCategory.category)
                for product in productCategory.products {
                    
                    if selectedSupermarket.productsIDs.contains(product.ID) {
                        categoryAndProducts.products.append(product)
                    }
                    
                }
                
                // If there is at least one product, the array is saved
                if categoryAndProducts.products.count != 0 { filteredProducts.append(categoryAndProducts) }
                
            }
            
            products = filteredProducts
            
        } else {
            products = backupProducts
        }
        
    }
    
    /// Returns the product identified by the provided id
    ///
    /// - Parameter id: the id of the product
    func getProductById(id: String) -> Product? {
        if let indexes = productIndexes[id] {
            return backupProducts[indexes.category].products[indexes.product]
        } else {
            return nil
        }
    }
    
    /// Resets all the loaded data
    func resetData() {
        products        = []
        supermarkets    = []
        
        categoryIndex   = [String: Int]()
        productIndexes  = [String: (category: Int, product: Int)]()
        
        backupProducts  = []
    }
    
}
