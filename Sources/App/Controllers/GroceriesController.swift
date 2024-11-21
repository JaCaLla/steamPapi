//
//  GroceriesController.swift
//  steamPapi
//
//  Created by Javier Calatrava on 15/11/24.
//

import Vapor
import Fluent

struct GroceriesController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let groceries = routes.grouped(PathComponent(stringLiteral: Grocery.schema))
        groceries.post(use: createGrocery)
    }
    
    @Sendable
    func createGrocery(req: Request) async throws -> Grocery {

        let payload = try req.content.decode(CreateGroceryPayload.self)
        
        let paylodadGrocery = Grocery(name: payload.name, latitude: payload.latitude, longitude: payload.longitude)
        
        return try await GroceriesController.createOrUpdate(db: req.db, grocery: paylodadGrocery)
    }
    
    @discardableResult
    static func createOrUpdate(db: Database, grocery from: Grocery) async throws -> Grocery {
        let existingGrocery = try await Grocery.query(on:db)
            .filter(\.$latitude, .custom("="), from.latitude)
            .filter(\.$longitude, .custom("="), from.longitude)
            .first()

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
    
    static func fetchGroceryWithParentRelationships(db: Database, grocery: Grocery) async throws  -> Grocery? {
        try await Grocery.query(on: db)
            .filter(\.$id, .custom("="), try grocery.requireID() )
            .with(\.$prices)
            .first()
    }
}

struct CreateGroceryPayload: Content {
    var name: String
    var latitude: Double
    var longitude: Double
    
    mutating func afterDecode() throws {
        let groceryName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !groceryName.isEmpty else {
            throw Abort(.badRequest, reason: "Grocery name cannot be empty")
        }
        self.name = groceryName
        
        guard latitude.isFinite else {
            throw Abort(.badRequest, reason: "Latitude must be a finite number")
        }
        self.latitude = latitude.truncate4Decimals()
        
        guard longitude.isFinite else {
            throw Abort(.badRequest, reason: "Longitude must be a finite number")
        }
        self.longitude = longitude.truncate4Decimals()
    }
}

extension CreateGroceryPayload {
    init(_ from: Grocery) {
        self.name = from.name
        self.latitude = from.latitude
        self.longitude = from.longitude
    }
}
