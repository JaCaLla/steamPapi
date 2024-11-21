@testable import App
import XCTVapor
import Testing
import Fluent
//import SwiftDotenv

@Suite("App Tests with DB", .serialized)
struct ControllerTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {

        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    // MARK :- Groceries
    @Test("Create Groceries")
    func createGroceries() async throws {
        let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                #expect(groceryAdded.name == "MD")
                #expect(groceryAdded.latitude == 1.2)
                #expect(groceryAdded.longitude == 1.3)
            })
        }
    }
    
    @Test("Create Groceries Twice")
    func createGroceriesTwice() async throws {
        let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                try await app.test(.POST, "groceries", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded2nd = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.id == groceryAdded2nd.id)
                    #expect(groceryAdded2nd.name == "MD")
                })
            })
        }
    }
    
    @Test("Create Groceries Twice replacing name")
    func createGroceriesTwiceReplacingNamee() async throws {
        let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                let newGrocery2 = Grocery(name: "MD2", latitude: 1.2, longitude: 1.3)
                try await app.test(.POST, "groceries", beforeRequest: { req in
                    try req.content.encode(newGrocery2)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded2nd = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.id == groceryAdded2nd.id)
                })
            })
        }
    }
    
    @Test("Create Groceries when name is empty")
    func createGroceriesWhenNameEmpty() async throws {
        let newGrocery = Grocery(name: "", latitude: 1.2, longitude: 1.3)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test("Create Groceries when name is trimmed")
    func createGroceriesTrimName() async throws {
        let newGrocery = Grocery(name: "      MD    ", latitude: 1.2, longitude: 1.3)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                #expect(groceryAdded.name == "MD")
            })
        }
    }
    
    @Test("Create Groceries with lat long > 5 decs")
    func createGroceriesLanLon5DecsNeg() async throws {
        let newGrocery = Grocery(name: "MD", latitude: -1.12345, longitude: 2.123)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                #expect(groceryAdded.latitude == -1.1234)
                #expect(groceryAdded.longitude == 2.123)
            })
        }
    }
    
    @Test("Create Groceries with lat long > 5 decs")
    func createGroceriesLanLon5Decs() async throws {
        let newGrocery = Grocery(name: "MD", latitude: 1.12345, longitude: 2.123)
        try await withApp { app in
            try await app.test(.POST, "groceries", beforeRequest: { req in
                try req.content.encode(newGrocery)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let groceryAdded = try res.content.decode(Grocery.self)
                #expect(groceryAdded.latitude == 1.1234)
                #expect(groceryAdded.longitude == 2.123)
            })
        }
    }
    
    // MARK :- Products
    @Test("Create Products")
    func createProducts() async throws {
        let newProduct = Product(name:"Milk", barcode: "123456")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let productAdded = try res.content.decode(Product.self)
                #expect(productAdded.name == "Milk")
                #expect(productAdded.barcode == "123456")
            })
        }
    }
    
    @Test("Create Proeuct Twice")
    func createProductsTwice() async throws {
        let newProduct = Product(name:"Milk", barcode: "123456")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let productAdded = try res.content.decode(Product.self)
                try await app.test(.POST, "products", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productAdded2nd = try res.content.decode(Product.self)
                    #expect(productAdded.id == productAdded2nd.id)
                })
            })
        }
    }
    
    @Test("Create Proeuct Twice When name changes")
    func createProductsTwiceReplacingName() async throws {
        let newProduct = Product(name:"Milk", barcode: "123456")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let productAdded = try res.content.decode(Product.self)
                try await app.test(.POST, "products", beforeRequest: { req in
                    let newProduct2 = Product(name:"Milk2", barcode: "123456")
                    try req.content.encode(newProduct2)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productAdded2nd = try res.content.decode(Product.self)
                    #expect(productAdded.id == productAdded2nd.id)
                    #expect(productAdded2nd.name == "Milk2")
                })
            })
        }
    }
    
    @Test("Create Product when name is empty")
    func createProductsWhenNameEmpty() async throws {
        let newProduct = Product(name:"", barcode: "123456")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test("Create Product when barcode is empty")
    func createProductsWhenBarcodeEmpty() async throws {
        let newProduct = Product(name:"Milk", barcode: "")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })
        }
    }
    
    @Test("Create Product when name is trimmed")
    func createProductsTrimName() async throws {
        let newProduct = Product(name:"   Milk  ", barcode: "12345")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let productAdded = try res.content.decode(Product.self)
                #expect(productAdded.name == "Milk")
            })
        }
    }
    
    @Test("Create Product when barcode is trimmed")
    func createProductsTrimBarcode() async throws {
        let newProduct = Product(name:"Milk", barcode: "    12 345   ")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let productAdded = try res.content.decode(Product.self)
                #expect(productAdded.barcode == "12 345")
            })
        }
    }
    
    // MARK :- Products
    @Test("Create Products When previosly exist product and grocery")
    func createPrices() async throws {
        let newProduct = Product(name:"Milk", barcode: "123456")
        try await withApp { app in
            try await app.test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newProduct)
            }, afterResponse: { res async throws in
                let productAdded = try res.content.decode(Product.self)
                #expect(res.status == .ok)
                let newGrocery = Grocery(name: "MD", latitude: 1.12345, longitude: 2.123)
                try await app.test(.POST, "groceries", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    let groceryAdded = try res.content.decode(Grocery.self)
                    #expect(res.status == .ok)
                    try await app.test(.POST, "prices", beforeRequest: { req in
                        let newPrice = CreatePricePayload(grocery: groceryAdded,
                                                          product: productAdded,
                                                          price: 10.3,
                                                          currency: "EUR")
                        try req.content.encode(newPrice)
                    }, afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        let priceAdded = try res.content.decode(Price.self)
                        #expect(priceAdded.price == 10.3)
                        #expect(priceAdded.currency == "EUR")
                    })
                })
            })
        }
    }
    
    @Test("Create Products When previosly do not exist neither product nor grocery")
    func createPricesNoProductNoGrocery() async throws {
        try await withApp { app in
            try await app.test(.POST, "prices", beforeRequest: { req in
                let newPrice = CreatePricePayload(grocery: Grocery(name: "MD", latitude: 1.12345, longitude: 2.123),
                                                  product: Product(name:"Milk", barcode: "123456"),
                                                  price: 10.3,
                                                  currency: "EUR")
                try req.content.encode(newPrice)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let priceAdded = try res.content.decode(Price.self)
                #expect(priceAdded.price == 10.3)
                #expect(priceAdded.currency == "EUR")
                
                guard let priceWithParents = try await PriceController.fetchPriceWithParentRelationships(db: app.db, price: priceAdded) else {
                    #expect(Bool(false))
                    return
                }
                #expect(priceWithParents.product.name == "Milk")
                #expect(priceWithParents.product.barcode == "123456")
                #expect(priceWithParents.product.id != nil)
                #expect(priceWithParents.grocery.name == "MD")
                #expect(priceWithParents.grocery.latitude == 1.12345)
                #expect(priceWithParents.grocery.longitude == 2.123)
                #expect(priceWithParents.grocery.id != nil)
                
                //Buscar el producto y ver que en la lista de precios esta el precio entrado
                let priceProduct = try await ProductsController.fechProductWithParentRelationships(db: app.db, product: priceWithParents.product)
                #expect(priceProduct?.prices.count == 1)
                #expect(priceProduct?.prices[0].price == 10.3)
                #expect(priceProduct?.prices[0].currency == "EUR")
                
                //Buscar la tientda y ver que en la lista de precios está el precio entrado
                let priceGrocery = try await GroceriesController.fetchGroceryWithParentRelationships(db: app.db, grocery: priceWithParents.grocery)
                #expect(priceGrocery?.prices.count == 1)
                #expect(priceGrocery?.prices[0].price == 10.3)
                #expect(priceGrocery?.prices[0].currency == "EUR")
            })
        }
    }
    
    @Test
    func create1ProductThatExistsIn2Groceries() async throws {
        try await withApp { app in
            try await ProductsController.createOrUpdate(db: app.db,
                                                        product: Product(name: "Apple",barcode: "12345"))
            try await GroceriesController.createOrUpdate(db: app.db,
                                                         grocery: Grocery(name: "MD", latitude: 1.12, longitude: 2.23))
            try await GroceriesController.createOrUpdate(db: app.db,
                                                         grocery: Grocery(name: "SP", latitude: 4.52, longitude: 4.53))
            
            try await app.test(.POST, "prices", beforeRequest: { req in
                let newPrice = CreatePricePayload(grocery: Grocery(name: "MD", latitude: 1.12, longitude: 2.23),
                                                  product: Product(name:"Apple", barcode: "12345"),
                                                  price: 14.3,
                                                  currency: "EUR")
                try req.content.encode(newPrice)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let priceAdded1 = try res.content.decode(Price.self)
                #expect(priceAdded1.price == 14.3)
                #expect(priceAdded1.currency == "EUR")
                
                try await app.test(.POST, "prices", beforeRequest: { req in
                    let newPrice = CreatePricePayload(grocery: Grocery(name: "SP", latitude: 4.52, longitude: 4.53),
                                                      product: Product(name:"Apple", barcode: "12345"),
                                                      price: 6.7,
                                                      currency: "EUR")
                    try req.content.encode(newPrice)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let priceAdded2 = try res.content.decode(Price.self)
                    #expect(priceAdded2.price == 6.7)
                    #expect(priceAdded2.currency == "EUR")
                    
                    guard let price1WithParents = try await PriceController.fetchPriceWithParentRelationships(db: app.db, price: priceAdded1) else {
                        #expect(Bool(false))
                        return
                    }
                    #expect(price1WithParents.product.name == "Apple")
                    #expect(price1WithParents.product.barcode == "12345")
                    #expect(price1WithParents.product.id != nil)
                    #expect(price1WithParents.grocery.name == "MD")
                    #expect(price1WithParents.grocery.latitude == 1.12)
                    #expect(price1WithParents.grocery.longitude == 2.23)
                    #expect(price1WithParents.grocery.id != nil)
                    
                    guard let price2WithParents = try await PriceController.fetchPriceWithParentRelationships(db: app.db, price: priceAdded2) else {
                        #expect(Bool(false))
                        return
                    }
                    #expect(price2WithParents.product.name == "Apple")
                    #expect(price2WithParents.product.barcode == "12345")
                    #expect(price2WithParents.product.id != nil)
                    #expect(price2WithParents.grocery.name == "SP")
                    #expect(price2WithParents.grocery.latitude == 4.52)
                    #expect(price2WithParents.grocery.longitude == 4.53)
                    #expect(price2WithParents.grocery.id != nil)
                    
                    //Buscar el producto y ver que en la lista de precios esta el precio entrado
                    let priceProduct = try await ProductsController.fechProductWithParentRelationships(db: app.db, product: price1WithParents.product)
                    #expect(priceProduct?.prices.count == 2)
                    #expect(priceProduct?.prices[0].price == 14.3)
                    #expect(priceProduct?.prices[0].currency == "EUR")
                    let grocery1 = try await priceProduct?.prices[0].$grocery.get(on: app.db)
                    #expect(grocery1?.name == "MD")
                    
                    #expect(priceProduct?.prices[1].price == 6.7)
                    #expect(priceProduct?.prices[1].currency == "EUR")
                    let grocery2 = try await priceProduct?.prices[1].$grocery.get(on: app.db)
                    #expect(grocery2?.name == "SP")
                    
                    //Buscar las tientdas y ver que en la lista de precios está el precio entrado
                    let priceGrocery1 = try await GroceriesController.fetchGroceryWithParentRelationships(db: app.db, grocery: price1WithParents.grocery)
                    #expect(priceGrocery1?.prices.count == 1)
                    #expect(priceGrocery1?.prices[0].price == 14.3)
                    #expect(priceGrocery1?.prices[0].currency == "EUR")
                    let priceGrocery2 = try await GroceriesController.fetchGroceryWithParentRelationships(db: app.db, grocery: price2WithParents.grocery)
                    #expect(priceGrocery2?.prices.count == 1)
                    #expect(priceGrocery2?.prices[0].price == 6.7)
                    #expect(priceGrocery2?.prices[0].currency == "EUR")
                })
            })
        }
    }
    
    @Test
    func create1GroceryWith2Products() async throws {
        try await withApp { app in
            let product1 = try await ProductsController.createOrUpdate(db: app.db,
                                                                      product: Product(name: "Apple",barcode: "12345"))
            let product2 = try await ProductsController.createOrUpdate(db: app.db,
                                                                      product: Product(name: "Clock",barcode: "6345"))
            let grocery = try await GroceriesController.createOrUpdate(db: app.db,
                                                                        grocery: Grocery(name: "Dtp", latitude: -8.12, longitude: 2.50))
            
            try await app.test(.POST, "prices", beforeRequest: { req in
                let newPrice = CreatePricePayload(grocery: Grocery(name: "Dtp", latitude: -8.12, longitude: 2.50),
                                                  product: Product(name: "Apple",barcode: "12345"),
                                                  price: 64.3,
                                                  currency: "EUR")
                try req.content.encode(newPrice)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let priceAdded1 = try res.content.decode(Price.self)
                #expect(priceAdded1.price == 64.3)
                #expect(priceAdded1.currency == "EUR")
                
                try await app.test(.POST, "prices", beforeRequest: { req in
                    let newPrice = CreatePricePayload(grocery: Grocery(name: "Dtp", latitude: -8.12, longitude: 2.50),
                                                      product: Product(name: "Clock",barcode: "6345"),
                                                      price: 7.7,
                                                      currency: "USD")
                    try req.content.encode(newPrice)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let priceAdded2 = try res.content.decode(Price.self)
                    #expect(priceAdded2.price == 7.7)
                    #expect(priceAdded2.currency == "USD")
                    
                    guard let price1WithParents = try await PriceController.fetchPriceWithParentRelationships(db: app.db, price: priceAdded1) else {
                        #expect(Bool(false))
                        return
                    }
                    #expect(price1WithParents.product.name == "Apple")
                    #expect(price1WithParents.product.barcode == "12345")
                    #expect(price1WithParents.product.id != nil)
                    #expect(price1WithParents.grocery.name == "Dtp")
                    #expect(price1WithParents.grocery.latitude == -8.12)
                    #expect(price1WithParents.grocery.longitude == 2.5)
                    #expect(price1WithParents.grocery.id != nil)
                    
                    guard let price2WithParents = try await PriceController.fetchPriceWithParentRelationships(db: app.db, price: priceAdded2) else {
                        #expect(Bool(false))
                        return
                    }
                    #expect(price2WithParents.product.name == "Clock")
                    #expect(price2WithParents.product.barcode == "6345")
                    #expect(price2WithParents.product.id != nil)
                    #expect(price2WithParents.grocery.name == "Dtp")
                    #expect(price2WithParents.grocery.latitude == -8.12)
                    #expect(price2WithParents.grocery.longitude == 2.5)
                    #expect(price2WithParents.grocery.id != nil)
                    
                    //Buscar el producto y ver que en la lista de precios esta el precio entrado
                    let priceProduct1 = try await ProductsController.fechProductWithParentRelationships(db: app.db, product: price1WithParents.product)
                    #expect(priceProduct1?.prices.count == 1)
                    #expect(priceProduct1?.prices[0].price == 64.3)
                    #expect(priceProduct1?.prices[0].currency == "EUR")
                    let product1 = try await priceProduct1?.prices[0].$product.get(on: app.db)
                    #expect(product1?.name == "Apple")
                    
                    let priceProduct2 = try await ProductsController.fechProductWithParentRelationships(db: app.db, product: price2WithParents.product)
                    #expect(priceProduct2?.prices.count == 1)
                    #expect(priceProduct2?.prices[0].price == 7.7)
                    #expect(priceProduct2?.prices[0].currency == "USD")
                    let product2 = try await priceProduct2?.prices[0].$product.get(on: app.db)
                    #expect(product2?.name == "Clock")
 
                    
                    //Buscar las tientdas y ver que en la lista de precios está el precio entrado
                    let priceGrocery = try await GroceriesController.fetchGroceryWithParentRelationships(db: app.db, grocery: price1WithParents.grocery)
                    #expect(priceGrocery?.prices.count == 2)
                    #expect(priceGrocery?.prices[0].price == 64.3)
                    #expect(priceGrocery?.prices[0].currency == "EUR")
                    let product1PriceGrocery = try await priceGrocery?.prices[0].$product.get(on: app.db)
                    #expect(product1PriceGrocery?.name == "Apple")
                    #expect(priceGrocery?.prices[1].price == 7.7)
                    #expect(priceGrocery?.prices[1].currency == "USD")
                    let product2PriceGrocery = try await priceGrocery?.prices[1].$product.get(on: app.db)
                    #expect(product2PriceGrocery?.name == "Clock")
                })
            })
        }
    }


    

}
