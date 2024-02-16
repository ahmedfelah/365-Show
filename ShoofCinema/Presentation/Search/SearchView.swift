//
//  SearchView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @StateObject var viewModel = SearchViewModel()
    @State private var showingfilter = false
    @State private var filterBadge = [String: String?]()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Button(action: {
                        viewModel.mediaType = .all
                    }, label: {
                        Text("all")
                            .font(.caption)
                            .foregroundColor(viewModel.mediaType == .all ? .secondaryBrand : .white)
                            .bold()
                            .padding()
                            .frame(minWidth: 80)
                            .overlay {
                                if viewModel.mediaType == .all {
                                    Capsule(style: .continuous)
                                        .stroke(Color.secondaryBrand, lineWidth: 1)
                                }
                            }
                    })
                    
                    Button(action: {
                        viewModel.mediaType = .movies
                    }, label: {
                        Text("movies")
                            .font(.caption)
                            .foregroundColor(viewModel.mediaType == .movies ? .secondaryBrand : .white)
                            .bold()
                            .padding()
                            .frame(minWidth: 80)
                            .overlay {
                                if viewModel.mediaType == .movies {
                                    Capsule(style: .continuous)
                                        .stroke(Color.secondaryBrand, lineWidth: 1)
                                }
                            }
                    })
                    
                    
                    
                    Button(action: {
                        viewModel.mediaType = .series
                    }, label: {
                        Text("series")
                            .font(.caption)
                            .foregroundColor(viewModel.mediaType == .series ? .secondaryBrand : .white)
                            .bold()
                            .padding()
                            .overlay {
                                if viewModel.mediaType == .series {
                                    Capsule(style: .continuous)
                                        .stroke(Color.secondaryBrand, lineWidth: 1)
                                }
                            }
                    })
                    
                    Spacer()
                    
                    Button(action: {self.showingfilter.toggle()}, label: {
                        HStack(spacing: 0) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                            
                            if viewModel.filterBadgeCount > 0 {
                                Text("\(viewModel.filterBadgeCount)")
                                    .font(.caption)
                                    .padding(5)
                                    .background(.white)
                                    .clipShape(Circle())
                                    .foregroundColor(Color.secondaryBrand)
                            }
                                
                        }.padding(10)
                            .background(Color.primaryBrand)
                            .clipShape(Capsule())
                            .disabled(viewModel.status == .loaded)
                    })
                }.padding()
                    .animation(.easeIn, value: viewModel.mediaType)
                    .sheet(isPresented: $showingfilter, onDismiss: {viewModel.updateShows()}) {
                        FilterSearchView(viewModel: viewModel)
                    }
                
                if viewModel.noData {
                    VStack {
                        Text("whoops!")
                            .foregroundColor(.primaryText)
                            .font(.title)
                        
                        Text("sorry we couldn't find any matches")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }.frame(height: UIScreen.main.bounds.height / 2)
                }
                else {
                    resultShowsView
                        .padding(.horizontal)
                        
                }
                
            }.searchable(text: $viewModel.searchKeyword)
                .onSubmit(of: .search, {
                    Task {
                        viewModel.loadShows()
                    }
                })
            .background(Color.primaryBrand)
                .buttonStyle(.plain)
                .navigationTitle("search")
        }
        
        
    }
    
    private var movieShows: [ShoofAPI.Show] {
        return viewModel.shows.filter({$0.isMovie})
    }
    
    private var tvShows: [ShoofAPI.Show] {
        return viewModel.shows.filter({!$0.isMovie})
    }
    
    @ViewBuilder private var resultShowsView: some View {
        switch viewModel.mediaType {
        case .all:
            allShowsView
            
        case .movies:
            movieShowsView
            
        case .series:
            tvShowsView
            
        }
    }
    
    @ViewBuilder private var allShowsView: some View {
        LazyVStack(alignment: .leading) {
            ForEach(viewModel.shows.indices , id: \.self) { index in
                NavigationLink(destination: {
                    ShowDetailsView(viewModel: ShowDetailsViewModel(show: viewModel.shows[index]))
                }, label: {
                    HorizontalPosterView(show: viewModel.shows[index])
                        .onAppear {
                            if viewModel.shows.last?.id == viewModel.shows[index].id {
                                viewModel.loadShowsMore()
                            }
                        }
                }).padding(.bottom)
            }
        }
    }
    
    @ViewBuilder private var tvShowsView: some View {
        LazyVStack(alignment: .leading) {
            ForEach(tvShows.indices , id: \.self) { index in
                NavigationLink(destination: {
                    ShowDetailsView(viewModel: ShowDetailsViewModel(show: viewModel.shows[index]))
                }, label: {
                    HorizontalPosterView(show: tvShows[index])
                        .onAppear {
                            if tvShows.last?.id == movieShows[index].id {
                                viewModel.loadShowsMore()
                            }
                        }
                    
                }).padding(.bottom)
            }
        }
    }
    
    @ViewBuilder private var movieShowsView: some View {
        LazyVStack(alignment: .leading) {
            ForEach(movieShows.indices , id: \.self) { index in
                NavigationLink(destination: {
                    ShowDetailsView(viewModel: ShowDetailsViewModel(show: viewModel.shows[index]))
                }, label: {
                    HorizontalPosterView(show: viewModel.shows[index])
                        .onAppear {
                            if movieShows.last?.id == movieShows[index].id {
                                viewModel.loadShowsMore()
                            }
                        }
                }).padding(.bottom)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
