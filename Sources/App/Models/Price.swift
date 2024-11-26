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
final class Price: Model, Content, @unchecked Sendable {
    static let schema = "prices"
    
    struct FieldKeys {
        struct v1 {
            static var price: FieldKey { "price" }
            static var currency: FieldKey { "currency" }
            static var productId: FieldKey { "product_id" }
            static var groceryId: FieldKey { "grocery_id" }
            static var createdAt: FieldKey { "created_at" }
            static var updatedAt: FieldKey { "updated_at" }
        }
    }
    /*
     .field("price", .double, .required)
     .field("currency", .string, .required)
     .field("product_id", .uuid, .references(Product.schema, "id"))
     .field("grocery_id", .uuid, .references(Grocery.schema, "id"))
     */
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.v1.price)
    var price: Double
    
    @Field(key: FieldKeys.v1.currency)
    var currency: String
    
    @Parent(key: FieldKeys.v1.productId)
    var product: Product
    
    @Parent(key: FieldKeys.v1.groceryId)
    var grocery: Grocery
    
    @Timestamp(key: FieldKeys.v1.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.v1.updatedAt, on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, price: Double, currency: String, productID: UUID, groceryID: UUID, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.price = price
        self.currency = currency
        self.$product.id = productID
        self.$grocery.id = groceryID
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

extension Price {
    struct CreatePricesPayload: Content {
        var prices: [CreatePricePayload]
        
        mutating func afterDecode() throws {
            guard prices.allSatisfy( { !$0.currency.isEmpty }) else {
                throw Abort(.badRequest, reason: "Currency name cannot be empty")
            }
        }
    }

    struct CreatePricePayload: Content {
        var grocery: Grocery.CreateGroceryPayload
        var product: Product.CreateProductPayload
        var price: Double
        var currency: String
        
        mutating func afterDecode() throws {
            
            guard price.isFinite else {
                throw Abort(.badRequest, reason: "Price must be a finite number")
            }
            
            let currencyName = currency.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !currencyName.isEmpty else {
                throw Abort(.badRequest, reason: "Currency name cannot be empty")
            }
            self.currency = currencyName
        }
    }
}

extension Price.CreatePricePayload {
    init(grocery: Grocery, product: Product, price: Double, currency: String) {
        self.grocery = .init(grocery)
        self.product = .init(product)
        self.price = price
        self.currency = currency
    }

    func toGrocery() -> Grocery {
        Grocery(name: self.grocery.name,
                latitude: self.grocery.latitude,
                longitude: self.grocery.longitude)
    }
    
    func toProduct() -> Product {
        Product(name: self.product.name,
                barcode: self.product.barcode)
    }
}
