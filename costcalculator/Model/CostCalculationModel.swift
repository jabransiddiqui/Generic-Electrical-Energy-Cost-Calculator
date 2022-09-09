//
//  CostCalculationModel.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

struct CostCalculationModel : Codable {
    let serialNumber : String
    let value : Int
}

struct HistoryModel : Codable {
    let serialNumber : String
    let units : Int
    let cost : Int
}

struct HandleUIErrorModel : Codable {
    let key : String
    let value : String
}
