//
//  HomeSectionView.swift
//  ShoofCinema
//
//  Created by mac on 7/5/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct HomeSectionView: View {
    
    var section: ShoofAPI.Section
    @Environment(\.layoutDirection) private var layoutDirection
    
    var body: some View {
        VStack {
            HStack {
                Text("\(section.title)")
                
                Spacer()
                
                NavigationLink(destination: {
                    ShowsView(
                        viewModel: ShowViewModel(
                            type: section.actions != nil
                            ?
                            .filter(actionToFilter(action: section.actions))
                            : .section(id: section.id)
                        )
                    )
                }, label: {
                    Text("More")
                        
                })
            }.padding(.vertical, 5)
                .padding(.horizontal, 10)
                .font(Font(Fonts.almarai()))
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(section.shows.indices, id: \.self) { index in
                            NavigationLink(destination: {
                                VStack {
                                    ShowDetailsView(viewModel: ShowDetailsViewModel(show: section.shows[index]))
                                }
                            }, label: {
                                SmallPosterView(show: section.shows[index])
                            })
                        }
                    }.padding(.leading)
                    .id("RTL")
                        .onAppear {
                            if layoutDirection == .rightToLeft {
                                  proxy.scrollTo("RTL", anchor: .trailing)
                            }
                            
                            else {
                                proxy.scrollTo("RTL", anchor: .leading)
                            }
                        }
                }
            }
        }
    }
    
    private func actionToFilter(action: ShoofAPI.Action?) -> ShoofAPI.Filter {
         return .init(
            genreID: action?.genreId,
            categoryID: action?.categoryId,
            tagID: action?.tagId,
            rate: ShoofAPI.Filter.convertToString(from: action?.rate),
            year: action?.year != nil ? String("\(action?.year)") : nil,
            mediaType: action?.isMovie ?? .all,
            sortType: action?.sortType
         )
    }
}

