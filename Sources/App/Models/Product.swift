//
//  Product.swift
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
final class Product: Model, Content, @unchecked Sendable {
    static let schema = "products"
    
    struct FieldKeys {
        struct v1 {
            static var name: FieldKey { "name" }
            static var barcode: FieldKey { "barcode" }
            static var createdAt: FieldKey { "created_at" }
            static var updatedAt: FieldKey { "updated_at" }
        }
    }
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.v1.name)
    var name: String
    
    @Field(key: FieldKeys.v1.barcode)
    var barcode: String
    
    @Children(for: \.$product)
    var prices: [Price]
    
    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.v1.updatedAt, on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, name: String, barcode: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.barcode = barcode
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
