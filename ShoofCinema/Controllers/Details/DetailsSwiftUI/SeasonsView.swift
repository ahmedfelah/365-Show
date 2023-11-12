//
//  SeasonsView.swift
//  ShoofCinema
//
//  Created by mac on 4/27/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SeasonsView: View {
    
    @ObservedObject private var viewModel: SeasonsViewModel
    
    
    init(show: ShoofAPI.Show, tabbar: RoundedTabBar) {
        self.viewModel = SeasonsViewModel(show: show, tabbar: tabbar)
        self.viewModel.fetchEpisodes()
    }
    
    var body: some View {
        LazyVStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false, content: {
                    LazyHStack {
                        ForEach(0 ..< viewModel.seasons.count, id: \.self) { index in
                            Text("\(Text(LocalizedStringKey(stringLiteral: "seasonName"))) \(index + 1)")
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .border(borderColor(index: index))
                                .foregroundColor(forGroundColor(index: index))
                                .id(index)
                                .onTapGesture {
                                    viewModel.seasonIndexSelected = index
                                    viewModel.fetchEpisodes()
                                }
                        }
                    }.padding()
                        .onAppear(perform: {
                            proxy.scrollTo(viewModel.seasonIndexSelected, anchor: .trailing)
                        })
                })
            }
            if viewModel.isLoading {
                mockEpisodesView
            }
            
            else {
                ForEach(0 ..< viewModel.episodes.count, id: \.self) { index in
                    episodeView(episode: viewModel.episodes[index])
                        .onTapGesture {
                            viewModel.playEpisode(index: index)
                        }
                    
                }
                if viewModel.hasNextPage && !viewModel.isLoading {
                    mockEpisodeView
                        .onAppear {
                            viewModel.fetchNextPage()
                        }
                }
            }
        }.background(Color.black)
            .foregroundColor(.red)
            .frame(maxWidth: UIScreen.main.bounds.width)
            .padding(10)
            
    }
    
    private func borderColor(index: Int) -> Color {
        viewModel.seasonIndexSelected == index ? Color(uiColor: Theme.current.tintColor) : .clear
    }
    
    private func forGroundColor(index: Int) -> Color {
        viewModel.seasonIndexSelected == index ? Color(uiColor: Theme.current.tintColor) : .white
    }
    
    @ViewBuilder private func episodeView(episode: ShoofAPI.Media.Episode) -> some View {
        
        let episodeDownload = viewModel.downloading[episode.id]
            EpisodeView(
                episode: episode,
                viewModel: EpisodeViewModel(
                    episodeId: episode.id,
                    progress: episodeDownload?.Progress ?? 0,
                    downloadStatus: episodeDownload?.Status ?? .unknown
                ),
                showId: viewModel.show.id,
                downloadAction: {viewModel.Download(episode: episode)}
            )
    }
    
    @ViewBuilder private var mockEpisodesView: some View  {
        ForEach(0 ..< 20) {_ in
            mockEpisodeView
        }
    }
    
    @ViewBuilder private var mockEpisodeView: some View  {
        EpisodeView(
            episode: viewModel.mockEpisode,
            viewModel: EpisodeViewModel(
                episodeId: viewModel.mockEpisode.id,
                progress: 0,
                downloadStatus: .unknown
            ),
            showId: viewModel.show.id,
            downloadAction: {viewModel.Download(episode: viewModel.mockEpisode)}
        ).redacted(reason: .placeholder)
            .shimmering()
    }
    
    
}

