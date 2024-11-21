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
        
        #expect(Double(4.56).truncate4Decimals() == 4.56)
        
        #expect(Double(1.234).truncate4Decimals() == 1.234)
        #expect(Double(-2.45678).truncate4Decimals() == -2.4567)
        #expect(Double(3.1).truncate4Decimals() == 3.1)
        #expect(Double(-4.5678).truncate4Decimals() == -4.5678)
        #expect(Double(5.12345).truncate4Decimals() == 5.1234)
        #expect(Double(-6.78).truncate4Decimals() == -6.78)
        #expect(Double(7.345).truncate4Decimals() == 7.345)
        #expect(Double(-8.9012).truncate4Decimals() == -8.9012)
        #expect(Double(9.87654).truncate4Decimals() == 9.8765)
        #expect(Double(-10.1234).truncate4Decimals() == -10.1234)
        #expect(Double(11.2).truncate4Decimals() == 11.2)
        #expect(Double(-12.34567).truncate4Decimals() == -12.3456)
        #expect(Double(13.4567).truncate4Decimals() == 13.4567)
        #expect(Double(-14.8765).truncate4Decimals() == -14.8765)
        #expect(Double(15.1234).truncate4Decimals() == 15.1234)
        #expect(Double(-16.789).truncate4Decimals() == -16.789)
        #expect(Double(17.56789).truncate4Decimals() == 17.5678)
        #expect(Double(-18.123).truncate4Decimals() == -18.123)
        #expect(Double(19.4).truncate4Decimals() == 19.4)
        #expect(Double(-20.567).truncate4Decimals() == -20.567)
    }
}
