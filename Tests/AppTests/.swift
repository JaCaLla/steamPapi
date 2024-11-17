//
//  DoubleExtensionTests.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

@testable import App
import XCTVapor
import Testing
import Fluent
//import SwiftDotenv

@Suite("App Tests with DB", .serialized)
struct DoubleExtensionTests {
    @Test("Double truncate to 4")
    func truncate4() throws {
        #expect(Double(1.12340).truncatingRemainder() == 1.1234)
        #expect(Double(1.12341).truncatingRemainder() == 1.1234)
        #expect(Double(1.12342).truncatingRemainder() == 1.1234)
        #expect(Double(1.12343).truncatingRemainder() == 1.1234)
        #expect(Double(1.12344).truncatingRemainder() == 1.1234)
        #expect(Double(1.12345).truncatingRemainder() == 1.1234)
        #expect(Double(1.12346).truncatingRemainder() == 1.1234)
        #expect(Double(1.12347).truncatingRemainder() == 1.1234)
        #expect(Double(1.12348).truncatingRemainder() == 1.1234)
        #expect(Double(1.12349).truncatingRemainder() == 1.1234)
        
        #expect(Double(-1.12340).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12341).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12342).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12343).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12344).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12345).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12346).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12347).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12348).truncatingRemainder() == 1.1234)
        #expect(Double(-1.12349).truncatingRemainder() == 1.1234)

    }
}
