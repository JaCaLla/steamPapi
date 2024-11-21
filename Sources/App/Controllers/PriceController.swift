//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 19/11/24.
//

import Vapor
import Fluent

struct PriceController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let prices = routes.grouped(PathComponent(stringLiteral: Price.schema))
        prices.post(use: createPrice)
    }
    
    @Sendable
    func createPrice(req: Request) async throws -> Price {

        let payload = try req.content.decode(CreatePricePayload.self)

        let product = try await ProductsController.createOrUpdate(db: req.db, product: payload.toProduct())
        
        let grocery = try await GroceriesController.createOrUpdate(db: req.db,
                                                                   grocery: payload.toGrocery())
        
        guard let productId = product.id,
              let groceryId = grocery.id else {
            throw Abort(.notFound, reason: "Grocery or product not found")
        }
        
        let existingPrice = try await Price.query(on: req.db)
            .filter(\.$product.$id, .custom("="), productId )
            .filter(\.$grocery.$id, .custom("="), groceryId )
            .first()
        let price: Price
        if let existingPrice {
            price = existingPrice
            price.price = payload.price
            price.currency = payload.currency
        } else {
            price = Price(price: payload.price, currency: payload.currency, productID: productId, groceryID: groceryId)
        }
        try await price.save(on: req.db)
        
        return price
    }
    
    @Sendable
    static func fetchPriceWithParentRelationships(db: Database, price: Price) async throws  -> Price? {
        try await Price.query(on: db)
            .filter(\.$id, .custom("="), try price.requireID() )
            .with(\.$product) // Eagerly load the Product relation
            .with(\.$grocery) // Eagerly load the Product relation
            .first()
    }
}

struct CreatePricePayload: Content {
    var grocery: CreateGroceryPayload
    var product: CreateProductPayload
    var price: Double
    var currency: String
    
    mutating func afterDecode() throws {
        
        guard price.isFinite else {
            throw Abort(.badRequest, reason: "Latitude must be a finite number")
        }
        
        let currencyName = currency.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currencyName.isEmpty else {
            throw Abort(.badRequest, reason: "Currency name cannot be empty")
        }
        self.currency = currencyName        
    }
}

extension CreatePricePayload {
    init(grocery: Grocery, product: Product, price: Double, currency: String) {
        self.grocery = .init(grocery)
        self.product = .init(product)
        self.price = price
        self.currency = currency
    }

    func toGrocery() -> Grocery {
        Grocery(name: self.grocery.name,
                latitude: self.grocery.latitude,
                longitude: self.grocery.longitude)
    }
    
    func toProduct() -> Product {
        Product(name: self.product.name,
                barcode: self.product.barcode)
    }
}
