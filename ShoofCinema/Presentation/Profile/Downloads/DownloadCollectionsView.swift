//
//  DownloadCollectionsView.swift
//  ShoofCinema
//
//  Created by mac on 9/10/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import RealmSwift
import Kingfisher




struct DownloadCollectionsView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @StateObject var viewModel: DownloadsViewModel

    @ObservedResults(RDownload.self, filter: NSPredicate(format: "isSeriesHeader = true")) var items

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(items, id: \.self) { item in
                NavigationLink(
                    destination: DownloadsEpisodesView(viewModel: viewModel, showId: item.show_id),
                    label: {card(show: item.show?.asShoofShow())})
                
                
            }
        }.padding(.horizontal)
    }
    
    @ViewBuilder private func card(show: ShoofAPI.Show?) -> some View {
        VStack(alignment: .leading) {
            KFImage.url(show?.coverURL)
                .placeholder {
                    Color.black
                }
                .resizable()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .cornerRadius(10)
            
            Text("\(show?.title ?? "")")
                .lineLimit(1)
                .padding([.leading, .trailing], 3)
                .font(.caption)
        }
        
    }
}

