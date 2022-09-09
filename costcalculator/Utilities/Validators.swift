//
//  Validators.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

class ValidationError : Error {
    var message : String
    
    init(_ message : String) {
        self.message = message
    }
}

protocol ValidatorConvertable {
    func validate(_ value : String) throws -> String
}

enum ValidatorType{
    case alphanumeric
    case positiveNumber
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertable {
        switch type {
        case .alphanumeric : return alphanumericValidator()
        case .positiveNumber : return positiveNumberValidator()
        }
    }
}

struct alphanumericValidator: ValidatorConvertable {
    func validate(_ value: String) throws -> String {
        do {
           if Validation.shared.isValidRegEx(value, .alphanumericStringWithSpace) != true{
                 throw ValidationError(CustomMessages.invalidAlphanumeric.localized())
             }
        } catch  {
            throw ValidationError(CustomMessages.invalidAlphanumeric.localized())
        }
        return value
    }
}

struct positiveNumberValidator: ValidatorConvertable {
    func validate(_ value: String) throws -> String {
        do {
            let number = value.isInt ? (Int(value) ?? 0) : 0
           if number < 1 {
                 throw ValidationError(CustomMessages.currentReading.localized())
             }
        } catch  {
            throw ValidationError(CustomMessages.currentReading.localized())
        }
        return value
    }
}
