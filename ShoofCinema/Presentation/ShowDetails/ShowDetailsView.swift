//
//  ShowDetailsView.swift
//  ShoofCinema
//
//  Created by mac on 7/9/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ShowDetailsView: View {
    
    @StateObject var viewModel: ShowDetailsViewModel
    
    @State var isPresented = false
    @State private var showingResolutions = false
    
    @Environment(\.openURL) var openURL
   
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .bottom) {
                imageView
                
                detailsView
                
            }
            
            descriptionView
            
            castAndCrew
            
            if viewModel.status == .loaded && !isOutsideDomain {
                HStack {
                    Text("Episodes")
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {viewModel.toggleSubscribe()}, label: {
                        HStack {
                            Image(systemName: "bell.fill")
                            
                            Text("Subscripe")
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
            }.confirmationDialog("Select a resolution", isPresented: $showingResolutions) {
                ForEach(viewModel.sources, id: \.self) { source in
                    Button("\(source.title)") {
                        viewModel.download(source: source)
                    }
                }
            }.fullScreenCover(isPresented: $viewModel.showingLogin) {
                SignInView(dismiss: $viewModel.showingLogin)
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
        HStack {
            Text("IMDB")
                .font(.system(size: 8))
                .padding(3)
                .background(Color("imdb"))
                .cornerRadius(5)
                .foregroundColor(.black)
                .padding(3)
            
            
            Text("\(viewModel.show.rating ?? "_")")
                .padding(3)
                .font(.caption2)
        }
    }
    
    @ViewBuilder private var genresView: some View {
        Text("2022 - Drama, Action - 1h 33 min")
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.bottom)
    }
    
    @ViewBuilder private var watchButtonView: some View {
        Button(action: {
            if !isOutsideDomain {
                isPresented.toggle()
                viewModel.videoPlayerViewController.play(show: viewModel.show)
            }
            else {
                if let url = viewModel.show.trailerURL {
                    openURL(url)
                }
            }
        }) {
            HStack {
                Image(systemName: "play.fill")
                
                Text("Watch Now")
                    .bold()
            }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.secondaryBrand)
                .cornerRadius(40)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.primaryBrand)
                
        }.padding([.bottom])
            .fullScreenCover(isPresented: $isPresented) {
                VideoPlayerView(videoPlayerViewController: viewModel.videoPlayerViewController, show: viewModel.show)
                    .edgesIgnoringSafeArea(.all)
                    
            }
    }
    
    @ViewBuilder private var watchLaterButtonView: some View {
        Button(action: {viewModel.toggleWatchLater()}) {
            Image(systemName: viewModel.show.isInWatchLater ? "checkmark" : "plus")
                .imageScale(.large)
                .padding(10)
                .foregroundColor(viewModel.show.isInWatchLater ? .secondaryBrand : .white)
                .animation(Animation.linear(duration: 1.5), value: viewModel.show.isInWatchLater)
        }.background(Color.tertiaryBrand)
            .clipShape(Circle())
    }
    
    @ViewBuilder private var actionView: some View {
        HStack(alignment: .center) {
            watchButtonView
            
            downloadButtonView
            
            watchLaterButtonView
                .alert("Please login ", isPresented: $viewModel.showingLoginAlert) {
                    Button("Ok", role: .none) {
                        viewModel.showingLogin.toggle()
                    }
                    
                    Button("Cancel", role: .cancel) {}
                }
            
        }.padding(.horizontal)
            .padding(.trailing)
            .fontWeight(.semibold)
    }
    
    @ViewBuilder private var downloadButtonView: some View {
        if viewModel.downloadStatus == .downloading {
            CircleProgress(progress: .constant(0))
                .frame(width: 25, height: 25)
                .environment(\.layoutDirection, .rightToLeft)
        }
        
        else if viewModel.downloadStatus == .downloaded {
            Image(systemName: "checkmark")
                .imageScale(.large)
                .foregroundColor(Color.secondaryBrand)
        }
        
        else {
            Button(action: {self.showingResolutions.toggle()}, label: {
                Image(systemName: "arrowshape.turn.up.forward")
                    .imageScale(.large)
                    .padding(10)
                    .foregroundColor(.white)
            }).background(Color.tertiaryBrand)
            .clipShape(Circle())
        }
    }
    
    @ViewBuilder private var detailsView: some View {
        ZStack(alignment: .bottom) {
            Rectangle().fill(LinearGradient(colors: [.clear, Color("denim")], startPoint: .top, endPoint: .bottom))
                .frame(height: 500)
            
            VStack {
                imdbRating
                
                genresView
                
                actionView
                
            }
        }
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
            .fontWeight(.semibold)
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder private var castAndCrew: some View {
        Text("Cats & Crew")
            .bold()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        
        if let actors = viewModel.show.actors {
            ActorsView(actors: actors)
                .padding(.bottom)
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

