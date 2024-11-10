//
//  CreateProductShopAndPrice.swift
//  steamPapi
//
//  Created by Javier Calatrava on 10/11/24.
//

import Fluent



struct CreateProductShopAndPrice: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schemas.products.rawValue)
            .id()
            .field("name", .string, .required)
            .field("barcode", .string, .required)
            .unique(on: "barcode")
            .timestamps()
            .create()
        
        try await database.schema(Schemas.groceries.rawValue)
            .id()
            .field("name", .string, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .timestamps()
            .create()
        
        try await database.schema(Schemas.prices.rawValue)
            .id()
            .field("price", .double, .required)
            .field("product_id", .uuid, .references(Schemas.products.rawValue, "id"))
            .field("grocery_id", .uuid, .references(Schemas.groceries.rawValue, "id"))
            .timestamps()
            .create()

    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Schemas.products.rawValue).delete()
        try await database.schema(Schemas.groceries.rawValue).delete()
        try await database.schema(Schemas.prices.rawValue).delete()
    }
}
