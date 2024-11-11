//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 11/11/24.
//
import Foundation
import Fluent
import Vapor
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Grocery: Model, Content, @unchecked Sendable {
    static let schema = "groceries"
    
    struct FieldKeys {
        struct v1 {
            static var name: FieldKey { "name" }
            static var latitude: FieldKey { "latitude" }
            static var longitude: FieldKey { "longitude" }
            static var createdAt: FieldKey { "created_at" }
            static var updatedAt: FieldKey { "updated_at" }
        }
    }
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String
    
    @Field(key: FieldKeys.v1.latitude)
    var latitude: Double
    
    @Field(key: FieldKeys.v1.longitude)
    var longitude: Double
    
    @Children(for: \.$grocery)
    var prices: [Price]
    
    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.v1.updatedAt, on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, name: String, latitude: Double, longitude: Double, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
//    func toDTO() -> TodoDTO {
//        .init(
//            id: self.id,
//            title: self.$title.value
//        )
//    }
}
