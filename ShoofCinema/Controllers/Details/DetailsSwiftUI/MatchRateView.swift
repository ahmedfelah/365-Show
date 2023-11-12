//
//  MatchRateView.swift
//  ShoofCinema
//
//  Created by mac on 6/2/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct MatchRateView: View {
    let matchRate: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.4))
                .frame(width: 110, height: 110)
            Text("\(matchRate)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(uiColor: Theme.current.tintColor))
        }
    }
}

struct MatchRateView_Previews: PreviewProvider {
    static var previews: some View {
        MatchRateView(matchRate: "70%")
    }
}
