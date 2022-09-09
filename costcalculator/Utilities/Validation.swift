//
//  Validation.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

enum ValidationResponse {
    case success
    case failure
    case error
}
enum ValidationType {
    case require
}

enum Valid {
    case success
    case failure(ValidationResponse, [String])
}
