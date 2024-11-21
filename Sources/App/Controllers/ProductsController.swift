//
//  ProductController.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

import Vapor
import Fluent

struct ProductsController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let products = routes.grouped(PathComponent(stringLiteral: Product.schema))
        products.post(use: createProduct)
    }
    
    @Sendable
    func createProduct(req: Request) async throws -> Product {

        let payload = try req.content.decode(CreateProductPayload.self)
        
        let paylodadProduct = Product(name: payload.name, barcode: payload.barcode)
        
        return try await ProductsController.createOrUpdate(db: req.db, product: paylodadProduct)
    }
    
    @discardableResult
    static func createOrUpdate(db: Database, product from: Product) async throws -> Product {
        let existingProduct = try await Product.query(on:db)
            .filter(\.$barcode, .custom("="), from.barcode)
            .first()

        let product: Product
        if let existingProduct {
            product = existingProduct
            product.name = from.name
        } else {
            product = from
        }
        try await product.save(on: db)
        return product
    }
    
    static func fechProductWithParentRelationships(db: Database, product: Product) async throws  -> Product? {
        try await Product.query(on: db)
            .filter(\.$id, .custom("="), try product.requireID() )
            .with(\.$prices)
            .first()
    }
    
    static func fechProductWithGroceriesRelationships(db: Database, product: Product) async throws  -> Product? {
        try await Product.query(on: db)
            .filter(\.$id, .custom("="), try product.requireID() )
            .with(\.$prices)
            .first()
    }
}

struct CreateProductPayload: Content {
    var name: String
    var barcode: String
    
    mutating func afterDecode() throws {
        let productName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !productName.isEmpty else {
            throw Abort(.badRequest, reason: "Grocery name cannot be empty")
        }
        self.name = productName
        
        let productBarcode = self.barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !productBarcode.isEmpty else {
            throw Abort(.badRequest, reason: "Barcode cannot be empty")
        }
        self.barcode = productBarcode
 
        
    }
}

extension CreateProductPayload {
    init(_ from: Product) {
        self.name = from.name
        self.barcode = from.barcode
    }
}
