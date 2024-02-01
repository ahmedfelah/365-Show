//
//  ContentView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

enum ColorScheme: String {
    case dark = "dark"
    case light = "light"
}

struct ContentView: View {
    
    @AppStorage("colorScheme") var colorScheme: ColorScheme = .dark
    @AppStorage("language") var language: String = "en"
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    
    var body: some View {
        MainView()
            .environment(\.colorScheme, colorScheme == .dark ? .dark : .light)
            .environment(\.layoutDirection, language == "en" ? .leftToRight : .rightToLeft)
            .environment(\.locale, Locale(identifier: language))
        
    }
}



