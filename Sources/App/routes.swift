import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("test") { req async throws in
        let product = Product(name: "Oil", barcode: "123")
        try await product.create(on: req.db)
        let grocery = Grocery(name: "MD", latitude: 1.2, longitude: 3.4)
        try await grocery.create(on: req.db)
        let price = Price(price: 1.5, currency: "EUR", productID: try product.requireID(), groceryID: try grocery.requireID())
        try await price.create(on: req.db)
        return price
    }
}
