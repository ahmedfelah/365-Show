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
            if isOutsideDomain {
                NowInCinemaView()
                    .tabItem {
                        Label("", systemImage: "house.fill")
                    }
            }
            
            else {
                HomeView()
                    .tabItem {
                        Label("", systemImage: "house.fill")
                    }
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
            .task {
                checkReseller()
            }
    }
    
    
    private func checkReseller() {
    
        guard !isOutsideDomain && !ShoofAPI.AutoLogin.current else {return}
        
        for resellerUrl in ResellersUrl {
            guard let url = URL(string: resellerUrl) else {return}
            
            guard let baseUrl = baseUrl(url: resellerUrl) else {return}
            
            ResellerAPI.shared.getToken(url: url) { response in
                switch response {
                case .success(let reseller):
                    if reseller.status == 200 && reseller.token != nil {
                        self.autoLogin(token: reseller.token, baseUrl: baseUrl.absoluteString)
                        break
                    }
                case .failure(let errors):
                    print(errors)
                }
            }
        }
    }
    
    private func autoLogin(token: String?, baseUrl: String) {
        ShoofAPI.shared.autoLogin(token: token, deviceType: 2, baseUrl: baseUrl) { result in
            do {
                let response = try result.get()
                
                if response.body {
                    ShoofAPI.AutoLogin.current = true
                }
            }
            catch(let error) {
                print("auto login error", error)
            }
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
