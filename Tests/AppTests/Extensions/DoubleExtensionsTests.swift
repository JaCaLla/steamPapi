//
//  File.swift
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
struct DoubleExtensionsTests {
    
    @Test("Check 4 truncated decimals")
    func truncate4() {
        #expect(Double(1.12340).truncate4Decimals() == 1.1234)
        #expect(Double(1.12341).truncate4Decimals() == 1.1234)
        #expect(Double(1.12342).truncate4Decimals() == 1.1234)
        #expect(Double(1.12343).truncate4Decimals() == 1.1234)
        #expect(Double(1.12344).truncate4Decimals() == 1.1234)
        #expect(Double(1.12345).truncate4Decimals() == 1.1234)
        #expect(Double(1.12346).truncate4Decimals() == 1.1234)
        #expect(Double(1.12347).truncate4Decimals() == 1.1234)
        #expect(Double(1.12348).truncate4Decimals() == 1.1234)
        #expect(Double(1.12349).truncate4Decimals() == 1.1234)
        
        #expect(Double(-1.12340).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12341).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12342).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12343).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12344).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12345).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12346).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12347).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12348).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12349).truncate4Decimals() == -1.1234)
                
        #expect(Double(1).truncate4Decimals() == 1)
        #expect(Double(1.1).truncate4Decimals() == 1.1)
        #expect(Double(1.12).truncate4Decimals() == 1.12)
        #expect(Double(1.123).truncate4Decimals() == 1.123)
        #expect(Double(1.1234).truncate4Decimals() == 1.1234)
        #expect(Double(1.12345).truncate4Decimals() == 1.1234)
        #expect(Double(1.123456).truncate4Decimals() == 1.1234)
        
        #expect(Double(-1).truncate4Decimals() == -1)
        #expect(Double(-1.1).truncate4Decimals() == -1.1)
        #expect(Double(-1.12).truncate4Decimals() == -1.12)
        #expect(Double(-1.123).truncate4Decimals() == -1.123)
        #expect(Double(-1.1234).truncate4Decimals() == -1.1234)
        #expect(Double(-1.12345).truncate4Decimals() == -1.1234)
        #expect(Double(-1.123456).truncate4Decimals() == -1.1234)
    }
}
