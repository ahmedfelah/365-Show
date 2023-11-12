//
//  WatchButtonView.swift
//  ShoofCinema
//
//  Created by mac on 6/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct WatchButtonView: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "play.fill")
                    .foregroundColor(.tertiaryBrand)
                
                Text("watch")
                    .textCase(.uppercase)
                    .foregroundColor(.tertiaryBrand)
                
            }
        }
    }
}

struct WatchButtonView_Previews: PreviewProvider {
    static var previews: some View {
        WatchButtonView()
    }
}
