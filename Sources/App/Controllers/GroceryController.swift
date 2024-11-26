//
//  GroceriesController.swift
//  steamPapi
//
//  Created by Javier Calatrava on 15/11/24.
//

import Vapor
import Fluent

struct GroceryDTO: Content {
    let name: String
    let latitude: Double
    let longitude: Double
    let productsPrices: [ProductPricesDTO]
}

struct ProductPricesDTO: Content {
    let name: String
    let barcode: String
    let price: Double
    let currency: String
}

struct GroceryController: RouteCollection {

    enum PathParaemeter: String {
        case coordinates
    }

    func boot(routes: any Vapor.RoutesBuilder) throws {
        let routesGrouped = routes.grouped(PathComponent(stringLiteral: EndPointPath.grocery.rawValue))
        routesGrouped.post(use: createGrocery)
        routesGrouped.get(":\(PathParaemeter.coordinates.rawValue)", use: getGrocery)
    }

    @Sendable
    func getGrocery(req: Request) async throws -> GroceryDTO {
        guard let coordinates = req.parameters.get(PathParaemeter.coordinates.rawValue),
            let coordinatesPair = coordinates.parseCoordinates() else {
            throw Abort(.badRequest, reason: "Invalid GPS coordinates")
        }

        let groceryToFetch = Grocery(name: "", latitude: coordinatesPair.latitude, longitude: coordinatesPair.longitude)
        guard let existsGrocery = try await GroceryController.fetchGroceryWithChildren(db: req.db, grocery: groceryToFetch, filterByCoordinates: true) else {
            throw Abort(.notFound, reason: "Grocery not found")
        }
        var productPricesDTO: [ProductPricesDTO] = []
        for price in existsGrocery.prices {
            if let fetchedPrice = try await PriceController.fetchPriceWithParentRelationships(db: req.db, price: price) {
                productPricesDTO.append(.init(name: fetchedPrice.product.name, barcode: fetchedPrice.product.barcode, price: fetchedPrice.price, currency: fetchedPrice.currency))
            }
        }
        return GroceryDTO(name: existsGrocery.name, latitude: existsGrocery.latitude, longitude: existsGrocery.longitude, productsPrices: productPricesDTO)
    }

    @Sendable
    func createGrocery(req: Request) async throws -> Grocery {

        let payload = try req.content.decode(Grocery.CreateGroceryPayload.self)

        let paylodadGrocery = Grocery(name: payload.name, latitude: payload.latitude, longitude: payload.longitude)

        return try await GroceryController.createOrUpdate(db: req.db, grocery: paylodadGrocery)
    }


    static func fetchGroceryWithChildren(db: Database, grocery from: Grocery, filterByCoordinates: Bool = false) async throws -> Grocery? {
        if filterByCoordinates {
            return try await Grocery.query(on: db)
                .filter(\.$latitude, .custom("="), from.latitude)
                .filter(\.$longitude, .custom("="), from.longitude)
                .with(\.$prices)
                .first()
        } else {
            return try await Grocery.query(on: db)
                .filter(\.$id, .custom("="), try from.requireID())
                .with(\.$prices)
                .first()
        }

    }

    @discardableResult
    static func createOrUpdate(db: Database, grocery from: Grocery) async throws -> Grocery {
        let existingGrocery = try await fetchGroceryWithChildren(db: db, grocery: from, filterByCoordinates: true)

        let grocery: Grocery
        if let existingGrocery {
            grocery = existingGrocery
            grocery.name = from.name
        } else {
            grocery = from
        }
        try await grocery.save(on: db)
        return grocery
    }
}
