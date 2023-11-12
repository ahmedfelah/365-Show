//
//  WatchedView.swift
//  ShoofCinema
//
//  Created by mac on 8/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct WatchedView: View {
    
    @StateObject var viewModel = WatchedViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.shows.indices , id: \.self) { index in
                    NavigationLink(destination: {
                        Text("Text")
                    }, label: {
                        HorizontalPosterView(show: viewModel.shows[index].asShoofShow())
                    }).padding(.bottom)
                }
            }.padding()
        }.background(Color.primaryBrand)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Watched")
            .fontWeight(.bold)
    }

}

