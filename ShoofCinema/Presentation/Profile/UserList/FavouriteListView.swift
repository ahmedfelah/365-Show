//
//  FavouriteListView.swift
//  365Show
//
//  Created by ممم on 23/02/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI
import RealmSwift

struct FavouriteListView: View {
    @ObservedResults(RShow.self) var items
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(items , id: \.self) { item in
                    NavigationLink(destination: {
                        ShowDetailsView(viewModel: ShowDetailsViewModel(show: item.asShoofShow()))
                    }, label: {
                        HorizontalPosterView(show: item.asShoofShow())
                    }).padding(.bottom)
                }
            }.padding()
        }.overlay {
            if items.isEmpty{
                VStack {
                    HStack {
                        Text("your favourite list is")
                            .foregroundColor(.secondary)
                        
                        Text("empty")
                            .foregroundColor(.secondaryBrand)
                            .fontWeight(.semibold)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.primaryBrand)
            }
        }
        .background(Color.primaryBrand)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("favourite")
    }
}

#Preview {
    FavouriteListView()
}
