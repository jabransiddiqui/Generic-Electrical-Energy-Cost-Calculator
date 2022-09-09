//
//  RegEx.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

enum RegEx: String {
    case alphanumericStringWithSpace = "^(?! )[A-Za-z0-9 ]*(?<! )$"
    case currentReadingString = "^0*[1-9]"
}
