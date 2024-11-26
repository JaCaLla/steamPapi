//
//  File.swift
//  gigbuddy-server
//
//  Created by Javier Calatrava on 25/11/24.
//

import Fluent
import Vapor

final class User: Model, Content, Authenticatable, @unchecked Sendable /* Not possible let id: UUID?*/  {
    static let schema = "users"
    
    struct FieldKeys {
        struct v1 {
            static var email: FieldKey { "email" }
            static var passwordHash: FieldKey { "password_hash" }
            static var createdAt: FieldKey { "created_at" }
            static var updatedAt: FieldKey { "updated_at" }
        }
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.v1.email)
    var email: String
    
    @Field(key: FieldKeys.v1.passwordHash)
    var passwordHash: String
    
    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.v1.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() {
        
    }
    
    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    struct CreatePayload: Codable, Validatable {
        var email: String
        var password: String
        var passwordConfirmation: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: .email)
            validations.add("password", as: String.self, is: .count(8...1000))
        }
    }
    
    struct LoginPayload: Content, Validatable {
        var email: String
        var password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("email", as: String.self, is: !.empty)
            validations.add("password", as: String.self, is: !.empty)
        }
    }
    
    struct Response: Content {
        let id: UUID
        let email: String
        
        init(user: User) throws {
            self.id = try user.requireID()
            self.email = user.email
        }
    }
    
    var response: Response {
        get throws { try Response(user: self) }
    }
}
