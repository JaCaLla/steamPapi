//
//  CreateProductShopAndPrice.swift
//  steamPapi
//
//  Created by Javier Calatrava on 10/11/24.
//

import Fluent



struct CreateProductGroceryAndPrice: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Product.schema)
            .id()
            .field(Product.FieldKeys.v1.name, .string, .required)
            .field(Product.FieldKeys.v1.barcode, .string, .required)
            .unique(on: Product.FieldKeys.v1.barcode)
            .timestamps()
            .create()
        
        try await database.schema(Grocery.schema)
            .id()
            .field(Grocery.FieldKeys.v1.name, .string, .required)
            .field(Grocery.FieldKeys.v1.latitude, .double, .required)
            .field(Grocery.FieldKeys.v1.longitude, .double, .required)
            .timestamps()
            .create()
        
        try await database.schema(Price.schema)
            .id()
            .field(Price.FieldKeys.v1.price, .double, .required)
            .field(Price.FieldKeys.v1.currency, .string, .required)
            .field(Price.FieldKeys.v1.productId, .uuid, .references(Product.schema, .id))
            .field(Price.FieldKeys.v1.groceryId, .uuid, .references(Grocery.schema, .id))
            .timestamps()
            .create()

    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Price.schema).delete()
        try await database.schema(Product.schema).delete()
        try await database.schema(Grocery.schema).delete()
    }
}
