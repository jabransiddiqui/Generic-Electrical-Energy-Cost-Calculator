//
//  ValidationService.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

class Validation: NSObject {
    
    public static let shared = Validation()
    
    func validate(values: (type: ValidationType, inputValue: String, fieldName : String)...) -> Valid {
        var requireield : [String] = []
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .require :
                if valueToBeChecked.inputValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                   requireield.append("\(valueToBeChecked.fieldName)")
                }
            }
        }
        if requireield.count > 0 {
            return .failure(.error, requireield)
        }else{
             return .success
        }
    }
    
    func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
    
    func whiteSpaceAndNewLineTrim(text : String) -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func whiteSpaceTrim(text : String) -> String {
        return text.trimmingCharacters(in: .whitespaces)
    }
}
