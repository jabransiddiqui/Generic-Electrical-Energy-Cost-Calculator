//
//  +CollectionType.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

extension Collection {
    
    func last(count:Int) -> [Self.Iterator.Element] {
        let selfCount = self.count
        if selfCount <= count - 1 {
            return Array(self)
        } else {
            return Array(self.reversed()[0...count - 1].reversed())
        }
    }
    
}
