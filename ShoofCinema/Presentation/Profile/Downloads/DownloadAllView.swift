//
//  DownloadAllView.swift
//  ShoofCinema
//
//  Created by mac on 9/10/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import RealmSwift
import Kingfisher


struct DownloadAllView: View {
    
    
    @StateObject var viewModel: DownloadsViewModel

    @ObservedResults(RDownload.self, filter: NSPredicate(format: "isSeriesHeader = false")) var items

    var body: some View {
        LazyVStack {
            ForEach(items, id: \.self) { item in
                DownloadCardView(rDownload: item, viewModel: viewModel)
                
            }
        }
        .padding(.horizontal)
    }
}
