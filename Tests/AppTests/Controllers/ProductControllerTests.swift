//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 22/11/24.
//

@testable import App
import XCTVapor
import Testing
import Fluent


extension ControllerTests {
    struct ProductControllerTests {
        // MARK :- Products
        @Test("Create Products")
        func createProducts() async throws {
            let newProduct = Product(name:"Milk", barcode: "123456")
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
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
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productAdded = try res.content.decode(Product.self)
                    try await app.test(.POST, "product", beforeRequest: { req in
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
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productAdded = try res.content.decode(Product.self)
                    try await app.test(.POST, "product", beforeRequest: { req in
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
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Create Product when barcode is empty")
        func createProductsWhenBarcodeEmpty() async throws {
            let newProduct = Product(name:"Milk", barcode: "")
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Create Product when name is trimmed")
        func createProductsTrimName() async throws {
            let newProduct = Product(name:"   Milk  ", barcode: "12345")
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
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
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "product", beforeRequest: { req in
                    try req.content.encode(newProduct)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productAdded = try res.content.decode(Product.self)
                    #expect(productAdded.barcode == "12 345")
                })
            }
        }
        
        
        @Test("Fetch a products with its groceries")
        func fetchProductWithItsGroceries() async throws {
            try await ControllerTests.withApp { app in
                let prices = try await PriceController.createOrUpdatePrices(db: app.db, payloads: .sample)
                #expect(prices.count == 6)
                try await app.test(.GET, "product/1111", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productDTO = try res.content.decode(ProductDTO.self)
                    #expect(productDTO.name == "sP1")
                    #expect(productDTO.barcode == "1111")
                    #expect(productDTO.groceryPrices.count == 2)
                    #expect(productDTO.groceryPrices[0].name == "sG1")
                    #expect(productDTO.groceryPrices[0].latitude == 23.3)
                    #expect(productDTO.groceryPrices[0].longitude == 23.3)
                    #expect(productDTO.groceryPrices[0].price == 1.1)
                    #expect(productDTO.groceryPrices[0].currency == "EUR")
                    #expect(productDTO.groceryPrices[1].name == "sG3")
                    #expect(productDTO.groceryPrices[1].latitude == 23.4)
                    #expect(productDTO.groceryPrices[1].longitude == 23.3)
                    #expect(productDTO.groceryPrices[1].price == 3.1)
                    #expect(productDTO.groceryPrices[1].currency == "EUR")
                })
                try await app.test(.GET, "product/2222", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productDTO = try res.content.decode(ProductDTO.self)
                    #expect(productDTO.name == "sP2")
                    #expect(productDTO.barcode == "2222")
                    #expect(productDTO.groceryPrices.count == 2)
                    #expect(productDTO.groceryPrices[0].name == "sG1")
                    #expect(productDTO.groceryPrices[0].latitude == 23.3)
                    #expect(productDTO.groceryPrices[0].longitude == 23.3)
                    #expect(productDTO.groceryPrices[0].price == 1.2)
                    #expect(productDTO.groceryPrices[0].currency == "EUR")
                    #expect(productDTO.groceryPrices[1].name == "sG2")
                    #expect(productDTO.groceryPrices[1].latitude == 23.3)
                    #expect(productDTO.groceryPrices[1].longitude == 23.4)
                    #expect(productDTO.groceryPrices[1].price == 2.2)
                    #expect(productDTO.groceryPrices[1].currency == "EUR")
                })
                try await app.test(.GET, "product/3333", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let productDTO = try res.content.decode(ProductDTO.self)
                    #expect(productDTO.name == "sP3")
                    #expect(productDTO.barcode == "3333")
                    #expect(productDTO.groceryPrices.count == 2)
                    #expect(productDTO.groceryPrices[0].name == "sG1")
                    #expect(productDTO.groceryPrices[0].latitude == 23.3)
                    #expect(productDTO.groceryPrices[0].longitude == 23.3)
                    #expect(productDTO.groceryPrices[0].price == 1.3)
                    #expect(productDTO.groceryPrices[0].currency == "EUR")
                    #expect(productDTO.groceryPrices[1].name == "sG2")
                    #expect(productDTO.groceryPrices[1].latitude == 23.3)
                    #expect(productDTO.groceryPrices[1].longitude == 23.4)
                    #expect(productDTO.groceryPrices[1].price == 2.3)
                    #expect(productDTO.groceryPrices[1].currency == "EUR")
                })
            }
        }
        
    }
}
