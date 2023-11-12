//
//  LoadingView.swift
//  ShoofCinema
//
//  Created by mac on 7/7/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2)
        }.padding(30)
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(5))
            .cornerRadius(10)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
