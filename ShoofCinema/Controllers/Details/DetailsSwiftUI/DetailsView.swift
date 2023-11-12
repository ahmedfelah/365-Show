//
//  DetailsView.swift
//  ShoofCinema
//
//  Created by mac on 4/27/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI


struct DetailsView: View {
    
    @ObservedObject private var viewModel: DetailsViewModel
    
    let tabbar:  RoundedTabBar
    
    init(show: ShoofAPI.Show?, tab: RoundedTabBar, parentVC: UIViewController?) {
        self.viewModel = DetailsViewModel(show: show, tabbar: tab, parentVC: parentVC)
        self.tabbar = tab
        self.viewModel.loadDetails()
        
    }
    
    var isAppInReview: Bool {
        if isOutsideDomain && !appPublished {
            return true
        }
        return false
    }
    
    
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                KingFisherImageView(url: viewModel.show?.posterURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 700)
                    .clipped()
                
                VStack {
                    Rectangle().fill(LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom))
                        .frame(height: 100)
                    
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        Rectangle().fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                            .frame(maxHeight: .infinity)
                        
                        VStack(spacing: 16) {
                            if isAppInReview {
                                MatchRateView(matchRate: viewModel.getMatchRate())
                            }
                            Text("\(viewModel.show?.title ?? "")")
                                .textCase(.uppercase)
                                .font(.largeTitle)
                            
                            HStack {
                                StarsView(number: Float(viewModel.show?.rating ?? "0") ?? 0)
                            }
                            
                            HStack {
                                Text("\(viewModel.show?.year ?? "----")")
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 5)
                                    .frame(width: 70)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(5)
                                
                                Text("\(viewModel.show?.rating ?? "--")/\(Text("10").foregroundColor(.gray))")
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 5)
                                    .frame(width: 70)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(5)
                                
                                Text("\("+" + (viewModel.show?.ageRating ?? "--"))")
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 5)
                                    .frame(width: 70)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(5)
                                    .foregroundColor(.red)
                            }
                            .font(.headline)
                            
                            WatchButtonView()
                            
                            if viewModel.state == .loaded {
                                HStack(alignment: .bottom) {
                                    Button(action: {viewModel.toggleFav()}) {
                                        VStack(spacing: 10) {
                                            if !viewModel.isFavLoading {
                                                Image(systemName: viewModel.show?.isInWatchLater ?? false ? "heart.fill" : "heart")
                                            }
                                            
                                            else {
                                                ActivityIndicatorView(style: .white)
                                                
                                            }
                                            
                                            Text("favorite")
                                                .textCase(.uppercase)
                                            
                                        }.foregroundColor(viewModel.show?.isInWatchLater ?? false ? Color(uiColor: Theme.current.tintColor) : .white)
                                            .frame(height: 60, alignment: .bottom)
                                    }.frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                    
                                    Button(action: {viewModel.shareTapped()}) {
                                        VStack(spacing: 10) {
                                            Image(systemName: "square.and.arrow.up")
                                            
                                            Text(LocalizedStringKey("share"))
                                                .textCase(.uppercase)
                                        }.frame(height: 60, alignment: .bottom)
                                        
                                    }.frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                    
                                    downloadButtonView
                                    
                                    subscribeButtonView
                                    
                                }.padding(30)
                                    .font(.caption)
                                    .buttonStyle(.plain)
                                    .frame(height: 60)
                                
                            }
                        }
                    }
                }
                
                
            }.frame(maxWidth: UIScreen.main.bounds.width)
            
            Text("\(viewModel.show?.description ?? "")")
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.vertical)
            
            ActorsView()
                .padding(.top)
            
            TabView()
            
        }.background(Color.black)
            .foregroundColor(.white)
            .navigationBarHidden(false)
            .font(Font(Fonts.almarai()))
            .padding(.top, -20)
        
    }
    
    @ViewBuilder private var downloadButtonView: some View {
        if viewModel.show?.isMovie ?? false && !isAppInReview {
            Button(action: {viewModel.startDownload()}) {
                withAnimation {
                    VStack(spacing: 10) {
                        downloadStatusView
                        
                        Text(LocalizedStringKey("download"))
                    }.frame(height: 60, alignment: .bottom)
                }
            }.frame(maxWidth: .infinity)
                .disabled(viewModel.downloadStatus != .unknown)
        }
    }
    
    @ViewBuilder private var subscribeButtonView: some View {
        if !(viewModel.show?.isMovie ?? false) && !isAppInReview {
            Button(action: {viewModel.handleSubscribe()}) {
                withAnimation {
                    VStack(spacing: 10) {
                        if !viewModel.isSubLoading {
                            Image(systemName: viewModel.show?.isSubscribed ?? false ? "bell" : "bell.fill")
                                .foregroundColor(Color(uiColor: Theme.current.tintColor))
                        }
                        else {
                            ActivityIndicatorView(style: .white)
                        }
                        
                        Text(LocalizedStringKey(stringLiteral: "subscribe"))
                            .foregroundColor(Color(uiColor: Theme.current.tintColor))
                        
                    }.frame(height: 60, alignment: .bottom)
                }
            }.frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var downloadStatusView: some View {
        switch viewModel.downloadStatus {
        case .downloaded:
            Image(systemName: "checkmark")
                .imageScale(.small)
                .foregroundColor(Color(uiColor: Theme.current.tintColor))
            
        case .loading, .downloading_sub:
            ActivityIndicatorView(style: .white)
            
        case .downloading, .in_queue, .paused:
            CircleProgress(progress: $viewModel.downloadingProgress)
                .frame(width: 20, height: 20)
            
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .imageScale(.small)
            
        case .unknown:
            Image(systemName: "arrow.down.to.line")
                .imageScale(.small)
                .foregroundColor(Color(uiColor: Theme.current.tintColor))
        }
    }
    
    @ViewBuilder private func StarsView(number: Float) -> some View {
        HStack {
            HStack {
                ForEach(0 ... 4, id: \.self) { index in
                    if index <  Int(number / 2) {
                        Image(systemName: "star.fill")
                            .renderingMode(.original)
                    }
                    else {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder private func TabView() -> some View {
        if viewModel.state == .loaded {
            if let show = viewModel.show  {
                DetailsTabView(show: show, tabbar: tabbar, moreAction: viewModel.moreComment, wirteAction: viewModel.writeComment)
            }
        }
    }
    
    @ViewBuilder private func ActorsView() -> some View {
        if let actors = viewModel.show?.actors, !actors.isEmpty {
            CrewView(actors: actors)
        }
    }
    
    @ViewBuilder private func WatchButtonView() -> some View {
        if !isAppInReview  {
            Button(action: {viewModel.watch()}) {
                if viewModel.state == .loading  || viewModel.isWatchLoading{
                    ActivityIndicatorView(style: .white)
                }
                
                else {
                    HStack {
                        Spacer()
                        Text("watch")
                            .textCase(.uppercase)
                            .padding(EdgeInsets(top: 10,
                                                leading: 10,
                                                bottom: 10,
                                                trailing: 10))
                        Spacer()
                    }
                }
            }
            .disabled(viewModel.state == .loading)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(.red)
            .cornerRadius(10)
            .padding(.horizontal, 40)
        }
        
        
    }
    
}




//struct DetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailsView()
//    }
//}
