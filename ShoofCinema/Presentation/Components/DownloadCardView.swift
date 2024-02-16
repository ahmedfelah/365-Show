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
    @State private var showingDeleteAlert = false
    
    
    var body: some View {
        HStack {
            KFImage.url(URL(string: rDownload.show?.posterURL ?? ""))
                .placeholder {
                    Color.black
                }
                .resizable()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 150)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(rDownload.show?.title ?? "")")
                    .lineLimit(1)
                    .padding(.vertical)
                    .font(.title3)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(Text("season:"))\(rDownload.series_season_title ?? "") \(Text("episode:"))\(rDownload.series_title ?? "")")
                            .lineLimit(1)
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("\(rDownload.formattedFileSize)")
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
                    
                    Text("\(rDownload.show?.rating ?? "_")")
                        .padding(3)
                        .font(.caption2)
                }.padding(.vertical)
                
            }.padding(.horizontal, 10)
                .foregroundColor(.gray)
            
        }.alert("delete confirmation", isPresented: $showingDeleteAlert) {
            Button("delete", role: .destructive) {viewModel.delete(rDownload)}
            Button("cancel", role: .cancel) {}
        } message: {
            Text("are you sure you want to delete?")
        }
    }
    
    @ViewBuilder private var downloadingStatusView: some View {
        switch rDownload.statusEnum {
        case .downloaded :
            Menu(content: {
                Button(action: {showingDeleteAlert.toggle()}, label: {
                    Text("delete")
                })
            }, label: {
                Image(systemName: "text.justify")
            })
            
        case .downloading, .downloading_sub, .paused :
            downloadingProgressView
            
        case .failed :
            Button(action: {showingOptions.toggle()}, label: {
                Image(systemName: "exclamationmark.circle.fill")
                    .imageScale(.large)
                    
            }).confirmationDialog("Selected Action", isPresented: $showingOptions) {
                Button("redownload", action: {viewModel.redownload(rDownload)})
                Button("delete", action: {viewModel.delete(rDownload)})
            }
            
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
            .confirmationDialog("selected action", isPresented: $showingOptions) {
                Button("resume", action: {viewModel.resume(rDownload)})
                
                Button("delete", action: {viewModel.delete(rDownload)})
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


