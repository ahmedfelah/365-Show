//
//  DownloadCard.swift
//  ShoofCinema
//
//  Created by mac on 9/10/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher
import RealmSwift

struct DownloadCardView: View {
    
    @ObservedRealmObject var rDownload: RDownload
    
    @StateObject var viewModel: DownloadsViewModel
    
    @State private var showingOptions = false

    
    var body: some View {
        HStack {
            KFImage.url(URL(string: rDownload.show?.posterURL ?? ""))
                .placeholder {
                    Color.black
                }
                .resizable()
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(rDownload.show?.title ?? "")")
                    .lineLimit(1)
                    .padding(.vertical)
                    .font(.title3)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(spacing: 10) {
                        Text("\(rDownload.series_season_title ?? "") \(rDownload.series_title ?? "")")
                            .lineLimit(1)
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("49MB")
                            .lineLimit(1)
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    downloadingStatusView
                    
                }
                
                HStack {
                    Text("IMDB")
                        .font(.system(size: 8))
                        .padding(3)
                        .background(Color("imdb"))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                        .padding(3)
                    
                    Text("8.5")
                        .padding(3)
                        .font(.caption2)
                }.padding(.vertical)

            }.padding(.horizontal, 10)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder private var downloadingStatusView: some View {
        switch rDownload.statusEnum {
        case .downloaded :
            Image(systemName: "text.justify")
            
        case .downloading, .downloading_sub, .paused :
            downloadingProgressView
            
        case .failed :
            Button(action: {}, label: {
                Image(systemName: "exclamationmark.circle.fill")
            })
            
        default :
            EmptyView()
        }
    }
    
    @ViewBuilder private var downloadingProgressView: some View {
        Gauge(value: viewModel.downloads[rDownload.video_filename]?.progress ?? rDownload.progress, in: 0...1) {
            switch rDownload.statusEnum {
            case .downloading:
                self.actionButtonView(action: {viewModel.pause(rDownload)}, icon: "pause.fill")
                
            case .paused:
                self.actionButtonView(action: {showingOptions.toggle()}, icon: "play.fill")
                
            default :
                EmptyView()
            }
        }.gaugeStyle(.accessoryCircularCapacity)
            .scaleEffect(0.7)
            .confirmationDialog("Selected Action", isPresented: $showingOptions) {
                Button("Resume", action: {viewModel.resume(rDownload)})
                
                Button("Delete", action: {viewModel.delete(rDownload)})
            }
    }
    
    @ViewBuilder private func actionButtonView(action: @escaping () -> Void, icon: String) -> some View {
        Button(
            action: action,
            label: {
                Image(systemName: icon)
            })
    }
}

