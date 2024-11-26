//
//  UsersController.swift
//  gigbuddy-server
//
//  Created by Javier Calatrava on 25/11/24.
//

import Vapor
import Fluent

struct UserBasicAuthenticator: AsyncBasicAuthenticator {
    func authenticate(basic: Vapor.BasicAuthorization, for request: Vapor.Request) async throws {
        guard let user = try await User.query(on: request.db)
            .filter(\.$email, .custom("ILIKE"), basic.username)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        guard try Bcrypt.verify(basic.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        request.auth.login(user)
    }
}

struct UserJWTAuthenticator: AsyncBearerAuthenticator {
    func authenticate(bearer: Vapor.BearerAuthorization, for request: Vapor.Request) async throws {
        let payload = try await request.jwt.verify(as: User.Token.self)
        guard let user = try await User.find(payload.userID, on: request.db) else {
            return
        }
        request.auth.login(user)
    }
}

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped(PathComponent(stringLiteral: EndPointPath.user.rawValue))
        users.post(use: create)
        users.post("login", use: login)
        
        let protected = users
            .grouped(UserBasicAuthenticator())
            .grouped(UserJWTAuthenticator())
            .grouped(User.guardMiddleware())
        protected.get("me", use: show)
    }

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
    
    func show(req: Request) async throws -> User.Response {
        let user = try req.auth.require(User.self)
        return try user.response
    }
    
    func login(req: Request) async throws -> [String: String] {
        let loginPayload = try req.content.decode(User.LoginPayload.self)
        guard let user = try await User.query(on: req.db)
            .filter(\.$email, .custom("ILIKE"), loginPayload.email)
            .first() else {
            throw Abort(.unauthorized)
        }
          
        guard try Bcrypt.verify(loginPayload.password, created: user.passwordHash) else {
            throw Abort(.unauthorized)
        }
        
        let jwt = User.Token(subject: .init(stringLiteral: user.email),
                             expiration: .init(value: Date.now.addingTimeInterval(50)),
                             issuer: .init(stringLiteral: User.Token.issuer),
                             issuedAt: .init(value: .now),
                             userID: try user.requireID()
        )
        let encodedJWT = try await req.jwt.sign(jwt)
        
        return ["token": encodedJWT]
    }
}
