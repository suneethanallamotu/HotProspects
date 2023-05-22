//
//  Extension+Sequence.swift
//  HotProspects
//
//  Created by Suneetha Nallamotu on 5/17/23.
//

import Foundation
extension Sequence {
    public func random(_ num: Int) -> [Element] {
        Array(shuffled().prefix(num))
    }
}
