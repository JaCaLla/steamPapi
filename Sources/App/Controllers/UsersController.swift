//
//  UsersController.swift
//  gigbuddy-server
//
//  Created by Javier Calatrava on 25/11/24.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped(PathComponent(stringLiteral: EndPointPath.user.rawValue))
        users.post(use: create)
    }

    @Sendable
    func create(req: Request) async throws -> User.Response {
        try User.CreatePayload.validate(content: req)

        let payload = try req.content.decode(User.CreatePayload.self)
        return try await UsersController.create(payload: payload, db: req.db)
    }
    
    static func create(payload: User.CreatePayload, db: Database) async throws -> User.Response {
        guard payload.password == payload.passwordConfirmation else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        let userToFetch = User(email: payload.email, passwordHash: "")
        guard try await fetchUser(user: userToFetch, db: db) == nil else {
            throw Abort(.conflict, reason: "User already exists")
        }

        let user = try User(
            email: payload.email,
            passwordHash: Bcrypt.hash(payload.password)
        )
        
        try await user.save(on: db)

        return try user.response
    }
    
    static func fetchUser(user from: User, db: Database) async throws -> User? {
        return  try await User.query(on: db)
            .filter(\.$email, .custom("="), from.email)
            .first()
    }
}
