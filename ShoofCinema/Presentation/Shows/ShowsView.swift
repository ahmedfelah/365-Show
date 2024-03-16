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
    @State var isPresentedFilter = false
    
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
            .overlay {
                if viewModel.status == .loading {
                    VStack {
                        LoadingView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.2))
                }
                else if viewModel.status == .failed {
                    VStack {
                        ErrorView(action: {Task{viewModel.loadShows()}})
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.toolbar(content: {
                if let type = viewModel.type {
                    switch viewModel.type {
                    case .filter:
                        Button(action: {isPresentedFilter.toggle()}, label: {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundColor(.white)
                        })
                    default:
                        EmptyView()
                    }
                }
            }).sheet(isPresented: $isPresentedFilter, content: {
                if #available(iOS 16, *) {
                    ShowsFilterView(viewModel: viewModel)
                        .presentationDetents([.medium])
                }
                
                else {
                    ShowsFilterView(viewModel: viewModel)
                        
                }
            })
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

