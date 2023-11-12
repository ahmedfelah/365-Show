//
//  MainView.swift
//  ShoofCinema
//
//  Created by mac on 9/14/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct MainView: View {
    let coloredNavAppearance = UINavigationBarAppearance()
    let coloredTabAppearance = UITabBarAppearance()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        
        coloredTabAppearance.configureWithOpaqueBackground()
        coloredTabAppearance.shadowColor = .clear
        coloredTabAppearance.backgroundColor = UIColor(Color.primaryBrand)

        
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.shadowColor = .clear
        coloredNavAppearance.backgroundColor = UIColor(Color.primaryBrand)
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.primaryText)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.primaryText)]
        
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
        
        UITabBar.appearance().standardAppearance = coloredTabAppearance
        UITabBar.appearance().scrollEdgeAppearance = coloredTabAppearance
        
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("", systemImage: "house.fill")
                }
            
            ExploreView()
                .tabItem {
                    Label("", systemImage: "rectangle.stack.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("", systemImage: "magnifyingglass")
                }
            
            UserProfileView()
                .tabItem {
                    Label("", systemImage: "person.circle.fill")
                }
        }.accentColor(.secondaryBrand)
            .toolbarBackground(Color.primaryBrand, for: .bottomBar)
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
