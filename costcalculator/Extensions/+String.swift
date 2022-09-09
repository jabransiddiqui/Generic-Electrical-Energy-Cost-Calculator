//
//  +String.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

extension String {
    
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validate(self)
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
}
