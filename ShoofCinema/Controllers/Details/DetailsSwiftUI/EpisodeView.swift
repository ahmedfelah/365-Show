//
//  EpisodeView.swift
//  ShoofCinema
//
//  Created by mac on 5/4/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct EpisodeView: View {
    
    let episode: ShoofAPI.Media.Episode
    let downloadAction : () -> Void
    var watchingProgress: Float = 0
    
    @State var isSelected: Bool = false
    @ObservedObject var viewModel: EpisodeViewModel
    
    init(episode: ShoofAPI.Media.Episode, viewModel: EpisodeViewModel, showId: String, downloadAction: @escaping () -> Void) {
        self.episode = episode
        self.downloadAction = downloadAction
        self.viewModel = viewModel
        let rm = RealmManager.rmContinueForPlayingShow(with: showId, with: episode)
        if let rm = RealmManager.rmContinueForPlayingShow(with: showId, with: episode) {
            watchingProgress = Float(rm.left_at_percentage)
        }
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            
            HStack {
                Text("\(episode.number)")
                    .foregroundColor(
                        isSelected
                        ? Color(uiColor: Theme.current.tintColor)
                        : .white)
                Spacer()
                
                DownloadCircleProgress(progress: $viewModel.progress, status: $viewModel.downloadStatus, downloadAction: downloadAction)
                
            }.padding(.horizontal)
            
            Spacer()
            
            ProgressView(value: watchingProgress, total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(uiColor: Theme.current.tintColor)))
                .background(Color(uiColor: Theme.current.backgroundColor))
        }
        
        .background(Color(uiColor: Theme.current.secondaryColor))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
}


fileprivate struct DownloadCircleProgress: View {
    @Binding var progress: Float
    @Binding var status: DownloadStatus
    let downloadAction : () -> Void
    var body: some View {
        ZStack {
            if status == .downloading {
                CircleProgress(progress: progress)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            
            else if status == .downloaded {
                Image(systemName: "checkmark")
                    .imageScale(.large)
                    .foregroundColor(Color(uiColor: Theme.current.tintColor))
            }
            
            else {
                Button(action: downloadAction) {
                    Image(systemName: "arrow.down.to.line")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }
        }.frame(width: 40, height: 40)
    }
}


struct CircleProgress: View {
    var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .foregroundColor(.white)
            
            Circle()
                .trim(from: CGFloat(progress), to: 1)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .foregroundColor(.gray)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }.environment(\.layoutDirection, .leftToRight)
    }
}
