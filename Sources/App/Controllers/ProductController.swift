//
//  ProductController.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

import Vapor
import Fluent


struct ProductDTO: Content {
    let name: String
    let barcode: String
    let groceryPrices: [GroceryPriceDTO]
}

struct GroceryPriceDTO: Content {
    let name: String
    let latitude: Double
    let longitude: Double
    let price: Double
    let currency: String
}

struct ProductController: RouteCollection {
    
    enum PathParaemeter: String {
        case barcode
    }
    
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let routesGrouped = routes.grouped(PathComponent(stringLiteral: EndPointPath.product.rawValue))
        routesGrouped.post(use: createProduct)
        routesGrouped.get(":\(PathParaemeter.barcode.rawValue)", use: getProduct)
    }
    
    @Sendable
    func getProduct(req: Request) async throws -> ProductDTO {
        guard let barcode = req.parameters.get(PathParaemeter.barcode.rawValue) else {
            throw Abort(.badRequest, reason: "Missing barcode")
        }
        
        let productToFetch = Product(name: "", barcode: barcode)
        guard let existsProduct = try await ProductController.fetchProductWithChildren(db: req.db, product: productToFetch, filterByBarcode: true) else {
            throw Abort(.notFound, reason: "Grocery not found")
        }
        var groceryPrices: [GroceryPriceDTO] = []
        for price in existsProduct.prices {
            if let fetchedPrice = try await PriceController.fetchPriceWithParentRelationships(db: req.db, price: price) {
                groceryPrices.append(.init(name: fetchedPrice.grocery.name, latitude: fetchedPrice.grocery.latitude, longitude: fetchedPrice.grocery.longitude, price: fetchedPrice.price, currency: fetchedPrice.currency))
            }
        }
        return ProductDTO(name: existsProduct.name, barcode: existsProduct.barcode, groceryPrices: groceryPrices)
    }
    
    @Sendable
    func createProduct(req: Request) async throws -> Product {

        let payload = try req.content.decode(Product.CreateProductPayload.self)

        let paylodadProduct = Product(name: payload.name, barcode: payload.barcode)
        
        return try await ProductController.createOrUpdate(db: req.db, product: paylodadProduct)
    }
    
    @discardableResult
    static func createOrUpdate(db: Database, product from: Product) async throws -> Product {
        let existingProduct = try await fetchProductWithChildren(db: db, product: from, filterByBarcode: true)

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
    
    static func fetchProductWithChildren(db: Database, product from: Product, filterByBarcode:Bool = false) async throws -> Product? {
        if filterByBarcode {
            return         try await Product.query(on: db)
                .filter(\.$barcode, .custom("="), from.barcode)
                .with(\.$prices)
                .first()
        } else {
            return         try await Product.query(on: db)
                .filter(\.$id, .custom("="), try from.requireID() )
                .with(\.$prices)
                .first()
        }
    }
}


