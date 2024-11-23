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
}
