//
//  CostCalculationViewModel.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

// MARK : Response of Service class
protocol CostCalculationViewModel {
    func requireSuccess()
    func validationSuccess(serialNumber : String, currentReading: String)
    func success()
    func failure(error: Error)
    func handleSerialNumber(value : String)
    func handleCurrentReading(value : String)
    func handle(errorFields: [HandleUIErrorModel])
    func showBillWithBreakdown(billBreakDown: [CostCalculationModel])
    func showHistory(historyValues: [HistoryModel])
}
