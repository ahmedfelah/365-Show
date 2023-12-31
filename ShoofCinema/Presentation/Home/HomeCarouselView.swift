//
//  HomeCarousel.swift
//  ShoofCinema
//
//  Created by mac on 6/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct HomeCarouselView: View {
    
    @State var index = 0
    
    var shows: [ShoofAPI.Show] = []
    
    init(shows: [ShoofAPI.Show]) {
        self.shows = shows
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.secondaryBrand)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                TabView(selection: $index.animation()) {
                    ForEach(shows.indices, id:\.self) { index in
                        MainPosterView(show: shows[index])
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: UIScreen.main.bounds.height * 0.6, alignment: .top)
                    .clipped()
                
                VStack {
                    DotsIndexView(numberOfPages: shows.count, currentIndex: index)
                }
            }
            
            actionView
        }
    }
    
    @ViewBuilder private var actionView: some View {
        if !isOutsideDomain {
            HStack() {
                watchButtonView
                addToWtachLaterView
            }.foregroundColor(.tertiaryBrand)
                .padding()
        }
    }
    
    @ViewBuilder private var watchButtonView: some View {
        NavigationLink(destination: {ShowDetailsView(viewModel: ShowDetailsViewModel(show: shows[index]))}) {
            WatchButtonView()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.secondaryBrand)
                .cornerRadius(40)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    @ViewBuilder private var addToWtachLaterView: some View {
        Button(action: {}, label: {
            Image(systemName: "plus")
                .imageScale(.large)
                .padding(10)
                .foregroundColor(.white)
        }).background(Color.tertiaryBrand)
        .clipShape(Circle())
        .padding(.trailing)
    }
}

//struct HomeCarouselView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeCarouselView()
//    }
//}
