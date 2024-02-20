//
//  ErrorView.swift
//  365Show
//
//  Created by ممم on 17/02/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    var action: () -> Void
    
    var body: some View {
        VStack {
            Text("Something went wrong")
                .padding()
                .foregroundColor(.white)
            
            Button(action: action) {
                Text("Try agin")
                    .foregroundColor(.primaryBrand)
                    
            }.padding()
                .background(Color.secondaryBrand)
                .clipShape(Capsule())
                .padding()
        }
    }
}
