//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 22/11/24.
//

@testable import App
import XCTVapor
import Testing
import Fluent


extension ControllerTests {
    struct GroceryControllerTests {
        
        @Test("Create Groceries")
        func createGroceries() async throws {
            let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.name == "MD")
                    #expect(groceryAdded.latitude == 1.2)
                    #expect(groceryAdded.longitude == 1.3)
                })
            }
        }
        
        @Test("Create Groceries Twice")
        func createGroceriesTwice() async throws {
            let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    try await app.test(.POST, "grocery", beforeRequest: { req in
                        try req.content.encode(newGrocery)
                    }, afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        let groceryAdded2nd = try res.content.decode(Grocery.self)
                        #expect(groceryAdded.id == groceryAdded2nd.id)
                        #expect(groceryAdded2nd.name == "MD")
                    })
                })
            }
        }
        
        @Test("Create Groceries Twice replacing name")
        func createGroceriesTwiceReplacingNamee() async throws {
            let newGrocery = Grocery(name: "MD", latitude: 1.2, longitude: 1.3)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    let newGrocery2 = Grocery(name: "MD2", latitude: 1.2, longitude: 1.3)
                    try await app.test(.POST, "grocery", beforeRequest: { req in
                        try req.content.encode(newGrocery2)
                    }, afterResponse: { res async throws in
                        #expect(res.status == .ok)
                        let groceryAdded2nd = try res.content.decode(Grocery.self)
                        #expect(groceryAdded.id == groceryAdded2nd.id)
                    })
                })
            }
        }
        
        @Test("Create Groceries when name is empty")
        func createGroceriesWhenNameEmpty() async throws {
            let newGrocery = Grocery(name: "", latitude: 1.2, longitude: 1.3)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Create Groceries when name is trimmed")
        func createGroceriesTrimName() async throws {
            let newGrocery = Grocery(name: "      MD    ", latitude: 1.2, longitude: 1.3)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.name == "MD")
                })
            }
        }
        
        @Test("Create Groceries with lat long > 5 decs")
        func createGroceriesLanLon5DecsNeg() async throws {
            let newGrocery = Grocery(name: "MD", latitude: -1.12345, longitude: 2.123)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.latitude == -1.1234)
                    #expect(groceryAdded.longitude == 2.123)
                })
            }
        }
        
        @Test("Create Groceries with lat long > 5 decs")
        func createGroceriesLanLon5Decs() async throws {
            let newGrocery = Grocery(name: "MD", latitude: 1.12345, longitude: 2.123)
            try await ControllerTests.withApp { app in
                try await app.test(.POST, "grocery", beforeRequest: { req in
                    try req.content.encode(newGrocery)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryAdded = try res.content.decode(Grocery.self)
                    #expect(groceryAdded.latitude == 1.1234)
                    #expect(groceryAdded.longitude == 2.123)
                })
            }
        }
        
        @Test("Fetch a grocery tha does not exists")
        func fetchGroceryThatDoesNotExist() async throws {
            try await ControllerTests.withApp { app in
                try await app.test(.GET, "grocery/23.3,23.5", afterResponse: { res async throws in
                    #expect(res.status == .notFound)
                })
            }
        }
        
        @Test("Fetch a grocery with wrong coordinator format")
        func fetchGroceryWrongCoordinatorFormat() async throws {
            try await ControllerTests.withApp { app in
                try await app.test(.GET, "grocery/23.3-23.4", afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Fetch a grocery with its prodcuts")
        func fetchGroceryWithItsProducts() async throws {
            try await ControllerTests.withApp { app in
                let prices = try await PriceController.createOrUpdatePrices(db: app.db, payloads: .sample)
                #expect(prices.count == 6)
                try await app.test(.GET, "grocery/23.3,23.3", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryDTO = try res.content.decode(GroceryDTO.self)
                    #expect(groceryDTO.name == "sG1")
                    #expect(groceryDTO.latitude == 23.3)
                    #expect(groceryDTO.longitude == 23.3)
                    #expect(groceryDTO.productsPrices.count == 3)
                    #expect(groceryDTO.productsPrices[0].name == "sP1")
                    #expect(groceryDTO.productsPrices[0].barcode == "1111")
                    #expect(groceryDTO.productsPrices[0].price == 1.1)
                    #expect(groceryDTO.productsPrices[0].currency == "EUR")
                    #expect(groceryDTO.productsPrices[1].name == "sP2")
                    #expect(groceryDTO.productsPrices[1].barcode == "2222")
                    #expect(groceryDTO.productsPrices[1].price == 1.2)
                    #expect(groceryDTO.productsPrices[1].currency == "EUR")
                    #expect(groceryDTO.productsPrices[2].name == "sP3")
                    #expect(groceryDTO.productsPrices[2].barcode == "3333")
                    #expect(groceryDTO.productsPrices[2].price == 1.3)
                    #expect(groceryDTO.productsPrices[2].currency == "EUR")
                })
                try await app.test(.GET, "grocery/23.3,23.4", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryDTO = try res.content.decode(GroceryDTO.self)
                    #expect(groceryDTO.name == "sG2")
                    #expect(groceryDTO.latitude == 23.3)
                    #expect(groceryDTO.longitude == 23.4)
                    #expect(groceryDTO.productsPrices.count == 2)
                    #expect(groceryDTO.productsPrices[0].name == "sP2")
                    #expect(groceryDTO.productsPrices[0].barcode == "2222")
                    #expect(groceryDTO.productsPrices[0].price == 2.2)
                    #expect(groceryDTO.productsPrices[0].currency == "EUR")
                    #expect(groceryDTO.productsPrices[1].name == "sP3")
                    #expect(groceryDTO.productsPrices[1].barcode == "3333")
                    #expect(groceryDTO.productsPrices[1].price == 2.3)
                    #expect(groceryDTO.productsPrices[1].currency == "EUR")
                })
                try await app.test(.GET, "grocery/23.4,23.3", afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let groceryDTO = try res.content.decode(GroceryDTO.self)
                    #expect(groceryDTO.name == "sG3")
                    #expect(groceryDTO.latitude == 23.4)
                    #expect(groceryDTO.longitude == 23.3)
                    #expect(groceryDTO.productsPrices.count == 1)
                    #expect(groceryDTO.productsPrices[0].name == "sP1")
                    #expect(groceryDTO.productsPrices[0].barcode == "1111")
                    #expect(groceryDTO.productsPrices[0].price == 3.1)
                    #expect(groceryDTO.productsPrices[0].currency == "EUR")
                })
            }
        }
    }
}
