//
//  Messages.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

enum CustomMessages: String {
    case emptySerialNumber = "Serial number can not be empty."
    case emptyCurrentReading = "Current reading can not be empty."
    case invalidAlphanumeric = "Invalid Alphanumeric string."
    case serialNumber = "Serial number should be 10 digits alphanumeric"
    case serialNumberCopyPaste = "The serial number you pasted is greater than 10 digits alphanumeric"
    case currentReading = "Current reading should be greater than 0 and previous reading"
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
