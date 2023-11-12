//
//  LoadingSpinnerView.swift
//  ShoofCinema
//
//  Created by mac on 4/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct LoadingSpinner: View {

    @State private var shouldAnimate = false
        
        var body: some View {
            Circle()
                .fill(Color(uiColor: Theme.current.tintColor))
                .frame(width: 30, height: 30)
                .overlay(
                    ZStack {
                        Circle()
                            .stroke(Color(uiColor: Theme.current.tintColor), lineWidth: 100)
                            .scaleEffect(shouldAnimate ? 1 : 0)
                        Circle()
                            .stroke(Color(uiColor: Theme.current.tintColor), lineWidth: 100)
                            .scaleEffect(shouldAnimate ? 1.5 : 0)
                        Circle()
                            .stroke(Color(uiColor: Theme.current.tintColor), lineWidth: 100)
                            .scaleEffect(shouldAnimate ? 2 : 0)
                    }
                    .opacity(shouldAnimate ? 0.0 : 0.2)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false))
            )
            .onAppear {
                self.shouldAnimate = true
            }
        }
}

// MARK: SpinnerCircle
struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LoadingSpinner()
        }
    }
}
