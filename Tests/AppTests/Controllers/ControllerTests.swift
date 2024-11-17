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
}
