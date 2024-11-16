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
        let groceries = routes.grouped("groceries")
        groceries.post(use: createGrocery)
    }
    
    @Sendable
    func createGrocery(req: Request) async throws -> Grocery {
        
        let payload = try req.content.decode(CreateGroceryPayload.self)
        let grocery = Grocery(name: payload.name, latitude: payload.latitude, longitude: payload.longitude)
        try await grocery.save(on: req.db)
        return grocery
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
        
        guard longitude.isFinite else {
            throw Abort(.badRequest, reason: "Longitude must be a finite number")
        }
        
    }
}
