//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

import Foundation

extension Double {
    func truncate4Decimals() -> Double {
        let doubleStr = String(format: "%.5f", self)
        return Double(doubleStr.prefix(doubleStr.count - 1)) ?? 0.0
   }
}
