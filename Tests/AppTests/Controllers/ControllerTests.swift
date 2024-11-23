@testable import App
import XCTVapor
import Testing
import Fluent
//import SwiftDotenv

@Suite("App Tests with DB", .serialized)
struct ControllerTests {
     static func withApp(_ test: (Application) async throws -> ()) async throws {

        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        }
        catch {
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}

extension CreateGroceryPayload {
    static let sampleG1: CreateGroceryPayload = .init(name: "sG1", latitude: 23.3, longitude: 23.3)
    static let sampleG2: CreateGroceryPayload = .init(name: "sG2", latitude: 23.3, longitude: 23.4)
    static let sampleG3: CreateGroceryPayload = .init(name: "sG3", latitude: 23.4, longitude: 23.3)
}

extension CreateProductPayload {
    static let sampleP1: CreateProductPayload = .init(name: "sP1", barcode: "1111")
    static let sampleP2: CreateProductPayload = .init(name: "sP2", barcode: "2222")
    static let sampleP3: CreateProductPayload = .init(name: "sP3", barcode: "3333")
}

extension Array where Element == CreatePricePayload {
    static var sample: Self {
        [
            .samplePriceG1P1,
            .samplePriceG1P2,
            .samplePriceG1P3,
            .samplePriceG2P2,
            .samplePriceG2P3,
            .samplePriceG3P1
        ]
    }
}

extension CreatePricePayload {
    static let samplePriceG1P1: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG1,
        product: .sampleP1,
        price: 1.1,
        currency: "EUR"
    )
    static let samplePriceG1P2: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG1,
        product: .sampleP2,
        price: 1.2,
        currency: "EUR"
    )
    static let samplePriceG1P3: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG1,
        product: .sampleP3,
        price: 1.3,
        currency: "EUR"
    )
    static let samplePriceG2P2: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG2,
        product: .sampleP2,
        price: 2.2,
        currency: "EUR"
    )
    static let samplePriceG2P3: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG2,
        product: .sampleP3,
        price: 2.3,
        currency: "EUR"
    )
    static let samplePriceG3P1: CreatePricePayload = CreatePricePayload(
        grocery: .sampleG3,
        product: .sampleP1,
        price: 3.1,
        currency: "EUR"
    )
}
