//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 22/11/24.
//

import Foundation

extension String {
    func parseCoordinates() -> (latitude: Double, longitude: Double)? {
        let coordinatesArray = self.split(separator: ",")

        guard coordinatesArray.count == 2,
            let latitude = Double(coordinatesArray[0]),
            let longitude = Double(coordinatesArray[1]) else {
            return nil
        }
        return (latitude.truncate4Decimals(), longitude.truncate4Decimals())
    }
    
    func containsJWT() -> Bool {

        let components = self.split(separator: ".")
        
        guard components.count == 3 else {
            return false
        }
        
        let base64Regex = "^[A-Za-z0-9_-]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", base64Regex)
        
        for component in components {
            if !predicate.evaluate(with: component) {
                return false
            }
        }
        
        return true
    }
}
