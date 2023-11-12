//
//  HomeView.swift
//  ShoofCinema
//
//  Created by mac on 7/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI


struct HomeView: View {
    
    
    @StateObject var viewModel = HomeViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                ForEach(viewModel.sections.indices, id: \.self) { index in
                    if viewModel.sections[index].style == .featured {
                        ZStack(alignment: .topLeading) {
                            HomeCarouselView(shows: viewModel.sections[index].shows)
                                .frame(height: UIScreen.main.bounds.height * 0.7, alignment: .top)
                            
                             Image("360-show")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .padding()
                        }
                    }
                    
                    HomeSectionView(section: viewModel.sections[index])
                        .padding(.top)
                    
                }
                
            }.edgesIgnoringSafeArea(.top)
                .statusBar(hidden: true)
                .background(Color.primaryBrand)
                .task {
                    viewModel.loadSections()
                }
                .overlay {
                    if viewModel.status == .loading {
                        VStack {
                            LoadingView()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }
                }
        }
    }
}


