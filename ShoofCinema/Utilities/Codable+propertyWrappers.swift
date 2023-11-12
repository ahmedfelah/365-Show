//
//  Codable+propertyWrappers.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 3/12/21.
//  Copyright © 2022 AppChief. All rights reserved.
//

import Foundation

@propertyWrapper
struct LossyCodableProperty<Value> {
    var value: Value?
    
    var wrappedValue: Value? {
        get { value }
        set { value = newValue }
    }
}

extension LossyCodableProperty : Decodable where Value : Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(Value.self)
    }
}

extension LossyCodableProperty : Encodable where Value : Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try? container.encode(wrappedValue)
    }
}

@propertyWrapper
struct LossyCodableArray<Element> {
    var elements: [Element]
    
    var wrappedValue: [Element] {
        get { elements }
        set { elements = newValue }
    }
}

extension LossyCodableArray : Decodable where Element : Decodable {
    private struct ElementWrapper: Decodable {
       var element: Element?

       init(from decoder: Decoder) throws {
           let container = try decoder.singleValueContainer()
           element = try? container.decode(Element.self)
       }
   }

   init(from decoder: Decoder) throws {
       let container = try decoder.singleValueContainer()
       let wrappers = try container.decode([ElementWrapper].self)
       elements = wrappers.compactMap(\.element)
   }
}

extension LossyCodableArray: Encodable where Element: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for element in elements {
            try? container.encode(element)
        }
    }
}
