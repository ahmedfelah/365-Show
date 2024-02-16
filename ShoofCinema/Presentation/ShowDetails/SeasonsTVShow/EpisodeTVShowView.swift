//
//  EpisodeView.swift
//  ShoofCinema
//
//  Created by mac on 8/2/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct EpisodeTVShowView: View {
    
    
    let episode: ShoofAPI.Media.Episode
    let imageUrl: URL?
    let rating: String
    
    @State var progress: Float
    @State var status: DownloadStatus
    
    var isSelected = false
    
    @StateObject var viewModel: SeasonsTVShowViewModel
    
    let downloadAction: () -> Void
    let playAction: () -> Void
    
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack {
                KFImage.url(imageUrl)
                    .placeholder {
                        Color.black
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                
                ZStack {
                    Circle()
                        .fill(Color.secondaryBrand)
                        .frame(width: 30)
                    
                    Image(systemName: "play.fill")
                    
                }.onTapGesture {
                    playAction()
                }
            }.frame(maxWidth: .infinity)
                .overlay {
                    if isSelected {
                        Rectangle()
                            .stroke(.white, lineWidth: 1)
                    }
                }
            
            Spacer()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(Text("episode")) \(episode.number)")
                        .padding(.top, 3)
                        .padding(.horizontal, 5)
                        .padding(.bottom)
                    
                    HStack {
                        Text("IMDB")
                            .font(.system(size: 8))
                            .padding(3)
                            .background(Color("imdb"))
                            .cornerRadius(5)
                            .foregroundColor(.black)
                            .padding(.trailing, 5)
                        
                        
                        Text("\(rating)")
                            
                            .font(.caption2)
                    }.padding(.horizontal, 5)
                }
                
                Spacer()
                
                VStack {
                    if status == .downloading {
                        CircleProgress(progress: $progress)
                            .frame(width: 25, height: 25)
                            .environment(\.layoutDirection, .rightToLeft)
                    }
                    
                    else if status == .downloaded {
                        Image(systemName: "checkmark")
                            .imageScale(.large)
                            .foregroundColor(Color.secondaryBrand)
                    }
                    
                    else {
                        Button(action: downloadAction) {
                            Image(systemName: "arrow.down.to.line")
                                .imageScale(.large)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }.padding([.horizontal])
            .padding(.vertical, 5)
            .onReceive(viewModel.$downloading) { item in
                if let item = item[episode.id] {
                    self.progress = item.Progress
                    self.status = item.Status
                }
            }
    }
    
    
}

