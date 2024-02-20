//
//  CircularProgressView.swift
//  365Show
//
//  Created by ممم on 16/02/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI

struct CircularProgressView: View {
    
    @State var progress: Float
    
    var body: some View {
        ZStack {
            // Background for the progress bar
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.1)
                .foregroundColor(.blue)
            
            // Foreground or the actual progress bar
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}
