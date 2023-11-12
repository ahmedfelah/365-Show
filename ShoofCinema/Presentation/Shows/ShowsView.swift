//
//  ShowsView.swift
//  ShoofCinema
//
//  Created by mac on 7/17/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct ShowsView: View {
    
    @StateObject var viewModel: ShowViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.shows.indices , id: \.self) { index in
                    NavigationLink(destination: {
                        ShowDetailsView(viewModel: ShowDetailsViewModel(show: viewModel.shows[index]))
                    }, label: {
                        HorizontalPosterView(show: viewModel.shows[index])
                            .onAppear {
                                if viewModel.shows.last?.id == viewModel.shows[index].id {
                                    viewModel.loadMoreShows()
                                }
                            }
                    }).padding(.bottom)
                }
            }.padding()
        }.background(Color.primaryBrand)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Categories")
            .fontWeight(.bold)
            .overlay {
                if viewModel.status == .loading {
                    VStack {
                        LoadingView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.2))
                }
            }
            .task {
                guard viewModel.shows.isEmpty else {return}
                viewModel.loadShows()
            }
    }
    
    @ViewBuilder private var showFilter: some View {
        switch viewModel.type {
        case .shows:
            ShowsFilterView(viewModel: viewModel)
            
        default:
            EmptyView()
        }
    }
}

