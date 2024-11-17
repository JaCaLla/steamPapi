//
//  File.swift
//  steamPapi
//
//  Created by Javier Calatrava on 17/11/24.
//

import Foundation

extension Double {
    func truncate4Decimals() -> Double {
       let factor = pow(10.0, Double(4))
       return Double(Int(self * factor)) / factor
   }
}
