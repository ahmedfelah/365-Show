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
        NavView {
            ScrollView(showsIndicators: false) {
                VStack {
                    Image("360-show")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, alignment: .leading)
                        .padding([.bottom, .leading, .trailing])
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(viewModel.sections.indices, id: \.self) { index in
                    if viewModel.sections[index].style == .featured {
                        HomeCarouselView(shows: viewModel.sections[index].shows)
                            .frame(height: UIScreen.main.bounds.height * 0.35)
                            .environment(\.layoutDirection, .leftToRight)
                    }
                    
                    HomeSectionView(section: viewModel.sections[index])
                        .padding(.top)
                    
                }
                
            }
            .statusBar(hidden: true)
            .background(Color.primaryBrand)
            .font(Font(Fonts.almarai()))
            .task {
                if viewModel.sections.isEmpty {
                    viewModel.loadSections()
                }
            }
            .overlay {
                if viewModel.status == .loading {
                    VStack {
                        LoadingView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.2))
                }
                else if viewModel.status == .failed {
                    VStack {
                        ErrorView(action: {Task{viewModel.loadSections()}})
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
}


