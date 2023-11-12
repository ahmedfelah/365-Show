//
//  SeasonsView.swift
//  ShoofCinema
//
//  Created by mac on 8/2/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SeasonsTVShowView: View {
    
    @StateObject var viewModel: SeasonsTVShowViewModel
    
    @State private var showingResolutions = false
    @State private var downloadEpisodeIndex = 0
    @State var isPresented = false
    @State private var shownAllEpisodes = false
    
    
    var body: some View {
        VStack {
            seasonsView
            
            if !viewModel.episodes.isEmpty {
                episodesView
                    .animation(.easeOut, value: viewModel.episodes)
            }
        }
    }
    
    @ViewBuilder private var seasonsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.seasons.indices, id: \.self) { index in
                    Button(action: {
                        fetchEpisodesBySeason(index: index)
                    }, label: {
                        Text("Season \(viewModel.seasons[index].number)")
                            .font(.caption)
                            .foregroundColor(viewModel.seasonIndexSelected == index ? .secondaryBrand : .white)
                            .bold()
                            .padding()
                            .overlay {
                                if viewModel.seasonIndexSelected == index  {
                                    Capsule(style: .continuous)
                                        .stroke(Color.secondaryBrand, lineWidth: 1)
                                }
                            }
                    })
                }
            }.padding()
                .foregroundColor(.gray)
                .frame(height: 70)
                .task {
                    viewModel.fetchEpisodes()
                }
        }
    }
    
    private func fetchEpisodesBySeason(index: Int) {
        viewModel.seasonIndexSelected = index
        viewModel.fetchEpisodes()
    }
    
    @ViewBuilder private var episodesView: some View {
        LazyVStack {
            ForEach(viewModel.episodes.indices, id: \.self) { index in
                EpisodeTVShowView(
                    episode: viewModel.episodes[index],
                    imageUrl: viewModel.show.coverURL,
                    rating: viewModel.show.rating ?? "_",
                    progress: 0.0,
                    status: .unknown,
                    isSelected: viewModel.episodeIndexSelected == index,
                    viewModel: viewModel,
                    downloadAction: {}
                ).onTapGesture {
                    viewModel.playEpisode(index: index)
                    isPresented.toggle()
                    
                }
            }.redacted(reason: viewModel.isLoading ? .placeholder : [])
            
            NavigationLink(destination: AllEpisodesTVShowView(viewModel: viewModel), label: {
                Text("SEE ALL")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .bold()
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .foregroundColor(.primaryBrand)
                    .padding(.bottom)
            })
            
        }.confirmationDialog("Select a resolution", isPresented: $showingResolutions) {
            ForEach(viewModel.sources(episode: viewModel.episodes[downloadEpisodeIndex]), id: \.self) { source in
                Button("\(source.title)") {
                    viewModel.download(episode: viewModel.episodes[downloadEpisodeIndex], source: source)
                }
            }
        }.fullScreenCover(isPresented: $isPresented, onDismiss: {}) {
            VideoPlayerView(videoPlayerViewController: viewModel.videoPlayerViewController, show: viewModel.show)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    
    private func showResolutionsDialog(index: Int) {
        downloadEpisodeIndex = index
        showingResolutions.toggle()
    }
}

