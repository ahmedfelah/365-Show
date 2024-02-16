//
//  DotsIndexView.swift
//  ShoofCinema
//
//  Created by ممم on 08/10/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct DotsIndexView: View {
    
    // MARK: - Public Properties
    
    let numberOfPages: Int
    let currentIndex: Int
    
    
    // MARK: - Drawing Constants
    
    private let rectangleWidth: CGFloat = 8
    private let rectangleHeight: CGFloat = 8
    
    
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0 ..< numberOfPages) { index in
                if shouldShowIndex(index) {
                    Rectangle()
                        .fill(currentIndex == index ? Color.secondaryBrand : .gray)
                        .frame(width: currentIndex == index ? rectangleWidth * 2 : rectangleWidth, height: rectangleHeight)
                        .cornerRadius(4)
                        .transition(AnyTransition.opacity.combined(with: .scale))
                        .id(index)
                }
            }
        }
    }
    
    // MARK: - Private Methods
      
      func shouldShowIndex(_ index: Int) -> Bool {
        ((currentIndex - 5)...(currentIndex + 5)).contains(index)
      }
    
    }
