//
//  ProductController.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

import Vapor
import Fluent

struct ProductController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let products = routes.grouped(PathComponent(stringLiteral: Product.schema))
        products.post(use: createProduct)
    }
    
    @Sendable
    func createProduct(req: Request) async throws -> Product {

        let payload = try req.content.decode(CreateProductPayload.self)
        
        let existingProduct = try await Product.query(on:req.db)
            .filter(\.$barcode, .custom("="), payload.barcode)
            .first()

        let product: Product
        if let existingProduct {
            product = existingProduct
        } else {
            product = Product(name: payload.name, barcode: payload.barcode)
        }
        try await product.save(on: req.db)
        return product
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
