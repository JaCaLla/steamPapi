//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 26/11/24.
//

@testable import App
import Fluent
import Testing
import XCTVapor

extension ControllerTests {
    struct UserControllerTests {
        let endpoint = "user"
        @Test("Create User")
        func createUser() async throws {
            try await ControllerTests.withApp { app in
                try await app.test(.POST, endpoint, beforeRequest: { req in
                    let payload = User.CreatePayload(email: "email@gmail.com", password: "1234567890", passwordConfirmation: "1234567890")
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let userResponse = try res.content.decode(User.Response.self)
                    #expect(userResponse.email == "email@gmail.com")
                    #expect(!userResponse.id.uuidString.isEmpty)
                })
            }
        }
        
        @Test("Create same user twice")
        func createSameUserTwice() async throws {
            try await ControllerTests.withApp { app in
                try await User.query(on: app.db).delete()
                let payload = User.CreatePayload(email: "email@gmail.com", password: "1234567890", passwordConfirmation: "1234567890")
                _ = try await UsersController.create(payload: payload, db: app.db)
                try await app.test(.POST, endpoint, beforeRequest: { req in
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .conflict)
                })
            }
        }
        
        @Test("Create different user twice")
        func createDifferentUserTwice() async throws {
            try await ControllerTests.withApp { app in
                try await User.query(on: app.db).delete()
                let payload1 = User.CreatePayload(email: "email@gmail.com", password: "1234567890", passwordConfirmation: "1234567890")
                _ = try await UsersController.create(payload: payload1, db: app.db)
                try await app.test(.POST, endpoint, beforeRequest: { req in
                    let payload2 = User.CreatePayload(email: "email2@gmail.com", password: "1234567890", passwordConfirmation: "1234567890")
                    try req.content.encode(payload2)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                })
            }
        }
        
        @Test("Create with different password confirmation")
        func createUserWithDifferentPassword() async throws {
            try await ControllerTests.withApp { app in
                try await app.test(.POST, endpoint, beforeRequest: { req in
                    let payload = User.CreatePayload(email: "email@gmail.com", password: "1234567890", passwordConfirmation: "123456789")
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Create with invalid email")
        func createUserWithInvalidEmail() async throws {
            try await ControllerTests.withApp { app in
                try await app.test(.POST, endpoint, beforeRequest: { req in
                    let payload = User.CreatePayload(email: "email@gmailcom", password: "1234567890", passwordConfirmation: "1234567890")
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .badRequest)
                })
            }
        }
        
        @Test("Access to securized API")
        func accessToSecurizedAPI() async throws {
            try await ControllerTests.withApp { app in
                try await User.query(on: app.db).delete()
                let email = "javi.calatrava@gmail.com"
                let password = "patatata"
                let payload = User.CreatePayload(email: email, password: password, passwordConfirmation: password)
                _ = try await UsersController.create(payload: payload, db: app.db)
                
                let credentials = "\(email):\(password)"
                let encodedCredentials = Data(credentials.utf8).base64EncodedString()
                
                try await app.test(.GET,
                                   "user/me",
                                   headers:  ["Authorization": "Basic \(encodedCredentials)"],
                                   beforeRequest: { req in
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .ok)
                    let userResponse = try res.content.decode(User.Response.self)
                    #expect(userResponse.email == "javi.calatrava@gmail.com")
                })
            }
        }
        
        @Test("Access to securized API with wrong password")
        func accessToSecurizedAPIWrongPassword() async throws {
            try await ControllerTests.withApp { app in
                try await User.query(on: app.db).delete()
                let email = "javi.calatrava@gmail.com"
                let password = "patatata"
                let payload = User.CreatePayload(email: email, password: password, passwordConfirmation: password)
                _ = try await UsersController.create(payload: payload, db: app.db)
                
                let credentials = "\(email):WrongPass"
                let encodedCredentials = Data(credentials.utf8).base64EncodedString()
                
                try await app.test(.GET,
                                   "user/me",
                                   headers:  ["Authorization": "Basic \(encodedCredentials)"],
                                   beforeRequest: { req in
                    try req.content.encode(payload)
                }, afterResponse: { res async throws in
                    #expect(res.status == .unauthorized)
                })
            }
        }
    }
}
