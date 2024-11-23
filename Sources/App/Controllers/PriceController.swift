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
        let prices = routes.grouped(PathComponent(stringLiteral: EndPointPath.price.rawValue))
        prices.post(use: createPrice)
    }
    
    @Sendable
    func createPrice(req: Request) async throws -> [Price] {
        var prices: [Price] = []
        let payloads = try req.content.decode(CreatePricesPayload.self)
        for payload in payloads.prices {
            let price = try await PriceController.createOrUpdatePrice(db: req.db, payload: payload)
            prices.append(price)
        }
        return prices
    }
    
    static func createOrUpdatePrices(db: Database, payloads: [CreatePricePayload]) async throws -> [Price] {
        var prices: [Price] = []
        for payload in payloads {
            let price = try await createOrUpdatePrice(db: db, payload: payload)
            prices.append(price)
        }
        return prices
    }
    
    static func createOrUpdatePrice(db: Database, payload: CreatePricePayload) async throws -> Price {
        let product = try await ProductController.createOrUpdate(db: db, product: payload.toProduct())
        
        let grocery = try await GroceryController.createOrUpdate(db: db,
                                                                   grocery: payload.toGrocery())
        
        guard let productId = product.id,
              let groceryId = grocery.id else {
            throw Abort(.notFound, reason: "Grocery or product not found")
        }
        
        let existingPrice = try await Price.query(on: db)
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
        try await price.save(on: db)
        
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

struct CreatePricesPayload: Content {
    var prices: [CreatePricePayload]
    
    mutating func afterDecode() throws {
        guard prices.allSatisfy( { !$0.currency.isEmpty }) else {
            throw Abort(.badRequest, reason: "Currency name cannot be empty")
        }
    }
}

struct CreatePricePayload: Content {
    var grocery: CreateGroceryPayload
    var product: CreateProductPayload
    var price: Double
    var currency: String
    
    mutating func afterDecode() throws {
        
        guard price.isFinite else {
            throw Abort(.badRequest, reason: "Price must be a finite number")
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
