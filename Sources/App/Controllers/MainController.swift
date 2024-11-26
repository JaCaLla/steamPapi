//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 16/11/24.
//

import Fluent
import Vapor

struct MainController: RouteCollection {
    func boot(routes: any Vapor.RoutesBuilder) throws {
        let groceries = routes.grouped("reset")
        groceries.post(use: reset)
    }
    
    @Sendable
    func reset(req: Request) async throws -> [Grocery] {
        
        try await Price.query(on: req.db).delete()
        try await Grocery.query(on: req.db).delete()
        try await Product.query(on: req.db).delete()
        try await User.query(on: req.db).delete()
        throw Abort(.ok)
    }
}
