//
//  ExploreView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ExploreView: View {
    
    @StateObject var viewModel = ExploreViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.explore.indices, id: \.self) { index in
                        NavigationLink(destination: {
                            VStack {
                                ShowsView(viewModel: ShowViewModel(type: .filter(viewModel.explore[index].filter)))
                            }
                        }, label: {
                            KFImage.url(viewModel.explore[index].imageURL)
                                .placeholder {
                                    Color.black
                                        .frame(maxWidth: .infinity)
                                    
                                    Image(systemName: "popcorn.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondaryBrand)
                                }
                                .resizable()
                                .resizable()
                                .fade(duration: 0.25)
                                .scaledToFill()
                                .cornerRadius(5)
                                .padding(.trailing, 5)
                                
                        })
                    }
                }
                .padding()
            }.background(Color.primaryBrand)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Categories")
                .fontWeight(.bold)
                .overlay {
                    if viewModel.status == .loading {
                        VStack {
                            LoadingView()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }
                }
                .task {
                    viewModel.loadExplore()
                }
        }
    }
}
