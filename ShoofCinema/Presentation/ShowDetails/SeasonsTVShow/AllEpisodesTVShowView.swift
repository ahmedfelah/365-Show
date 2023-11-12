//
//  AllEpisodesTVShowView.swift
//  ShoofCinema
//
//  Created by mac on 8/2/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct AllEpisodesTVShowView: View {
    
    @StateObject var viewModel: SeasonsTVShowViewModel
    @State private var showingResolutions = false
    @State private var downloadEpisodeIndex: Int = 0
    @State var isPresented = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.episodes.indices, id: \.self) { index in
                        EpisodeTVShowView(
                            episode: viewModel.episodes[index],
                            imageUrl: viewModel.show.coverURL,
                            rating: viewModel.show.rating ?? "_",
                            progress: viewModel.downloading[viewModel.episodes[index].id]?.Progress ?? 0.0,
                            status: viewModel.downloading[viewModel.episodes[index].id]?.Status ?? .unknown,
                            isSelected: viewModel.episodeIndexSelected == index,
                            viewModel: viewModel,
                            downloadAction: {showResolutionsDialog(index: index)}
                        ).onTapGesture {
                            viewModel.playEpisode(index: index)
                            isPresented.toggle()
                        }
                    }

                }.confirmationDialog("Select a resolution", isPresented: $showingResolutions) {
                    ForEach(viewModel.sources(episode: viewModel.episodes[downloadEpisodeIndex]), id: \.self) { source in
                        Button("\(source.title)") {
                            viewModel.download(episode: viewModel.episodes[downloadEpisodeIndex], source: source)
                        }
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(viewModel.episodeIndexSelected, anchor: .center)
                        }
                    }
                    
                })

            }.fullScreenCover(isPresented: $isPresented, onDismiss: {}) {
                VideoPlayerView(videoPlayerViewController: viewModel.videoPlayerViewController, show: viewModel.show)
                    .edgesIgnoringSafeArea(.all)
            }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Categories")
                .background(Color.primaryBrand)
                .onReceive(viewModel.$downloading) { newValue in
                    print(newValue)
                    
                }
        }
    }
    
    private func showResolutionsDialog(index: Int) {
        downloadEpisodeIndex = index
        showingResolutions.toggle()
    }
}

