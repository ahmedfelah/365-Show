//
//  ArrayExtension.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 5/9/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation


extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
    
    
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
