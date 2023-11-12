//
//  DownloadsEpisodesView.swift
//  ShoofCinema
//
//  Created by mac on 9/17/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import RealmSwift

struct DownloadsEpisodesView: View {
    @StateObject var viewModel: DownloadsViewModel
    
    @ObservedResults(RDownload.self) var items
    
    init(viewModel: DownloadsViewModel, showId: String) {
        _viewModel = StateObject(wrappedValue: viewModel)
        $items.filter = NSPredicate(format: "show_id = %@ and isSeriesHeader = false", showId)
        
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(items, id: \.self) { item in
                    DownloadCardView(rDownload: item, viewModel: viewModel)
                    
                }
            }
            .padding(.horizontal)
        }
    }
}

