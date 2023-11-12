//
//  NSLayoutConstraint+ArrayBuilder.swift
//  ShoofCinema
//
//  Created by Zaid Rahhawi on 4/10/22.
//  Copyright © 2022 AppChief. All rights reserved.
//

import UIKit

@resultBuilder
public struct ArrayBuilder {
    public static func buildExpression<Item>(_ element: Item) -> [Item] {
        return [element]
    }
    
    public static func buildOptional<Item>(_ component: [Item]?) -> [Item] {
        return component ?? []
    }
    
    public static func buildEither<Item>(first component: [Item]) -> [Item] {
        return component
    }
    
    public static func buildEither<Item>(second component: [Item]) -> [Item] {
        return component
    }
    
    public static func buildArray<Item>(_ components: [[Item]]) -> [Item] {
        return Array(components.joined())
    }
    
    public static func buildBlock<Item>(_ components: [Item]...) -> [Item] {
        return Array(components.joined())
    }
}

extension NSLayoutConstraint {
    static func activate(@ArrayBuilder _ constraints: () -> [NSLayoutConstraint]) {
        activate(constraints())
    }
    
    static func deactivate(@ArrayBuilder _ constraints: () -> [NSLayoutConstraint]) {
        deactivate(constraints())
    }
}
