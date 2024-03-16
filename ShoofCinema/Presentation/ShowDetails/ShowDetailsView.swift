//
//  ShowDetailsView.swift
//  ShoofCinema
//
//  Created by mac on 7/9/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher
import Foundation

struct ShowDetailsView: View {
    
    @StateObject var viewModel: ShowDetailsViewModel
    
    @State private var isPresentedPlayer = false
    @State private var isPresentedImage = false
    @State private var isPresenResolutions = false
    
    @Environment(\.openURL) var openURL
   
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .bottom) {
                    imageView
    
                    detailsView
                    
                }.onTapGesture {
                    self.isPresentedImage.toggle()
                }
                
                alternativeTitleView
                
                descriptionView
                
                castAndCrew
                
                if viewModel.status == .loaded && !isOutsideDomain && !viewModel.show.isMovie {
                    HStack {
                        Text("episodes")
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {viewModel.toggleSubscribe()}, label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                
                                Text("subscripe")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }).foregroundColor(viewModel.show.isSubscribed ? .red : .white)
                            .animation(Animation.linear(duration: 1.5), value: viewModel.show.isSubscribed)
                        
                        
                    }.padding()
                    
                    if !viewModel.show.isMovie && !isOutsideDomain {
                        SeasonsTVShowView(viewModel: SeasonsTVShowViewModel(show: viewModel.show))
                    }
                }
                
            }.task {
                viewModel.loadDetails()
            }.edgesIgnoringSafeArea(.top)
                .background(Color("denim"))
                .buttonStyle(.plain)
                .toolbarBackground(.hidden, for: .navigationBar)
                .overlay {
                    if viewModel.status == .loading {
                        VStack {
                            LoadingView()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }
                }.confirmationDialog("select a resolution", isPresented: $isPresenResolutions) {
                    ForEach(viewModel.sources, id: \.self) { source in
                        Button("\(source.title)") {
                            viewModel.download(source: source)
                        }
                    }
                    
                }.fullScreenCover(isPresented: $viewModel.showingLogin) {
                    SignInView(dismiss: $viewModel.showingLogin)
                    
                }.sheet(isPresented: $isPresentedImage, content: {
                    if #available(iOS 16.4, *) {
                        ImageView(url: viewModel.show.coverURL)
                            .presentationBackground(.clear)
                    }
                    else  {
                        ImageView(url: viewModel.show.coverURL)
                    }
                })
        }
        
        else {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .bottom) {
                    imageView
                    
                    detailsView
                    
                }
                
                alternativeTitleView
                
                descriptionView
                
                castAndCrew
                
                if viewModel.status == .loaded && !isOutsideDomain && !viewModel.show.isMovie {
                    HStack {
                        Text("episodes")
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {viewModel.toggleSubscribe()}, label: {
                            HStack {
                                Image(systemName: "bell.fill")
                                
                                Text("subscripe")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }).foregroundColor(viewModel.show.isSubscribed ? .red : .white)
                            .animation(Animation.linear(duration: 1.5), value: viewModel.show.isSubscribed)
                        
                        
                    }.padding()
                    
                    if !viewModel.show.isMovie && !isOutsideDomain {
                        SeasonsTVShowView(viewModel: SeasonsTVShowViewModel(show: viewModel.show))
                    }
                }
                
            }.task {
                viewModel.loadDetails()
            }.edgesIgnoringSafeArea(.top)
                .background(Color("denim"))
                .buttonStyle(.plain)
                .overlay {
                    if viewModel.status == .loading {
                        VStack {
                            LoadingView()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }
                }.confirmationDialog("select a resolution", isPresented: $isPresentedPlayer) {
                    ForEach(viewModel.sources, id: \.self) { source in
                        Button("\(source.title)") {
                            viewModel.download(source: source)
                        }
                    }
                }.fullScreenCover(isPresented: $viewModel.showingLogin) {
                    SignInView(dismiss: $viewModel.showingLogin)
                }
        }
    }
    
    @ViewBuilder private var imageView: some View {
        KFImage.url(viewModel.show.coverURL)
            .placeholder {
                Color.black
            }
            .resizable()
            .fade(duration: 0.25)
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: 500,alignment: .top)
            .clipped()
    }
    
    @ViewBuilder private var imdbRating: some View {
        if let rating = viewModel.show.rating, rating.isNumber {
            HStack {
                Text("IMDB")
                    .font(.system(size: 8))
                    .padding(3)
                    .background(Color("imdb"))
                    .cornerRadius(5)
                    .foregroundColor(.black)
                    .padding(3)
                
                Text("\(rating)")
                    .padding(3)
                    .font(.callout)
            }
        }
        
    }
    
    @ViewBuilder private var genresView: some View {
        Text("\(viewModel.show.year) \(viewModel.show.genres?.map({$0.name}).joined(separator: " ") ?? "" as String)")
            .font(.callout)
            .foregroundColor(.gray)
            .padding(.bottom)
    }
    
    @ViewBuilder private var watchButtonView: some View {
        Button(action: {
           watch()
        }) {
            HStack {
                Image(systemName: "play.fill")
                
                Text(isOutsideDomain ? "watch trailer" : "watch now")
                    .bold()
            }.padding()
                .background(Color.secondaryBrand)
                .foregroundColor(.primaryBrand)
                .clipShape(Capsule())
                
        }.padding([.bottom])
            .fullScreenCover(isPresented: $isPresentedPlayer) {
                VideoPlayerView(videoPlayerViewController: viewModel.videoPlayerViewController, show: viewModel.show)
                    .edgesIgnoringSafeArea(.all)
                    
            }.font(.caption)
    }
    
    @ViewBuilder private var watchLaterButtonView: some View {
        Button(action: {viewModel.toggleWatchLater()}) {
            VStack {
                Image(systemName: viewModel.show.isInWatchLater ? "checkmark" : "plus")
                    .imageScale(.large)
                    .foregroundColor(viewModel.show.isInWatchLater ? .secondaryBrand : .white)
                    
                
                Text("watch later")
                    .foregroundColor(.white)
                    
            }.foregroundColor(viewModel.show.isInWatchLater ? .red : .white)
                .animation(Animation.linear(duration: 1), value: viewModel.show.isInWatchLater)
        }.padding()
            .font(.caption)
    }
    
    @ViewBuilder private var favouriteButtonView: some View {
        Button(action: {viewModel.toggleFavourite()}) {
            VStack {
                Image(systemName: viewModel.isFavourite ? "heart.fill" : "heart")
                    .imageScale(.large)
                    .foregroundColor(viewModel.isFavourite ? .secondaryBrand : .white)
                    
                
                Text("favourite")
                    .foregroundColor(.white)
                    
            }
                .animation(Animation.linear(duration: 1), value: viewModel.isFavourite)
        }.padding()
            .font(.caption)
    }
    
    @ViewBuilder private var actionView: some View {
        HStack(alignment: .center, spacing: 10) {
            
            
            if !isOutsideDomain {
                downloadButtonView
            }
            
            else {
                favouriteButtonView
                    .onAppear {
                        viewModel.checkIsFavourite()
                    }
            }
            
            watchButtonView
            
            watchLaterButtonView
                .alert("please login ", isPresented: $viewModel.showingLoginAlert) {
                    Button("okAlertButton", role: .none) {
                        viewModel.showingLogin.toggle()
                    }
                    
                    Button("cancel", role: .cancel) {}
                }
            
        }.padding(.horizontal)
    }
    
    
    @ViewBuilder private var downloadButtonView: some View {
        switch viewModel.downloadStatus {
        case .downloaded:
            VStack {
                Image(systemName: "checkmark")
                    .imageScale(.small)
                    .foregroundColor(Color(uiColor: Theme.current.tintColor))
                
                Text("downloaded")
            }
            
        case .loading, .downloading_sub:
            VStack {
                ActivityIndicatorView(style: .white)
                
                Text("loading")
            }.padding()
                .foregroundColor(.white)
                .font(.caption)
            
        case .downloading, .in_queue, .paused:
            VStack {
                downloadProgressView
                
                Text("downloading")
            }.padding()
                .foregroundColor(.white)
                .font(.caption)
            
        case .failed:
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.small)
                
                Text("faild")
            }.padding()
                .font(.caption)
                .foregroundColor(.white)
            
        case .unknown:
            Button(action: {
                self.isPresenResolutions.toggle()
            }, label: {
                VStack {
                    Image(systemName: "arrow.down.to.line")
                    
                    Text("download")
                }
                .foregroundColor(.white)
            }).padding()
                .font(.caption)
        }
    }
    
    @ViewBuilder private var downloadProgressView: some View {
        ZStack {
            CircleProgress(progress: viewModel.downloadingProgress)
                .frame(width: 25, height: 25)
                .environment(\.layoutDirection, .rightToLeft)
            
            switch viewModel.downloadStatus {
            case .downloading:
                Image(systemName: "pause")
                    .imageScale(.small)
                
                
            case .paused:
                Image(systemName: "play.fill")
                    .imageScale(.small)
                
            default :
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private var detailsView: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(LinearGradient(colors: [.clear, Color("denim")], startPoint: .top, endPoint: .bottom))
                .frame(height: 500)
            
            VStack {
                titleView
                
                imdbRating
                
                genresView
                
                actionView
            }
        }
    }
    
    @ViewBuilder private var titleView: some View {
        Text(viewModel.show.title)
            .font(.title3)
            .fontWeight(.bold)
    }
    
    @ViewBuilder private var alternativeTitleView: some View {
        Text(viewModel.show.alternativeTitle ?? "")
            .fontWeight(.bold)
            .padding(.horizontal)
            .frame(
                maxWidth: .infinity,
                alignment: detectLanguage(
                    for: viewModel.show.alternativeTitle ?? ""
                ) == "en" ? .leading : .trailing
            ).environment(\.layoutDirection, .leftToRight)
            
    }
    
    @ViewBuilder private var sensitiveContentView: some View {
        HStack {
            Image(systemName: "r.square")
                .imageScale(.large)
            
            Image(systemName: "scissors")
                .imageScale(.large)
        }.padding()
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder private var descriptionView: some View {
        Text("\(viewModel.show.description ?? "")")
            .padding(.horizontal)
            .foregroundColor(.gray)
            .multilineTextAlignment(
                detectLanguage(
                    for: viewModel.show.description ?? ""
                ) == "en" ? .leading : .trailing)
            .environment(\.layoutDirection, .leftToRight)
    }
    
    @ViewBuilder private var reactionView: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "hand.thumbsup.fill")
                .imageScale(.large)
            Text("1003")
                
            
            Image(systemName: "hand.thumbsdown.fill")
                .imageScale(.large)
            
            Text("350")
                
            
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .padding(.leading)
        }.padding()
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder private var castAndCrew: some View {
        if let actors = viewModel.show.actors, !actors.isEmpty {
            Text("cast & crew")
                .bold()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ActorsView(actors: actors)
                .padding(.bottom)
        }
    }
    
    private func watch() {
        if !isOutsideDomain || viewModel.downloadedItem {
            isPresentedPlayer.toggle()
            viewModel.watch()
        }
        else {
            if let youtubeID = viewModel.show.youtubeID, let url  = URL(string: "https://youtube.com/watch?v=\(youtubeID)") {
                openURL(url)
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoPlayerViewController: VideoPlayerViewController
    
    let show: ShoofAPI.Show
    
    func makeUIViewController(context: Context) -> VideoPlayerViewController {
        
        return videoPlayerViewController
    }
    
    func updateUIViewController(_ uiViewController: VideoPlayerViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}


extension String {
    var isNumber: Bool {
        return self.range(
            of: "^[0-9]+(?:[.,][0-9]+)*$", // 1
            options: .regularExpression) != nil
    }
}

