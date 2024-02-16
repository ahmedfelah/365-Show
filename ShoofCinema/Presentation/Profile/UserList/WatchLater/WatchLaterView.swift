//
//  WatchLaterView.swift
//  ShoofCinema
//
//  Created by mac on 8/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct WatchLaterView: View {
    @StateObject var viewModel = WatchLaterViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.shows.indices , id: \.self) { index in
                    NavigationLink(destination: {
                        ShowDetailsView(viewModel: ShowDetailsViewModel(show: viewModel.shows[index]))
                    }, label: {
                        HorizontalPosterView(show: viewModel.shows[index])
                    }).padding(.bottom)
                }
            }.padding()
        }.background(Color.primaryBrand)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("watch later")
            .overlay {
                if viewModel.status == .loading {
                    VStack {
                        LoadingView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.2))
                }
            }
            .task {
                viewModel.load()
            }
    }
}

