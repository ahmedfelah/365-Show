//
//  ReelView.swift
//  365Show
//
//  Created by ممم on 19/11/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import AVKit

struct ReelView: View {
    
    let reel: ShoofAPI.Show
    
    @State var player: AVPlayer?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Player(player: $player)
                .onAppear {
                    guard player == nil else {return}
                    player = AVPlayer(url: reel.trailerURL ?? URL(string: "http://imdb-video.media-imdb.com/vi1225109529/1421100405014-mxwp62-1434643350557.m3u8")!)
                    player?.play()
                    print("onAppear", reel.id)
                }
                .onDisappear {
                    player = nil
                    print("onDisappear", reel.id)
                }
            HStack(alignment: .bottom) {
                KingFisherImageView(url: reel.posterURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 150)
                    .clipped()
                    .padding()
                
                VStack(alignment: .leading) {
                    Text("\(reel.title)")
                        .font(.title2)
                    
                     Button(action: {}, label: {
                         Text("NAVIGATE TO SHOW")
                             .foregroundColor(.red)
                             .font(.callout)
                             .padding(5)
                             .background(.black.opacity(0.1))
                             .overlay(
                                 RoundedRectangle(cornerRadius: 2)
                                     .stroke(Color.gray, lineWidth: 1)
                             )
                     }).padding(.bottom)
                    
                }
                .padding(.vertical)
            }
            .padding(.bottom, 100)
            
        }.ignoresSafeArea(.all)
            
            
    }
}

struct Player : UIViewControllerRepresentable {
    
    @Binding var player : AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController{
        
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
        uiViewController.player = player
    }
}
