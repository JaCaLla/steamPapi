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
        let users = routes.grouped("users")
        users.post(use: create)
    }

    @Sendable
    func create(req: Request) async throws -> User.Response {
        try User.CreatePayload.validate(content: req)

        let payload = try req.content.decode(User.CreatePayload.self)
        guard payload.password == payload.passwordConfirmation else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }

        let user = try User(
            email: payload.email,
            passwordHash: Bcrypt.hash(payload.password)
        )
        try await user.save(on: req.db)

        return try user.response
    }
}
